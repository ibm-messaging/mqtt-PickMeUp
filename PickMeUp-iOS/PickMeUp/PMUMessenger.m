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

#import "PMUMessenger.h"
#import "PMUCallbacks.h"
#import "PMUAppDelegate.h"
#import "PMUMessage.h"

@implementation PMUMessenger

/** Initialize a PMUMessenger instance. */
- (id)init
{
    if (self = [super init])
    {
        self.client = [MqttClient alloc];
        self.client.callbacks = [[GeneralCallbacks alloc] init];
    }
    return self;
}

+ (id)sharedMessenger
{
    static PMUMessenger *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)connectWithHost:(NSString *)host
                   port:(int)port
               clientId:(NSString *)clientId
{
    ConnectOptions *opts = [[ConnectOptions alloc] init];
    opts.timeout = 15;
    // TODO: Use cleanSession = NO for durable subscriptions.
    opts.cleanSession = YES;
    opts.keepAliveInterval = 30;
    
    self.client = [self.client initWithHost:host port:port clientId:clientId];
    
    // Set up will message to pickmeup/passengers/<passenger_id>
    MqttMessage *willMessage = [[MqttMessage alloc] initWithMqttMessage:[PMUTopicFactory getPassengerTopLevelTopic] payload:"" length:0 qos:0 retained:NO duplicate:NO];
    opts.willMessage = willMessage;
    
    NSLog(@"%s:%d host=%@, port=%d, clientId=%@", __func__, __LINE__, host, port, clientId);
    
    [self.client connectWithOptions:opts invocationContext:PMUContextConnect onCompletion:[[InvocationCompleteCallbacks alloc] init]];
}

- (void)publish:(NSString *)topic
        payload:(NSString *)payload
            qos:(int)qos
       retained:(BOOL)retained
{
    char *utfPayload = (char *)[payload UTF8String];
    
    MqttMessage *msg = [[MqttMessage alloc] initWithMqttMessage:topic payload:utfPayload length:(int)payload.length qos:qos retained:retained duplicate:NO];
    [self.client send:msg invocationContext:PMUContextSend onCompletion:[[InvocationCompleteCallbacks alloc] init]];
}

- (void)subscribe:(NSString *)topicFilter
              qos:(int)qos
{
    NSString *invocationContext = [NSString stringWithFormat:@"%@/%@", PMUContextSubscribe, topicFilter];
    [self.client subscribe:topicFilter qos:qos invocationContext:invocationContext onCompletion:[[InvocationCompleteCallbacks alloc] init]];
}

- (void)unsubscribe:(NSString *)topicFilter
{
    NSString *invocationContext = [NSString stringWithFormat:@"%@/%@", PMUContextUnsubscribe, topicFilter];
    [self.client unsubscribe:topicFilter invocationContext:invocationContext onCompletion:[[InvocationCompleteCallbacks alloc] init]];
}

- (void)disconnect
{
    DisconnectOptions *opts = [[DisconnectOptions alloc] init];
    opts.timeout = 10;
    [self.client disconnectWithOptions:opts invocationContext:PMUContextDisconnect onCompletion:[[InvocationCompleteCallbacks alloc] init]];
}

- (void)displayChatMessage:(PMUMessage *)message
                      from:(NSString *)senderId
{
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // The message always goes into the cache for the chat view.
    [appDelegate.messageCache addObject:message];

    [appDelegate.chatController reload];
    if ([senderId isEqualToString:[PMUTopicFactory getPassengerId]] == NO)
    {
        // Only autoplay message if it came from the driver.
        [appDelegate.chatController playMessageOnArrival:message];
    }
}

@end
