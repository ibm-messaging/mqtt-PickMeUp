/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
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
