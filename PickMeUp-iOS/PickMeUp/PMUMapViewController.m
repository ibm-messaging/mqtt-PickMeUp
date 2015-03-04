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
#import "PMUMapViewController.h"

@interface PMUMapViewController()

@property (strong, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *estimateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *driverImage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@end

@implementation PMUMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.mapController = self;
    }
    return self;
}

- (void)viewDidLoad
{
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    _mapView.scrollEnabled = YES;
    _mapView.zoomEnabled = YES;
    
    PMURequest *request = [PMURequest sharedRequest];
    PMUDriver *driver = [PMUDriver sharedDriver];
    
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (request.coordinate, 10.0*METERS_PER_MILE, 10.0*METERS_PER_MILE);
    [_mapView setRegion:region animated:NO];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    if (driver != nil)
    {
        [self addDriver:driver];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:34/255.0 green:51/255.0 blue:63/255.0 alpha:1.0];
    
    CGRect titleViewFrame = CGRectMake(0, 0, 160, 44);
    UIView* titleView = [[UILabel alloc] initWithFrame:titleViewFrame];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.autoresizesSubviews = YES;
    
    NSAttributedString *titleAttrString = [[NSAttributedString alloc] initWithString:@"PickMeUp" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:13/255.0 green:191/255.0 blue:153/255.0 alpha:1.0]}];
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setAttributedText:titleAttrString];
    
    CGRect topTitleFrame = CGRectMake(0, 2, 160, 44);
    UILabel *topTitleView = [[UILabel alloc] initWithFrame:topTitleFrame];
    topTitleView.attributedText = titleAttrString;
    topTitleView.textAlignment = NSTextAlignmentCenter;
    topTitleView.adjustsFontSizeToFitWidth = NO;
    [titleView addSubview:topTitleView];
    
    self.navigationItem.titleView = titleView;
    
    PMUDriver *driver = [PMUDriver sharedDriver];
    if (driver.name != nil)
    {
        self.driverNameLabel.text = driver.name;
    }
    if (driver.image != nil)
    {
        self.driverImage.image = driver.image;
        self.driverImage.layer.cornerRadius = 32;
        self.driverImage.layer.masksToBounds = YES;
        self.driverImage.layer.borderWidth = 1;
    }
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate calculateETA];
}

- (void)setEstimateLabelText:(NSString *)estimateLabelText
{
    self.estimateLabel.text = estimateLabelText;
}

- (void)addDriver:(PMUDriver *)driver
{
    PMUDriver *existingDriver = [self getDriver:[driver title]];
    if (existingDriver != nil)
    {
        [_mapView removeAnnotation:driver];
    }
    
    [_mapView addAnnotation:driver];
}

- (void)removeDriver:(PMUDriver *)driver
{
    [_mapView removeAnnotation:driver];
}

- (PMUDriver *)getDriver:(NSString *)driverID
{
    NSArray *annotations = [_mapView annotations];
    for (int index = 0; index < annotations.count; index++)
    {
        if ([[annotations[index] title] isEqualToString:driverID])
        {
            return annotations[index];
        }
    }
    
    return nil;
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    static NSString *identifier = @"myAnnotation";
    MKAnnotationView * annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        
        // If running app on iPad, leave car image full sized.
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            CGRect imageFrame = CGRectMake(annotationView.frame.origin.x-50, annotationView.frame.origin.y-100, 100, 100);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            imageView.image = [UIImage imageNamed:PMUCarImage];
            [annotationView addSubview:imageView];
        }
        // Otherwise, make the image smaller.
        else
        {
            CGRect imageFrame = CGRectMake(annotationView.frame.origin.x-15, annotationView.frame.origin.y-30, 30, 30);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            imageView.image = [UIImage imageNamed:PMUCarImage];
            [annotationView addSubview:imageView];
        }
    }
    else
    {
        annotationView.annotation = annotation;
    }
    return annotationView;
}

- (void)        mapView:(MKMapView *)mapView
didSelectAnnotationView:(MKAnnotationView *)view
{
}

-(void)           mapView:(MKMapView *)mapView
didDeselectAnnotationView:(MKAnnotationView *)view
{
}

- (void)      mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation
{
    PMUMessenger *messenger = [PMUMessenger sharedMessenger];
    
    _mapView.centerCoordinate = userLocation.location.coordinate;

    // Publish location updates whenever the user location changes
    NSString *payload = [PMUMessageFactory createLocationMessage:userLocation.coordinate.longitude latitude:userLocation.coordinate.latitude];

    [messenger publish:[PMUTopicFactory getPassengerLocationTopic] payload:payload qos:0 retained:YES];
}

# pragma mark Actions

/** Zoom in the map view.
 */
- (IBAction)zoomInPressed:(id)sender
{
    MKCoordinateRegion region;
    region.span.latitudeDelta = _mapView.region.span.latitudeDelta / 2;
    region.span.longitudeDelta = _mapView.region.span.longitudeDelta / 2;
    region.center.latitude = _mapView.region.center.latitude;
    region.center.longitude = _mapView.region.center.longitude;
    [_mapView setRegion:region];
}

/** Zoom out the map view.
 */
- (IBAction)zoomOutPressed:(id)sender
{
    MKCoordinateRegion region;
    region.span.latitudeDelta = _mapView.region.span.latitudeDelta * 2;
    region.span.longitudeDelta = _mapView.region.span.longitudeDelta * 2;
    region.center.latitude = _mapView.region.center.latitude;
    region.center.longitude = _mapView.region.center.longitude;
    [_mapView setRegion:region];
}

/** Return to the chat view.
 */
- (IBAction)backPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
