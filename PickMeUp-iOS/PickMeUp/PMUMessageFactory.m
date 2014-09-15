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

#import "PMUMessageFactory.h"
#import "PMUAppDelegate.h"

@implementation PMUMessageFactory

+ (NSString *)createPresenceMessage
{
    PMURequest *request = [PMURequest sharedRequest];
    NSNumber *timestamp = [NSNumber numberWithDouble:(1000 *[[NSDate date] timeIntervalSince1970])];
    NSString *messageString = [NSString stringWithFormat:@"{\"%@\":\"%@\",\"%@\":%d}", PMUNameField, request.name, PMUConnectionTimeField, [timestamp intValue]];
    return messageString;
}

+ (NSString *)createRequestMessage
{
    PMURequest *request = [PMURequest sharedRequest];
    NSString *messageString = [NSString stringWithFormat:@"{\"%@\":\"%@\",\"%@\":%f,\"%@\":%f}", PMUNameField, request.name, PMULongitudeField, request.coordinate.longitude, PMULatitudeField, request.coordinate.latitude];
    return messageString;
}

+ (NSString *)createChatMessage:(NSString *)format
                        payload:(NSString *)payload
{
    NSString *messageString = [NSString stringWithFormat:@"{\"%@\":\"%@\",\"%@\":\"%@\"}",
                               PMUFormatField, format, PMUDataField, payload];
    return messageString;
}

+ (NSString *)createPhotoMessage:(NSString *)payload
{
    NSString *messageString = [NSString stringWithFormat:@"{\"%@\":\"%@,%@\"}",
                               PMUURLField, PMUImageFormat, payload];
    return messageString;
}

+ (NSString *)createLocationMessage:(double)longitude
                           latitude:(double)latitude
{
    NSString *messageString = [NSString stringWithFormat:@"{\"lon\":%f,\"lat\":%f}", longitude, latitude];
    return messageString;
}

+ (NSString *)createPaymentMessage:(double)tipAmount
                            rating:(int)rating
{
    PMURequest *request = [PMURequest sharedRequest];
    NSString *messageString = [NSString stringWithFormat:@"{\"passengerId\":\"%@\",\"driverId\":\"%@\",\"cost\":%f,\"tip\":%f,\"rating\":%d}", [PMUTopicFactory getPassengerId], [PMUTopicFactory getDriverId], [request.cost doubleValue], tipAmount, rating];
    return messageString;
}

@end
