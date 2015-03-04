/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
 *******************************************************************************/

#import "PMUCallbacks.h"
#import "PMUAppDelegate.h"
#import "PMUMessage.h"

// TODO: For all callbacks -- Handle failures appropriately instead of just
//       logging them.

@class PMUMapViewController;

@implementation InvocationCompleteCallbacks

- (void)onSuccess:(NSObject *)invocationContext
{
    NSLog(@"%s:%d - invocationContext=%@", __func__, __LINE__, invocationContext);
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // If invocationContext is MqttClient class, then this was called for a send
    if ([invocationContext isKindOfClass:[MqttClient class]])
    {
        return;
    }
    // Otherwise it is expected to be an NSString
    else if (![invocationContext isKindOfClass:[NSString class]])
    {
        NSLog(@"InvocationContext was not an NSString or MqttClient object");
        return;
    }
    
    NSString *context = (NSString *)invocationContext;
    
    // Handle the callback based on the content of invocationContext
    if ([context isEqualToString:PMUContextConnect])
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [appDelegate subscribeToInbox];
        });
    }
    else if ([context isEqualToString:PMUContextDisconnect])
    {
        // Do nothing
    }
    else if ([context isEqualToString:PMUContextSend])
    {
        // Do nothing
    }
    else
    {
        NSArray *parts = [context componentsSeparatedByString:@"/"];
        if ([parts[0] isEqualToString:PMUContextSubscribe])
        {
            // subscribe/pickmeup/passengers/passengerId/inbox
            //     0         1         2          3        4
            if ([parts count] == 5 && [[parts objectAtIndex:4] isEqualToString:PMUTopicInbox])
            {
                PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [appDelegate sendPresenceAndRequest];
                });
            }
        }
        else if ([parts[0] isEqualToString:PMUContextUnsubscribe])
        {
            // Do nothing
        }
    }
}

- (void)onFailure:(NSObject *)invocationContext
        errorCode:(int)errorCode
     errorMessage:(NSString*)errorMessage
{
    NSLog(@"%s:%d - invocationContext=%@  errorCode=%d  errorMessage=%@", __func__, __LINE__, invocationContext, errorCode, errorMessage);
    // TODO: Handle failures.
}

@end

#pragma mark General Callbacks

@implementation GeneralCallbacks

- (void)onConnectionLost:(NSObject *)invocationContext
            errorMessage:(NSString *)errorMessage
{
    NSLog(@"%s:%d - %@", __func__, __LINE__, errorMessage);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Lost" message:@"The connection to the server has been lost. Your trip has been cancelled" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK" , nil];
    [alert show];
    
    // TODO: Handle connection losses.
}

/** Callback method for UIAlertView. */
- (void)   alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // User pressed OK on connection lost popup. Reset the application.
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate resetApplication];
}

- (void)handleChatMessage:(NSDictionary *)json topic:(NSString *)topic payload:(NSString *)payload
{
    PMUMessenger *messenger = [PMUMessenger sharedMessenger];
    
    // parse chat message (text or audio)
    NSString* format = [json objectForKey:PMUFormatField];
    PMUChatSender sender = PMUChatDriver;
    
    // Use timestamp based on receiving clients time, so that messages show up in the order
    // that they arrive.
    NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]];
    
    PMUMessage *message = [PMUMessage dataWithText:payload date:date sender:sender format:format];
    [messenger displayChatMessage:message from:[PMUTopicFactory getDriverId]];
}

/** The incoming message is an inbox message.
 */
- (void)handleInboxMessage:(NSDictionary *)json topic:(NSString *)topic
{
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *type = [json objectForKey:PMUTypeField];
    if ([type isEqualToString:PMUTypeAccept])
    {
        // switch to pairing view
        [appDelegate createPairSubscriptions:json];
    }
    else if ([type isEqualToString:PMUTypeTripStart])
    {
        // switch to trip started view
        [appDelegate switchToTripStarted];
    }
    else if ([type isEqualToString:PMUTypeTripEnd])
    {
        // switch to finalize view
        [appDelegate deletePairSubscriptions:json];
    }
    else if ([type isEqualToString:PMUTypeTripProcessed])
    {
        // switch to payment processed view
        [appDelegate switchToTripProcessed];
    }
    
    return;
}

/** The incoming message is a location update.
 */
- (void)handleLocationMessage:(NSDictionary *)json topic:(NSString *)topic
{
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    // json field lon, lat
    NSNumber *lon = (NSNumber *)[json objectForKey:PMULongitudeField];
    NSNumber *lat = (NSNumber *)[json objectForKey:PMULatitudeField];
    
    CLLocationCoordinate2D location;
    location.longitude = [lon doubleValue];
    location.latitude = [lat doubleValue];
    
    [appDelegate updateDriver:location];
}

/** The incoming message is a picture message.
 */
- (void)handlePictureMessage:(NSDictionary *)json
{
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // get driver picture for driverFound view
    NSString *imageData = [json objectForKey:PMUURLField];
    
    if (imageData.length < 23)
    {
        NSLog(@"invalid image string");
        return;
    }
    NSString *imageString = [imageData substringFromIndex:22];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:imageString options:0];
    UIImage *image = [UIImage imageWithData:data];
    [appDelegate.driverFoundController setDriverPicture:image];
}

/** The incoming message is a status message.
 */
- (void)handleStatusMessage:(NSDictionary *)json
{
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    PMUDriver *driver = [PMUDriver sharedDriver];
    
    // get driver name for driverFound view
    NSString *name = [json objectForKey:PMUNameField];
    [appDelegate.driverFoundController setDriverName:name];
    [driver setName:name];
}

- (void)onMessageArrived:(NSObject *)invocationContext
                 message:(MqttMessage *)message
{
    NSString *topic = message.destinationName;
    NSArray *topicParts = [topic componentsSeparatedByString:@"/"];
    
    NSString *payload = [[NSString alloc] initWithBytes:message.payload length:message.payloadLength encoding:NSASCIIStringEncoding];

    NSLog(@"MQTT Message Received\n\tTopic: %@\n\tPayload: %@", topic, payload);
    
    // Convert the message payload to a dictionary for parsing
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding]
                          options:NSJSONReadingMutableContainers
                          error:&error];
    if (error)
    {
        NSLog(@"Error parsing json: %@", error);
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // pickmeup/passengers/<passenger_id>/inbox
        if ([topicParts count] == 4 && [[topicParts objectAtIndex:3] isEqualToString:PMUTopicInbox])
        {
            [self handleInboxMessage:json topic:topic];
        }
        // pickmeup/drivers/<driver_id>/location
        else if ([topicParts count] == 4 && [[topicParts objectAtIndex:3] isEqualToString:PMUTopicLocation])
        {
            [self handleLocationMessage:json topic:topic];
        }
        // pickmeup/drivers/<driver_id>/picture
        else if ([topicParts count] == 4 && [[topicParts objectAtIndex:3] isEqualToString:PMUTopicPicture])
        {
            [self handlePictureMessage:json];
        }
        // pickmeup/passengers/<passenger_id>/chat
        else if ([topicParts count] == 4 && [[topicParts objectAtIndex:3] isEqualToString:PMUTopicChat])
        {
            [self handleChatMessage:json topic:topic payload:payload];
        }
        // pickmeup/drivers/<driver_id>
        else if ([topicParts count] == 3 && [[topicParts objectAtIndex:1] isEqualToString:PMUDriversTopicPrefix])
        {
            [self handleStatusMessage:json];
        }
    });
}

- (void)onMessageDelivered:(NSObject *)invocationContext
                 messageId:(int)messageId
{
    NSLog(@"%s:%d - invocationContext=%@ - Published message with msgId: %d", __func__, __LINE__, invocationContext, messageId);
}

@end
