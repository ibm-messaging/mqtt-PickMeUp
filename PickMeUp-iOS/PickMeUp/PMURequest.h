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
#import <MapKit/MapKit.h>

/** PMURequest stores the passenger and trip data for the application. */
@interface PMURequest : NSObject

/** The coordinate of the passenger. */
@property (nonatomic) CLLocationCoordinate2D coordinate;
/** The name of the passenger. */
@property (strong, nonatomic) NSString *name;
/** The total distance of the trip. */
@property (strong, nonatomic) NSNumber *distance;
/** The total time of the trip. */
@property (strong, nonatomic) NSNumber *time;
/** The total cost of the trip. */
@property (strong, nonatomic) NSNumber *cost;
/** The picture of the passenger. */
@property (strong, nonatomic) UIImage *image;

/** Returns the PMURequest object. */
+ (id)sharedRequest;

/** Clear the properties of the PMURequest object. */
+ (void)resetRequestProperties;

@end
