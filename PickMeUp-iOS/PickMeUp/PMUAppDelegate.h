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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "PMUDriver.h"
#import "PMUMessenger.h"
#import "PMURequest.h"
#import "PMUConstants.h"
#import "PMUTopicFactory.h"
#import "PMUMessageFactory.h"

#import "PMURequestViewController.h"
#import "PMUSpinnerViewController.h"
#import "PMUPairingViewController.h"
#import "PMUChatViewController.h"
#import "PMUMapViewController.h"
#import "PMUFinalizeViewController.h"

/** 
 * @mainpage PickMeUp iOS Passenger Application
 *
 * @brief PickMeUp is a sample ride sharing service powered by MQTT.<br/>
 */

/** The PMUAppDelegate class implements the UIApplicationDelegate protocol.
 */
@interface PMUAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PMURequestViewController *requestController;
@property (strong, nonatomic) PMUSpinnerViewController *spinnerController;
@property (strong, nonatomic) PMUPairingViewController *driverFoundController;
@property (strong, nonatomic) PMUChatViewController *chatController;
@property (strong, nonatomic) PMUMapViewController *mapController;
@property (strong, nonatomic) PMUFinalizeViewController *finalizeController;

/** The array of PMUMessage objects for the chat table. */
@property (strong, nonatomic) NSMutableArray *messageCache;

@property (strong, nonatomic) NSString *passengerId;

/** Integer value to maintain the current stage of the application.
 * This is used to prevent going backwards in application state.
 * For example, if the driver and passenger are already at the same location
 * when the driver accepts the passenger, then its possible for the tripStarted
 * message to arrive before the accept message. This would cause the view to change to
 * driver arrived and then to driver found, which confuses the navigation controller.
 * 0 - Connected stage
 * 1 - Pairing stage
 * 2 - Approaching stage
 * 3 - Riding stage
 * 4 - Payment stage
 */
@property (nonatomic) int applicationStage;

/** Switch to the pairingComplete storyboard view. */
- (void)switchToAccepted;
/** Switch to the driverArrived storyboard view. */
- (void)switchToTripStarted;
/** Switch to the submitPayment storyboard view. */
- (void)switchToTripEnded;
/** Switch to the paymentProcessed storyboard view. */
- (void)switchToTripProcessed;
/** Switch to the request storyboard view. */
- (void)switchToRequest;

/** Create the passenger inbox subscription. */
- (void)subscribeToInbox;
/** Send the presence and request MQTT messages. */
- (void)sendPresenceAndRequest;
/** Create subscriptions for paired passenger and driver.
 * @param json Dictionary containing the driver ID to pair with.
 */
- (void)createPairSubscriptions:(NSDictionary *)json;
/** Delete subscriptions for paired passenger and driver.
 * @param json Dictionary containing the ride information.
 */
- (void)deletePairSubscriptions:(NSDictionary *)json;
/** Clear retained messages and disconnect from the MQTT broker. */
- (void)clearRetainedAndDisconnect;
/** Reset the application back to initial view controller and state. */
- (void)resetApplication;

/** Update the location of the driver map annotation. 
 * @param location The location of the driver. 
 */
- (void)updateDriver:(CLLocationCoordinate2D)location;
/** Calculate the estimated time of arrival for the driver. 
 * Driver assumed to be going 20mph or 0.33 miles per minute.
 * CLLocationDistance is in meters. Meters per mile is 1609.34.
 * ETA is (distance / 1609.34) / 0.33.
 */
- (void)calculateETA;

@end
