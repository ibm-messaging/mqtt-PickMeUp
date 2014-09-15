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
