/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
 *******************************************************************************/

#import "PMUAppDelegate.h"

@implementation PMUAppDelegate

/** Returns when the application has finished launching.
 * Loads the appropriate storyboard for the application.
 */
- (BOOL)          application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadStoryboard];
    
    self.messageCache = [[NSMutableArray alloc] init];
    self.applicationStage = 0;
    return YES;
}

- (void)switchToAccepted
{
    if (self.applicationStage == 0)
    {
        self.applicationStage = 1;
        [self.requestController performSegueWithIdentifier:PMUTypeAccept sender:self.requestController];
    }
}

- (void)switchToTripStarted
{
    if (self.applicationStage < 2)
    {
        self.applicationStage = 2;
        [self.requestController performSegueWithIdentifier:PMUTypeTripStart sender:self.requestController];
    }
}

- (void)switchToTripEnded
{
    if (self.applicationStage < 3)
    {
        self.applicationStage = 3;
        [self.requestController performSegueWithIdentifier:PMUTypeTripEnd sender:self.requestController];
    }
}

- (void)switchToTripProcessed
{
    if (self.applicationStage < 4)
    {
        self.applicationStage = 4;
        [self.requestController performSegueWithIdentifier:PMUTypeTripProcessed sender:self.requestController];
    }
}

- (void)switchToRequest
{
    self.applicationStage = 0;
    [self.requestController.navigationController popToRootViewControllerAnimated:YES];
}

- (void)subscribeToInbox
{
    PMUMessenger *messenger = [PMUMessenger sharedMessenger];
    [messenger subscribe:[PMUTopicFactory getPassengerInboxTopic] qos:2];
}

- (void)sendPresenceAndRequest
{
    PMUMessenger *messenger = [PMUMessenger sharedMessenger];
    PMURequest *request = [PMURequest sharedRequest];
    
    // publish presence message to pickmeup/passengers/<passengerId>
    // { "name": "Bryan", "connectionTime": <time> }
    NSString *presenceMessage = [PMUMessageFactory createPresenceMessage];
    [messenger publish:[PMUTopicFactory getPassengerTopLevelTopic] payload:presenceMessage qos:0 retained:YES];
    
    // publish request message to pickmeup/requests
    // { "name": "Bryan", "lon": -97.123, "lat": 34.123 }
    NSString *requestMessage = [PMUMessageFactory createRequestMessage];
    [messenger publish:[PMUTopicFactory getRequestTopic] payload:requestMessage qos:1 retained:YES];
    
    // publish presence message to pickmeup/passengers/<passengerId>/location
    // { "lon": -97.123, "lat": 34.123 }
    NSString *locationMessage = [PMUMessageFactory createLocationMessage:request.coordinate.longitude latitude:request.coordinate.latitude];
    [messenger publish:[PMUTopicFactory getPassengerLocationTopic] payload:locationMessage qos:0 retained:YES];
    
    [self.requestController sendPictureMessage];
    
    [self.requestController performSegueWithIdentifier:@"submitRequest" sender:self.requestController];
}

- (void)createPairSubscriptions:(NSDictionary *)json
{
    NSLog(@"[PickMeUp] A driver has accepted the request");
    
    NSString *driverId = [json objectForKey:PMUDriverIDField];
    NSNumber *lon = [json objectForKey:PMULongitudeField];
    NSNumber *lat = [json objectForKey:PMULatitudeField];
    PMUMessenger *messenger = [PMUMessenger sharedMessenger];
    
    CLLocationCoordinate2D coord;
    coord.latitude = [lat doubleValue];
    coord.longitude = [lon doubleValue];
    
    PMUDriver *driver = [PMUDriver sharedDriver];
    [self updateDriver:coord];
    [driver setTitle:driverId];
    
    [self.mapController addDriver:driver];
    
    [messenger subscribe:[PMUTopicFactory getDriverTopLevelTopic] qos:0];
    [messenger subscribe:[PMUTopicFactory getDriverPhotoTopic] qos:0];
    [messenger subscribe:[PMUTopicFactory getDriverLocationTopic] qos:0];
    [messenger subscribe:[PMUTopicFactory getPassengerChatTopic] qos:0];
    
    [self switchToAccepted];

}

- (void)deletePairSubscriptions:(NSDictionary *)json
{
    // json field distance, time, cost
    NSNumber *distance = [json objectForKey:PMUDistanceField];
    NSNumber *time = [json objectForKey:PMUTimeField];
    NSNumber *cost = [json objectForKey:PMUCostField];
    PMUMessenger *messenger = [PMUMessenger sharedMessenger];
    PMURequest *request = [PMURequest sharedRequest];
    
    [messenger unsubscribe:[PMUTopicFactory getDriverTopLevelTopic]];
    [messenger unsubscribe:[PMUTopicFactory getDriverPhotoTopic]];
    [messenger unsubscribe:[PMUTopicFactory getDriverLocationTopic]];
    [messenger unsubscribe:[PMUTopicFactory getPassengerChatTopic]];
    
    request.distance = distance;
    request.time = time;
    request.cost = cost;
    
    [self switchToTripEnded];
}

- (void)clearRetainedAndDisconnect
{
    PMUMessenger *messenger = [PMUMessenger sharedMessenger];
    
    // clean up retained messages
    NSString *emptyMessage = @"";
    
    // 1. pickmeup/passengers/<passengerId>
    [messenger publish:[PMUTopicFactory getPassengerTopLevelTopic] payload:emptyMessage qos:0 retained:YES];
    // 2. pickmeup/passengers/<passengerId>/location
    [messenger publish:[PMUTopicFactory getPassengerLocationTopic] payload:emptyMessage qos:0 retained:YES];
    // 3. pickmeup/passengers/<passengerId>/picture
    [messenger publish:[PMUTopicFactory getPassengerPhotoTopic] payload:emptyMessage qos:0 retained:YES];
    // 4. pickmeup/requests/<passengerId>
    [messenger publish:[PMUTopicFactory getRequestTopic] payload:emptyMessage qos:0 retained:YES];
    
    [messenger disconnect];
}

- (void)resetApplication
{
    PMUMessenger *messenger = [PMUMessenger sharedMessenger];
    if (messenger.client.isConnected == YES)
    {
        [self clearRetainedAndDisconnect];
    }
    
    // Clear the message cache
    [self.messageCache removeAllObjects];
    
    // Clear the PMUDriver singleton properties
    [PMUDriver resetDriverProperties];
    
    // Clear the PMURequest singleton properties
    [PMURequest resetRequestProperties];
    
    [self switchToRequest];
}

- (void)updateDriver:(CLLocationCoordinate2D)location
{
    PMUDriver *driver = [PMUDriver sharedDriver];
    [driver setCoordinate:location];
    [self calculateETA];
}

- (void)calculateETA
{
    PMUDriver *driver = [PMUDriver sharedDriver];
    PMURequest *request = [PMURequest sharedRequest];
    
    CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:request.coordinate.latitude longitude:request.coordinate.longitude];
    CLLocation *driverLocation = [[CLLocation alloc] initWithLatitude:driver.coordinate.latitude longitude:driver.coordinate.longitude];
    
    CLLocationDistance distance = [myLocation distanceFromLocation:driverLocation];
    double miles = distance / METERS_PER_MILE;
    double eta = miles / 0.33;
    [self.mapController setEstimateLabelText:[NSString stringWithFormat:@"%.02f minutes", eta]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

/** Load the appropriate storyboard file based on device type.
 *   iPad         - iPad.storyboard
 *   3.5in iPhone - iPhone.storyboard
 *   4.0in iPhone - Main.storyboard
 */
- (void)loadStoryboard
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIStoryboard *storyboard = nil;
    if (screenSize.height == 568)
    {
        // Main.storyboard - 4in iPhone
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        // iPad.storyboard - iPad
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    else
    {
        // iPhone.storyboard - 3.5in iPhone
        storyboard = [UIStoryboard storyboardWithName:@"Secondary_iPhone" bundle:nil];
    }
    
    UIViewController *view = [storyboard instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = view;
    self.chatController = [self.chatController init];
    [self.window makeKeyAndVisible];
}

@end
