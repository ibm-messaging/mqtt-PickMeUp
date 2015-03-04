/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
 *******************************************************************************/

#import "PMUFinalizeViewController.h"
#import "PMUAppDelegate.h"

@interface PMUFinalizeViewController()

@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *costLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIStepper *stepper;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) IBOutlet UITextField *tipTextField;
@property (strong, nonatomic) IBOutlet UIImageView *driverImage;
@property (strong, nonatomic) IBOutlet UILabel *driverNameLabel;

@property (nonatomic) CGPoint tipFrameOrigin;

@end

@implementation PMUFinalizeViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.finalizeController = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tipTextField setDelegate:self];
    
    // Keyboard events
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
    
    PMUDriver *driver = [PMUDriver sharedDriver];
    PMURequest *request = [PMURequest sharedRequest];

    if (driver.name != nil)
    {
        self.driverNameLabel.text = driver.name;
    }
    if (driver.image != nil)
    {
        self.driverImage.image = driver.image;
    }
    
    // Time is sent in seconds
    int seconds = [request.time intValue] % 60;
    int minutes = ([request.time intValue] / 60) % 60;
    int hours = [request.time intValue] / 3600;
    
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", [request.distance doubleValue]];
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    self.costLabel.text = [NSString stringWithFormat:@"$%.2f", [request.cost doubleValue]];
}

#pragma mark NSNotifications

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGRect frame = self.tipTextField.frame;
        self.tipFrameOrigin = frame.origin;
        frame.origin.y = screenSize.height - kbSize.height - frame.size.height;
        self.tipTextField.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.tipTextField.frame;
        frame.origin = self.tipFrameOrigin;
        self.tipTextField.frame = frame;
    }];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)text
{
    [text resignFirstResponder];
    return YES;
}

#pragma mark Actions

- (IBAction)onSubmitPressed:(id)sender
{
    PMUMessenger *messenger = [PMUMessenger sharedMessenger];

    // publish to backend pickmeup/payments
    NSString *payload = [PMUMessageFactory createPaymentMessage:[self.tipTextField.text doubleValue] rating:(int)self.stepper.value];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Submitted" message:@"Please wait for transaction to complete" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    [messenger publish:[PMUTopicFactory getPaymentTopic] payload:payload qos:2 retained:NO];
}

- (IBAction)onStepperPressed:(id)sender
{
    self.ratingLabel.text = [NSString stringWithFormat:@"%d", (int)self.stepper.value];
}

/** 1. Clear retained messages.
 * 2. Disconnect from the MQTT broker.
 * 3. Clear PMUDriver, PMURequest, and messageCache.
 * 4. Switch back to request view controller.
 */
- (IBAction)homePressed:(id)sender
{
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate resetApplication];
}

@end
