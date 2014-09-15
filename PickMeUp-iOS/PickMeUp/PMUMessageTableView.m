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

#import "PMUMessageTableView.h"
#import "PMUAppDelegate.h"

#define NAME_HEIGHT 20

@implementation PMUMessageTableView

#pragma mark - Initializators

- (void)initializator
{
    // UITableView properties
    
    self.separatorStyle = UITableViewCellSeparatorStyleNone;

    assert(self.style == UITableViewStylePlain);
    
    self.delegate = self;
    self.dataSource = self;
}

- (id)init
{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame
              style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self initializator];
    return self;
}

/** Returns the number of sections in the table.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/** Returns the number of rows in section.
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.chatMessageDataSource rowsForChatTable:self];
}

/** Reload the chat table view.
 */
- (void)reloadData
{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    // Cleaning up
	self.chatSection = nil;
    
    // Loading new data
    int count = 0;
    self.chatSection = [[NSMutableArray alloc] init];
        
    if (self.chatMessageDataSource && (count = (int)[self.chatMessageDataSource rowsForChatTable:self]) > 0)
    {
        NSMutableArray *chatTableData = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++)
        {
            NSObject *object = [self.chatMessageDataSource chatMessageTableView:self dataForRow:i];
            assert([object isKindOfClass:[PMUMessage class]]);
            PMUMessage *message = (PMUMessage *)object;
            if (![message.text isEqualToString:@""])
                [chatTableData addObject:object];
        }
        
        [chatTableData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             PMUMessage *chatMessage1 = (PMUMessage *)obj1;
             PMUMessage *chatMessage2 = (PMUMessage *)obj2;
        
             return [chatMessage1.date compare:chatMessage2.date];
         }];
        
        for (int i = 0; i < count; i++)
        {
            PMUMessage *data = (PMUMessage *)[chatTableData objectAtIndex:i];
            [self.chatSection addObject:data];
        }
    }
    
    [super reloadData];
    [self scrollChatViewToBottomAnimated];
}

/** Return the height for the cell at indexPath.
 */
- (CGFloat)   tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMUMessage *data = [self.chatSection objectAtIndex:indexPath.row];
    return data.insets.top + data.view.frame.size.height + data.insets.bottom + NAME_HEIGHT;
}

/**
 Diagram of chat table view
 |-------------------------------|
 |     ___                       |  AA    ==> Avatar image
 | AA |txt|                      |  AA
 | AA |___|                      |
 |                       ___     |
 |                      |txt| AA |
 |                      |___| AA |   ___
 |                               |  |txt| ==> Chat bubble
 |                               |  |___|
 
 iPhone values
 
 For PMUChatSender = PMUChatDriver:
 Avatar at x = 5, width 35
 Chat bubble at x = 40, width based on text / audio icon
 Text at x = 40 + data.insets.left
 
 For PMUChatSender = PMUChatPassenger:
 Avatar at x = self.frame.size.width - 40
 Chat bubble at x = self.frame.size.width - 40 - width - data.insets.left - data.insets.right
 Text at x = self.frame.size.width - 40 - width - data.insets.right
 
 ...
 
 iPad values
 
 For PMUChatType = PMUMessageSomeoneElse:
 Avatar at x = 10, width 70
 Chat bubble at x = 80, width based on text / audio icon
 Text at x = 80 + data.insets.left
 
 For PMUChatType = PMUMessageMine:
 Avatar at x = self.frame.size.width - 80
 Chat bubble at x = self.frame.size.width - 80 - width - data.insets.left - data.insets.right
 Text at x = self.frame.size.width - 80 - width - data.insets.right
 
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    PMUMessage *data = [self.chatSection objectAtIndex:indexPath.row];
    
    // Create the subviews for the table cell
    UIImageView *avatarImage = [self createAvatarImageSubview:data.sender];
    [cell addSubview:avatarImage];
    
    UIImageView *bubbleImage = [self createBubbleImageSubview:data];
    [cell addSubview:bubbleImage];

    UIView *textView = [self createTextView:data];
    [cell addSubview:textView];
    
    if ([data.format isEqualToString:PMUAudioFormat])
    {
        UIButton *voiceButton = [self createAudioButtonSubview:bubbleImage];
        [cell addSubview:voiceButton];
    }
    
    [cell setBackgroundColor:[UIColor colorWithRed:58/255.0 green:74/255.0 blue:83/255.0 alpha:1.0]];

    return cell;
}

/** Create the subview for a cell that displays the audio
 * button for an audio chat message.
 */
- (UIButton *)createAudioButtonSubview:(UIImageView *)imageView
{
    UIButton *voiceButton = [[UIButton alloc] init];
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    voiceButton.frame = imageView.frame;
    [voiceButton addTarget:appDelegate.chatController action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    return voiceButton;
}

/** Create the subview for a cell that contains the avatar image
 * for the sender of the message.
 */
- (UIImageView *)createAvatarImageSubview:(PMUChatSender)sender
{
    UIImageView *avatarImage = [[UIImageView alloc] init];
    PMUDriver *driver = [PMUDriver sharedDriver];
    PMURequest *request = [PMURequest sharedRequest];
    
    CGFloat xAvatar;
    CGFloat y;
    
    // x positions for chat on left side of screen
    if (sender == PMUChatDriver)
    {
        xAvatar = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 10 : 5;
        
        avatarImage.image = driver.image;
    }
    // x positions for chat on right side of screen
    else
    {
        xAvatar = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? self.frame.size.width - 80 : self.frame.size.width - 40;
        avatarImage.image = request.image;
    }
    
    y = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        avatarImage.frame = CGRectMake(xAvatar, y+10, 70, 70);
        avatarImage.layer.cornerRadius = 15;
        avatarImage.layer.masksToBounds = YES;
        avatarImage.layer.borderWidth = 1;
    }
    else
    {
        avatarImage.frame = CGRectMake(xAvatar, y+5, 35, 35);
        avatarImage.layer.cornerRadius = 15;
        avatarImage.layer.masksToBounds = YES;
        avatarImage.layer.borderWidth = 1;
    }
    
    return avatarImage;
}

/** Create the subview for a table cell that contains the background
 * bubble image for a chat message.
 */
- (UIImageView *)createBubbleImageSubview:(PMUMessage *)message
{
    UIImageView *bubbleImage = [[UIImageView alloc] init];
    
    CGFloat xBubble;
    CGFloat y;
    CGFloat width = message.view.frame.size.width;
    CGFloat height = message.view.frame.size.height;
    
    // x positions for chat on left side of screen
    if (message.sender == PMUChatDriver)
    {
        xBubble = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 80 : 40;
    }
    // x positions for chat on right side of screen
    else
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            xBubble = self.frame.size.width - 80 - width - message.insets.left - message.insets.right;
        else
            xBubble = self.frame.size.width - 40 - width - message.insets.left - message.insets.right;
    }
    
    y = 0;
    
    bubbleImage.frame = CGRectMake(xBubble, y, width + message.insets.left + message.insets.right, height + message.insets.top + message.insets.bottom);
    
    if (message.sender == PMUChatDriver)
    {
        bubbleImage.image = [[UIImage imageNamed:PMUBubbleDriverImage] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    }
    else if (message.sender == PMUChatPassenger)
    {
        bubbleImage.image = [[UIImage imageNamed:PMUBubblePassengerImage] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
    }
    
    return bubbleImage;
}

/** Create the subview for a table cell that contains the
 * text of a PMUMessage object.
 */
- (UIView *)createTextView:(PMUMessage *)message
{
    UIView *textView = message.view;
    
    CGFloat xText;
    CGFloat y;
    CGFloat width = message.view.frame.size.width;
    CGFloat height = message.view.frame.size.height;
    
    // x positions for chat on left side of screen
    if (message.sender == PMUChatDriver)
    {
        xText = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 80 + message.insets.left : 40 + message.insets.left;
    }
    // x positions for chat on right side of screen
    else
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            xText = self.frame.size.width - 80 - width - message.insets.right;
        else
            xText = self.frame.size.width - 40 - width - message.insets.right;
    }
    
    y = 0;
    
    textView.frame = CGRectMake(xText, y + message.insets.top, width, height);
    
    return textView;
}

/** Scroll the chat view to the bottom when a new message is received.
 */
- (void)scrollChatViewToBottomAnimated
{
    if ([self.chatMessageDataSource rowsForChatTable:self] < 1)
    {
        return;
    }
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.chatMessageDataSource rowsForChatTable:self] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end
