/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
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