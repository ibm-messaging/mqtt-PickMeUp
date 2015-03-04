/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
 *******************************************************************************/

#import <CommonCrypto/CommonDigest.h>
#import "PMURequestViewController.h"
#import "PMUAppDelegate.h"

@interface PMURequestViewController()
    
@property (nonatomic,weak) IBOutlet UIButton *submitButton;
@property (nonatomic,weak) IBOutlet UITextField *nameField;

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLLocation *location;

// Send picture view
@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
@property (strong, nonatomic) UIImagePickerController *imgPicker;
@property (strong, nonatomic) NSString *imageString;

@end

@implementation PMURequestViewController

@synthesize locationManager;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.requestController = self;
    }
    return self;
}

/** Initialize the CLLocationManager so that the application
 * is able to send the correct coordinates with its request.
 */
- (void)viewDidLoad
{
    [self.nameField setDelegate:self];
    
    // Create the location manager
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    
    locationManager.pausesLocationUpdatesAutomatically = YES;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    locationManager.distanceFilter = 500; // meters
    
    [locationManager startUpdatingLocation];
    
    // Configure imgPicker
    self.imageString = nil;
    
    // Initiate and prepare the image picker controller
    self.imgPicker = [[UIImagePickerController alloc] init];
    self.imgPicker.allowsEditing = YES;
    self.imgPicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // Only set camera if we have a camera available
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)sendPictureMessage
{
    if (self.imageString == nil)
    {
        return;
    }

    NSString *payload = [PMUMessageFactory createPhotoMessage:self.imageString];
    
    PMUMessenger *messenger = [PMUMessenger sharedMessenger];
    [messenger publish:[PMUTopicFactory getPassengerPhotoTopic] payload:payload qos:0 retained:YES];
}

#pragma mark Actions

/** When the submit button is pressed, make sure that the name field
 * has a value. If it does not, display an error.
 * If it does have a value, then connect to the MQTT broker.
 */
- (IBAction)submitPressed:(id)sender
{
    
    /* TODO: Use user location */
    PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CLLocationCoordinate2D coord = _location.coordinate;
    
    if ([self.nameField.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Name must be specified" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    PMURequest *request = [PMURequest sharedRequest];
    [request setCoordinate:coord];
    [request setName:self.nameField.text];
    
    if (request != nil)
    {
        // Max MQTT client length in 3.1 is 23 characters
        if (self.nameField.text.length > 23)
        {
            [appDelegate setPassengerId:[self.nameField.text substringToIndex:23]];
        } else
        {
            [appDelegate setPassengerId:self.nameField.text];
        }
        
        PMUMessenger *messenger = [PMUMessenger sharedMessenger];
        [messenger connectWithHost:PMUServerIP port:PMUServerPort clientId:[PMUTopicFactory getPassengerId]];
    }
}

/** The user pressed the picture button. If the camera is available, switch to
 * the camera view. Otherwise, go to the photo library.
 */
- (IBAction)pictureButtonPressed:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // Only set camera if we have a camera available
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imgPicker animated:YES completion:nil];
    }
    else {
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imgPicker animated:YES completion:nil];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)text
{
    [text resignFirstResponder];
    return YES;
}

#pragma mark CLLocationManagerDelegate

/** Update the user location. */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    _location = [locations lastObject];
}

#pragma mark imgPicker callback

/** The user selected an image. Take the edited image and put it into
 * a 256x256 frame and set the image on the request.
 */
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([info objectForKey:UIImagePickerControllerOriginalImage] != nil)
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        CGRect rect = CGRectMake(0, 0, 256, 256);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.image = image;
        image = imageView.image;
        NSData *imgData = UIImageJPEGRepresentation(image, 0.1f);
        [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
        self.imageString = [imgData base64EncodedStringWithOptions:0];
        
        [self.pictureButton setBackgroundImage:image forState:UIControlStateNormal];
        PMURequest *request = [PMURequest sharedRequest];
        [request setImage:image];
    }
}

@end
