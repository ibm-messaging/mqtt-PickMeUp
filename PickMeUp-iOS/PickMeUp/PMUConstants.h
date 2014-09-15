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

#define METERS_PER_MILE 1609.344

// server constants
extern NSString * const PMUServerIP;
int               const PMUServerPort;

// topics
extern NSString * const PMUPickMeUpTopic;
extern NSString * const PMUDriversTopicPrefix;
extern NSString * const PMUPassengersTopicPrefix;
extern NSString * const PMURequestTopic;
extern NSString * const PMUPaymentTopic;
extern NSString * const PMUTopicInbox;
extern NSString * const PMUTopicChat;
extern NSString * const PMUTopicPicture;
extern NSString * const PMUTopicLocation;

// inbox message types
extern NSString * const PMUTypeAccept;
extern NSString * const PMUTypeTripStart;
extern NSString * const PMUTypeTripEnd;
extern NSString * const PMUTypeTripProcessed;

// invocation context values
extern NSString * const PMUContextConnect;
extern NSString * const PMUContextDisconnect;
extern NSString * const PMUContextSubscribe;
extern NSString * const PMUContextUnsubscribe;
extern NSString * const PMUContextSend;

// image file names
extern NSString * const PMUMicrophoneImage;
extern NSString * const PMUCarImage;
extern NSString * const PMUStopImage;
extern NSString * const PMUBubbleDriverImage;
extern NSString * const PMUBubblePassengerImage;

// JSON fields
extern NSString * const PMUTypeField;
extern NSString * const PMUPassengerIDField;
extern NSString * const PMUDriverIDField;
extern NSString * const PMUConnectionTimeField;
extern NSString * const PMULongitudeField;
extern NSString * const PMULatitudeField;
extern NSString * const PMUNameField;
extern NSString * const PMUFormatField;
extern NSString * const PMUDataField;
extern NSString * const PMUURLField;
extern NSString * const PMUDistanceField;
extern NSString * const PMUTimeField;
extern NSString * const PMUCostField;

// Message content formats
extern NSString * const PMUTextFormat;
extern NSString * const PMUAudioFormat;
extern NSString * const PMUImageFormat;