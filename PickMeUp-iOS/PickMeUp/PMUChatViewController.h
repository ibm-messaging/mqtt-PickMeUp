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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PMUMessageTableViewDataSource.h"

/** The PMUChatViewController implements the chat view of the application. */
@interface PMUChatViewController : UIViewController <PMUMessageTableViewDataSource, UITextFieldDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

/** Reload the chat table. */
- (void)reload;
/** Play an audio chat message.
 * @param sender The sender of the action.
 */
- (IBAction)playAudio:(id)sender;
/** Automatically play an audio chat message when it is received. 
 * @param message The audio message to be played. 
 */
- (void)playMessageOnArrival:(PMUMessage *)message;

@end
