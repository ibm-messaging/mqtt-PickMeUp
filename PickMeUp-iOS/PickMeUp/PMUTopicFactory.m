/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
 *******************************************************************************/

#import "PMUTopicFactory.h"
#import "PMUAppDelegate.h"

@implementation PMUTopicFactory

+ (NSString *)getPassengerId
{
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.passengerId;
}

+ (NSString *)getDriverId
{
    PMUDriver *driver = [PMUDriver sharedDriver];
    return driver.title;
}

+ (NSString *)getPaymentTopic
{
    NSString *topic = [NSString stringWithFormat:@"%@/%@", PMUPickMeUpTopic, PMUPaymentTopic];
    return topic;
}

+ (NSString *)getRequestTopic
{
    NSString *topic = [NSString stringWithFormat:@"%@/%@/%@", PMUPickMeUpTopic, PMURequestTopic, [PMUTopicFactory getPassengerId]];
    return topic;
}

+ (NSString *)getPassengerTopLevelTopic
{
    NSString *topic = [NSString stringWithFormat:@"%@/%@/%@", PMUPickMeUpTopic, PMUPassengersTopicPrefix, [PMUTopicFactory getPassengerId]];
    return topic;
}

+ (NSString *)getPassengerInboxTopic
{
    NSString *topic = [NSString stringWithFormat:@"%@/%@/%@/%@", PMUPickMeUpTopic, PMUPassengersTopicPrefix, [PMUTopicFactory getPassengerId], PMUTopicInbox];
    return topic;
}

+ (NSString *)getPassengerChatTopic
{
    NSString *topic = [NSString stringWithFormat:@"%@/%@/%@/%@", PMUPickMeUpTopic, PMUPassengersTopicPrefix, [PMUTopicFactory getPassengerId], PMUTopicChat];
    return topic;
}

+ (NSString *)getPassengerPhotoTopic
{
    NSString *topic = [NSString stringWithFormat:@"%@/%@/%@/%@", PMUPickMeUpTopic, PMUPassengersTopicPrefix, [PMUTopicFactory getPassengerId], PMUTopicPicture];
    return topic;
}

+ (NSString *)getPassengerLocationTopic
{
    NSString *topic = [NSString stringWithFormat:@"%@/%@/%@/%@", PMUPickMeUpTopic, PMUPassengersTopicPrefix, [PMUTopicFactory getPassengerId], PMUTopicLocation];
    return topic;
}

+ (NSString *)getDriverTopLevelTopic
{
    NSString *topic = [NSString stringWithFormat:@"%@/%@/%@", PMUPickMeUpTopic, PMUDriversTopicPrefix, [PMUTopicFactory getDriverId]];
    return topic;
}

+ (NSString *)getDriverChatTopic
{
    NSString *topic = [NSString stringWithFormat:@"%@/%@/%@/%@", PMUPickMeUpTopic, PMUDriversTopicPrefix, [PMUTopicFactory getDriverId], PMUTopicChat];
    return topic;
}

+ (NSString *)getDriverPhotoTopic
{
    NSString *topic = [NSString stringWithFormat:@"%@/%@/%@/%@", PMUPickMeUpTopic, PMUDriversTopicPrefix, [PMUTopicFactory getDriverId], PMUTopicPicture];
    return topic;
}

+ (NSString *)getDriverLocationTopic
{
    NSString *topic = [NSString stringWithFormat:@"%@/%@/%@/%@", PMUPickMeUpTopic, PMUDriversTopicPrefix, [PMUTopicFactory getDriverId], PMUTopicLocation];
    return topic;
}

@end
