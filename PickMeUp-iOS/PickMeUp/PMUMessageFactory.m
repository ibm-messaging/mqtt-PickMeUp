/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
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
