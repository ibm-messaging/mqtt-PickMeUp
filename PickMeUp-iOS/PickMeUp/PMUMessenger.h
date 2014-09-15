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
