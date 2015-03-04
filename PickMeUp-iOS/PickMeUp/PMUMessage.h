/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
 *******************************************************************************/

#ifndef ChatMessage_h
#define ChatMessage_h

#import "PMUConstants.h"

/** PMUChatSender defines the type of the chat message. */
typedef enum _PMUChatSender
{
    /** The message was sent by the passenger. */
    PMUChatPassenger = 0,
    /** The message was sent by the driver. */
    PMUChatDriver = 1,
} PMUChatSender;

/** PMUMessage represents a single chat message. */
@interface PMUMessage : NSObject

/** The date used for sorting chat messages. */
@property (nonatomic, strong) NSDate *date;
/** The sender of the chat message. PMUChatPassenger or PMUChatDriver. */
@property (nonatomic) PMUChatSender sender;
/** The message format. "text" or "data:wav/audio;base64". */
@property (nonatomic) NSString *format;
/** The message data. */
@property (nonatomic) NSString *data;
/** The view for the message. */
@property (nonatomic, strong) UIView *view;
/** The text of the message. */
@property (nonatomic, strong) NSString *text;
/** The insets for the message view. */
@property (nonatomic) UIEdgeInsets insets;

/** Returns a new PMUMessage instance.
 * @param text The message text.
 * @param date The date that the message was sent.
 * @param sender The sender of the message (PMUChatPassenger or PMUChatDriver).
 * @param format The format of the message (text or data:audio/wav;base64).
 */
+ (id)dataWithText:(NSString *)text
              date:(NSDate *)date
            sender:(PMUChatSender)sender
            format:(NSString *)format;

@end




#endif