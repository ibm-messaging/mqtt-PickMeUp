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

#import "PMUDriver.h"
#import "PMUAppDelegate.h"

@implementation PMUDriver

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize name;
@synthesize image;

/** Initialize a PMUDriver instance 
 */
- (id)init
{
    if (self = [super init])
    {
        title = nil;
        subtitle = nil;
        name = nil;
        image = nil;
    }
    return self;
}

+ (id)sharedDriver
{
    static PMUDriver *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

+ (void)resetDriverProperties
{
    CLLocationCoordinate2D coord;
    coord.longitude = 0;
    coord.latitude = 0;
    PMUDriver *driver = [PMUDriver sharedDriver];
    [driver setTitle:nil];
    [driver setName:nil];
    [driver setImage:nil];
    [driver setCoordinate:coord];
}

- (void)setTitle:(NSString *)newTitle
{
    title = newTitle;
}

/** Set the coordinate of the PMUDriver object.
 */
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
}

@end
