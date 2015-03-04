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
#import "MqttOCClient.h"
#import "PMUMessage.h"

/** PMUMessenger is the wrapper around the MQTT Client API's
 * for communicating with MessageSight.
 */
@interface PMUMessenger : NSObject

/** A handle to the iOS MQTT client. */
@property (nonatomic, retain) MqttClient *client;
/** The clientId used for the connection. */
@property NSString *clientId;

/** Returns the singleton PMUMessenger object. */
+ (id)sharedMessenger;

/** Connect to the MQTT broker at the specified host 
 * @param host The address of the MQTT broker to connect to.
 * @param port The port that the MQTT broker listens on.
 * @param clientId The client identifier used to identify the MQTT connection.
 */
- (void)connectWithHost:(NSString *)host
                   port:(int)port
               clientId:(NSString *)clientId;

/** Publish payload to topic.
 * @param topic The MQTT topic to publish the message to.
 * @param payload The content for the message.
 * @param qos The Quality of Service level to send the message as. (0,1,2)
 * @param retained The retained value to send the message as. (true,false)
 */
- (void)publish:(NSString *)topic
        payload:(NSString *)payload
            qos:(int)qos
       retained:(BOOL)retained;

/** Subscribe to topicFilter at the specified QoS.
 * @param topicFilter The MQTT topic filter to subscribe to.
 * @param qos The Quality of service level for the subscription.
 */
- (void)subscribe:(NSString *)topicFilter
              qos:(int)qos;

/** Unsubscribe from topicFilter.
 * @param topicFilter The MQTT topic filter to unsubscribe from.
 */
- (void)unsubscribe:(NSString *)topicFilter;

/** Disconnect from the MQTT broker. */
- (void)disconnect;

/** Add a PMUMessage to the chat table message cache.
 * @param message The message to be displayed.
 * @param from The ID of the sender of the message.
 */
- (void)displayChatMessage:(PMUMessage *)message
                      from:(NSString *)senderId;

@end
