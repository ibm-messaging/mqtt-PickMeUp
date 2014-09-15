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

#import "PMURequest.h"

@implementation PMURequest

/** Initialize a PMURequest instance. */
- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.name = nil;
        self.distance = nil;
        self.cost = nil;
        self.time = nil;
        self.image = nil;
    }
    return self;
}

+ (id)sharedRequest
{
    static PMURequest *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

+ (void)resetRequestProperties
{
    CLLocationCoordinate2D coord;
    coord.longitude = 0;
    coord.latitude = 0;
    PMURequest *request = [PMURequest sharedRequest];
    [request setName:nil];
    [request setTime:0];
    [request setCost:0];
    [request setDistance:0];
    [request setImage:nil];
    [request setCoordinate:coord];
}

@end
