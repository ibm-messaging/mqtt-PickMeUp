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
#import "PMUDriver.h"

/** The PMUMapViewController class implements the map view of the application. */
@interface PMUMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

/** Add a PMUDriver annotation to the map. */
- (void)addDriver:(PMUDriver *)driver;
/** Remove a PMUDriver annotation from the map .
 * @param driver The driver to add to the map.
 */
- (void)removeDriver:(PMUDriver *)driver;
/** Get the PMUDriver annotation matching driverID.
 * @param driverID The ID of the driver to get. 
 */
- (PMUDriver *)getDriver:(NSString *)driverID;
/** Set the ETA label. 
 * @param estimateLabelText The new text to set the estimate label to. 
 */
- (void)setEstimateLabelText:(NSString *)estimateLabelText;

@end
