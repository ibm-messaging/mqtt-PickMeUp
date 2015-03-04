/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
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