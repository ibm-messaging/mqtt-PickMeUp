/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
 *******************************************************************************/

#import "PMUPairingViewController.h"
#import "PMUAppDelegate.h"

@interface PMUPairingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UILabel *driverNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *driverImage;

@end

@implementation PMUPairingViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        PMUAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.driverFoundController = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [self.navigationItem setHidesBackButton:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    PMUDriver *driver = [PMUDriver sharedDriver];
    if (driver.name != nil)
    {
        self.driverNameLabel.text = driver.name;
    }
    if (driver.image != nil)
    {
        self.driverImage.image = driver.image;
    }
    self.navigationController.navigationBar.hidden = YES;
}

- (void)setDriverName:(NSString *)name
{
    self.driverNameLabel.text = name;
}

- (void)setDriverPicture:(UIImage *)image
{
    self.driverImage.image = image;
    PMUDriver *driver = [PMUDriver sharedDriver];
    [driver setImage:image];
}

@end
