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

/** Implements MKAnnotation Protocol. The PMUDriver object will
 * be used to generate the driver image on the PMUMapViewController.
 */
@interface PMUDriver : NSObject <MKAnnotation> {
    NSString *title;
    NSString *subtitle;
    CLLocationCoordinate2D coordinate;
}

/** The title for this driver. This is the driver ID. */
@property (readonly, nonatomic, copy) NSString *title;
/** This property is unused. */
@property (readonly, nonatomic, copy) NSString *subtitle;
/** The coordinate of the driver. */
@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
/** The name of the driver. */
@property (strong, nonatomic) NSString *name;
/** The picture of the driver. */
@property (strong, nonatomic) UIImage *image;

/** Returns the PMUDriver object. */
+ (id)sharedDriver;

/** Clear the properties of the PMUDriver object. */
+ (void)resetDriverProperties;

/** Set the driverId of the PMUDriver object. 
 * @param newTitle The new value for the title property.
 */
- (void)setTitle:(NSString *)newTitle;

@end
