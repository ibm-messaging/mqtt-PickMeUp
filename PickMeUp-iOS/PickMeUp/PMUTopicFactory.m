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
