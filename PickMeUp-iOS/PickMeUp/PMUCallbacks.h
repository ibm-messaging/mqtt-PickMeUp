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
#import <MapKit/MapKit.h>

#import "PMUMessenger.h"
#import "PMUDriver.h"

/** InvocationComplete protocol for MqttClient. */
@interface InvocationCompleteCallbacks : NSObject <InvocationComplete>

/** Called when an API call completes sucessfully.
 * @param invocationContext A pointer to an object that is made available to
 * the onSuccess function.
 */
- (void)onSuccess:(NSObject *)invocationContext;
/** Called when an API call fails.
 * @param invocationContext A pointer to an object that is made available to
 * the onFailure function.
 * @param errorCode The error code corresponding to the failure.
 * @param errorMessage the error message corresponding to the failure.
 */
- (void)onFailure:(NSObject *)invocationContext
        errorCode:(int)errorCode
     errorMessage:(NSString *)errorMessage;

@end

/** GeneralCallbacks protocol for MqttClient. */
@interface GeneralCallbacks : NSObject <MqttCallbacks>

/** Called when connection to the MQTT broker is lost unexpectedly.
 * @param invocationContext A pointer to an object that is made available to
 * the onConnectionLost function.
 * @param errorMessage The error message explaining the failure.
 */
- (void)onConnectionLost:(NSObject *)invocationContext
            errorMessage:(NSString *)errorMessage;
/** Called when an MQTT message arrives at the client.
 * @param invocationContext A pointer to an object that is made available to
 * the onMessageArrived function.
 * @param message The message that was received.
 */
- (void)onMessageArrived:(NSObject *)invocationContext
                 message:(MqttMessage *)message;
/** Called when the client has completed delivering a message.
 * @param invocationContext A pointer to an object that is made available to
 * the onMessageDelivered function.
 * @param messageId The messageId of the message that was delivered.
 */
- (void)onMessageDelivered:(NSObject *)invocationContext
                 messageId:(int)messageId;

@end
