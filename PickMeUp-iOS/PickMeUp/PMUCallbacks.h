/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
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
