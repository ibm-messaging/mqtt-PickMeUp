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
