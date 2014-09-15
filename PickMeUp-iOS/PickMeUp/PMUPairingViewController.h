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

/** The PMUPairingViewController implements the driver found and trip started
 * views of the application. */
@interface PMUPairingViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/** Set the driver name label.
 * @param name The new name to set for the driver. 
 */
- (void)setDriverName:(NSString *)name;
/** Set the driver image.
 * @param image The new image to set for the driver. 
 */
- (void)setDriverPicture:(UIImage *)image;

@end
