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

#import "PMUMessage.h"
#import "PMUAppDelegate.h"

@implementation PMUMessage

const UIEdgeInsets textInsetsPassenger = {10, 15, 16, 26};
const UIEdgeInsets textInsetsDriver = {10, 20, 16, 19};

+ (id)dataWithText:(NSString *)text
              date:(NSDate *)date
            sender:(PMUChatSender)sender
            format:(NSString *)format
{
    return [[PMUMessage alloc] initWithText:text date:date sender:sender format:format];
}

/** Initialize the PickMeUp specific properties of the PMUMessage object. */
- (id)initWithText:(NSString *)text
              date:(NSDate *)date
            sender:(PMUChatSender)sender
            format:(NSString *)format
{
    UIImageView *imageView = nil;
    UIImage *image;
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:[text dataUsingEncoding:NSUTF8StringEncoding]
                          options:NSJSONReadingMutableContainers
                          error:&error];
    if (!json)
    {
        NSLog(@"Error in json string: %@", error);
    }
    else
    {
        // Text message
        if ([format isEqualToString:PMUTextFormat])
        {
            self.text = [NSString stringWithFormat:@"%@", [json objectForKey:PMUDataField]];
            self.data = nil;
        }
        // Audio message
        else if ([format isEqualToString:PMUAudioFormat])
        {
            // data:audio/wav;base64,
            self.data = [json objectForKey:PMUDataField];
            image = [UIImage imageNamed:PMUMicrophoneImage];
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
            imageView.image = image;
        }
    }
    
    self.format = format;
    self.date = date;
    self.sender = sender;
    self.insets = (sender == PMUChatPassenger ? textInsetsPassenger : textInsetsDriver);

    return [self initWithView:imageView date:date sender:sender];
}

/** Initialize the view properties of the PMUMessage object. */
- (id)initWithView:(UIView *)view
              date:(NSDate *)date
            sender:(PMUChatSender)sender
{
    self = [super init];
    if (self)
    {
        
        UIFont *font;
        CGSize size;
        UILabel *label;
        
        // Set maximum chat bubble width
        NSInteger bubbleWidth;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            font = [UIFont systemFontOfSize:28.0];
            bubbleWidth = 500;
        }
        else
        {
            font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            bubbleWidth = 220;
        }
        
        // Create UILabel for message content
        CGRect textRect = [(self.text ? self.text : @"") boundingRectWithSize:CGSizeMake(bubbleWidth,9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        size = CGSizeMake(textRect.size.width, textRect.size.height);
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = (self.text ? self.text : @"");
        label.font = font;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [label setUserInteractionEnabled:YES];
        
        // If view != nil then it is an audio message.
        // The chat bubble will contain a button to play the message.
        if (view != nil)
        {
            CGSize frameSize = CGSizeMake(25, 25);
            UIView *messageView = [[UIView alloc] init];
            [messageView setFrame:CGRectMake(0, 0, frameSize.width, frameSize.height+5)];
            [view setFrame:CGRectMake(0, 5, 20, 20)];
            [view setUserInteractionEnabled:YES];
            [messageView addSubview:label];
            [messageView addSubview:view];
            [messageView setUserInteractionEnabled:YES];
            self.view = messageView;
        } else
        {
            self.view = label;
        }
    }
    return self;
}

@end