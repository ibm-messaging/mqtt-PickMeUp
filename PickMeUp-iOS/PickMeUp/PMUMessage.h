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