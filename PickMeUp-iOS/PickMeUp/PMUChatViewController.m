/*******************************************************************************
 * Copyright (c) 2014 IBM Corp.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 *
 * The Eclipse Public License is available at
 *   http://www.eclipse.org/legal/epl-v10.html
 * and the Eclipse Distribution License is available at
 *   http://www.eclipse.org/org/documents/edl-v10.php.
 *
 * Contributors:
 *    Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 *    Rahul Gupta, Vasfi Gucer
 *******************************************************************************/

#import "PMUChatViewController.h"
#import "PMUMessageTableView.h"
#import "PMUAppDelegate.h"

@interface PMUChatViewController ()

// Chat message view
@property (weak,nonatomic) IBOutlet UIView *textInputView;
@property (weak,nonatomic) IBOutlet UITextField *textField;
@property (weak,nonatomic) IBOutlet UIButton *sendButton;
@property (weak,nonatomic) IBOutlet UIButton *recordButton;
@property (weak,nonatomic) IBOutlet PMUMessageTableView *chatTable;
@property (nonatomic) AVAudioRecorder *recorder;
@property (nonatomic) AVAudioPlayer *player;

@end

@implementation PMUChatViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.chatController = self;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.chatController = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [self.navigationItem setHidesBackButton:YES];
    
    [self.textField setDelegate:self];
    
    self.chatTable.chatMessageDataSource = self;
    
    // Set file path for recorder
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"ChatMessage.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    
    // Keyboard events
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [self reload];
}

/** The chat controller displays the navigation bar for switching back and forth
 * between chat and map views.
 * Set color for navigation bar and navigation items.
 */
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:34/255.0 green:51/255.0 blue:63/255.0 alpha:1.0];
    
    CGRect titleViewFrame = CGRectMake(0, 0, 160, 44);
    UIView* titleView = [[UILabel alloc] initWithFrame:titleViewFrame];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.autoresizesSubviews = YES;
    
    NSAttributedString *titleAttrString = [[NSAttributedString alloc] initWithString:@"PickMeUp" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:13/255.0 green:191/255.0 blue:153/255.0 alpha:1.0]}];
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setAttributedText:titleAttrString];
    
    CGRect topTitleFrame = CGRectMake(0, 2, 160, 44);
    UILabel *topTitleView = [[UILabel alloc] initWithFrame:topTitleFrame];
    topTitleView.attributedText = titleAttrString;
    topTitleView.textAlignment = NSTextAlignmentCenter;
    topTitleView.adjustsFontSizeToFitWidth = NO;
    [titleView addSubview:topTitleView];
    
    self.navigationItem.titleView = titleView;
}

/** Switching to map view screws up the text field if the keyboard is currently
 * shown, so call resignFirstResponder whenever switching to map view.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    [self.textField resignFirstResponder];
}

- (void)playAudio:(id)sender
{
    if (!self.recorder.recording)
    {
        CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.chatTable];
        NSIndexPath *indexPath = [self.chatTable indexPathForRowAtPoint:buttonOriginInTableView];
        PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        PMUMessage *message = [appDelegate.messageCache objectAtIndex:indexPath.row];
        NSData *audio = [[NSData alloc] initWithBase64EncodedString:message.data options:0];
        NSError *error = nil;
        self.player = [[AVAudioPlayer alloc] initWithData:audio error:&error];
        
        if (error != nil)
        {
            NSLog(@"Error: %@", error);
        }
        
        [self.player setDelegate:self];
        [self.player play];
    }
}

- (void)playMessageOnArrival:(PMUMessage *)message
{
    // Only play the message if a voice message is not in the middle
    // of being recorded.
    if (!self.recorder.recording)
    {
        if ([message.format isEqualToString:PMUAudioFormat])
        {
            NSData *audio = [[NSData alloc] initWithBase64EncodedString:message.data options:0];
            NSError *error = nil;
            self.player = [[AVAudioPlayer alloc] initWithData:audio error:&error];
            
            if (error != nil)
            {
                NSLog(@"Error in json string: %@", error);
            }
            
            [self.player setDelegate:self];
            [self.player play];
        }
    }
}

/** Publish an outgoing text message.
 */
- (void)sendChatMessage
{
    if (self.recorder.recording)
    {
        // If currently recording, treat send pressed as stop pressed.
        [self recordPressed:self.recordButton];
        return;
    }
    NSString *textToSend = [self.textField text];
    if ([textToSend isEqualToString:@""] || [textToSend isEqualToString:@"Recording..."])
    {
        // Don't send if no content.
        return;
    }
    [self.textField setText:@""];
    
    [self sendMessage:textToSend withFormat:PMUTextFormat];
}

/** Construct and send text and audio chat messages.
 */
- (void)sendMessage:(NSString *)payload
         withFormat:(NSString *)format
{
    /* { “format” : “text” , “data” : “text message” } */
    NSString *payloadEscaped = [payload stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *payloadString = [PMUMessageFactory createChatMessage:format payload:payloadEscaped];
    
    PMUMessenger *messenger = [PMUMessenger sharedMessenger];
    NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]];
    
    /* pickmeup/drivers/<driverId>/chat */
    [messenger publish:[PMUTopicFactory getDriverChatTopic] payload:payloadString qos:0 retained:NO];
    
    PMUMessage *newMessage = [PMUMessage dataWithText:payloadString date:date sender:PMUChatPassenger format:format];
    [messenger displayChatMessage:newMessage from:[PMUTopicFactory getPassengerId]];
    [self reload];
}

- (void)reload
{
    [self.chatTable reloadData];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)text
{
    [text resignFirstResponder];
    [self sendChatMessage];
    return YES;
}

#pragma mark PMUMessageTableViewDataSource

- (NSInteger)rowsForChatTable:(PMUMessageTableView *)tableView
{
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.messageCache.count;
}

- (PMUMessage *)chatMessageTableView:(PMUMessageTableView *)tableView
                          dataForRow:(NSInteger)row
{
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return [appDelegate.messageCache objectAtIndex:row];
}

#pragma mark NSNotifications

/** Raise the text field view when keyboard is shown.
 */
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = self.textInputView.frame;
        frame.origin.y -= kbSize.height;
        self.textInputView.frame = frame;
        
        frame = self.chatTable.frame;
        frame.size.height -= kbSize.height;
        self.chatTable.frame = frame;
    }];
}

/** Lower the text field view when keyboard goes away.
 */
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = self.textInputView.frame;
        frame.origin.y += kbSize.height;
        self.textInputView.frame = frame;
        
        frame = self.chatTable.frame;
        frame.size.height += kbSize.height;
        self.chatTable.frame = frame;
    }];
}

#pragma mark Actions

/** The record button was pressed.
 * If the recorder is already recording, then stop recording
 * and send the data.
 * If the recorder is not recording, begin recording.
 */
- (IBAction)recordPressed:(id)sender
{
    // Stop the audio player before recording
    if (self.player.playing)
    {
        [self.player stop];
    }
    
    if (!self.recorder.recording)
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [session setActive:YES error:nil];
        
        [self.recordButton setImage:[UIImage imageNamed:PMUStopImage] forState:UIControlStateNormal];
        
        // Start recording
        self.textField.text = @"Recording...";
        self.textField.userInteractionEnabled = NO;
        [self.recorder record];
    }
    else
    {
        [self.recordButton setImage:[UIImage imageNamed:PMUMicrophoneImage] forState:UIControlStateNormal];

        self.textField.userInteractionEnabled = YES;
        self.textField.text = @"";
        [self.recorder stop];
        
        NSData *sounds = [[NSData alloc] initWithContentsOfURL:self.recorder.url options:0 error:nil];
        NSString *base64String = [sounds base64EncodedStringWithOptions:0];
        
        [self sendMessage:base64String withFormat:PMUAudioFormat];
    }
}

/** Send was pressed.
 */
- (IBAction)sendPressed:(id)sender
{
    [self sendChatMessage];
}

@end
