/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
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
