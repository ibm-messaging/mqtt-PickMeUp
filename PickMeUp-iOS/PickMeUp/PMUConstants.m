/*******************************************************************************
 Licensed Materials - Property of IBM
 
 © Copyright IBM Corporation 2014. All Rights Reserved.
 
 This licensed material is sample code intended to aid the licensee in the development of software for the Apple iOS and OS X platforms . This sample code is  provided only for education purposes and any use of this sample code to develop software requires the licensee obtain and comply with the license terms for the appropriate Apple SDK (Developer or Enterprise edition).  Subject to the previous conditions, the licensee may use, copy, and modify the sample code in any form without payment to IBM for the purposes of developing software for the Apple iOS and OS X platforms.
 
 Notwithstanding anything to the contrary, IBM PROVIDES THE SAMPLE SOURCE CODE ON AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND ANY WARRANTY OR CONDITION OF NON-INFRINGEMENT. IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY OR ECONOMIC CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF THE SAMPLE SOURCE CODE. IBM SHALL NOT BE LIABLE FOR LOSS OF, OR DAMAGE TO, DATA, OR FOR LOST PROFITS, BUSINESS REVENUE, GOODWILL, OR ANTICIPATED SAVINGS. IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SAMPLE SOURCE CODE.
 
 
 Contributors:
 Mike Robertson, Bryan Boyd, Vladimir Kislicins, Joel Gauci, Nguyen Van Duy,
 Rahul Gupta, Vasfi Gucer
 *******************************************************************************/

#import "PMUConstants.h"

// server constants
NSString * const PMUServerIP = (NSString *)CFSTR("messagesight.demos.ibm.com");
int        const PMUServerPort = 1883;

// topic prefix
NSString * const PMUPickMeUpTopic = (NSString *)CFSTR("pickmeup");
NSString * const PMUDriversTopicPrefix = (NSString *)CFSTR("drivers");
NSString * const PMUPassengersTopicPrefix = (NSString *)CFSTR("passengers");
NSString * const PMURequestTopic = (NSString *)CFSTR("requests");
NSString * const PMUPaymentTopic = (NSString *)CFSTR("payments");
NSString * const PMUTopicInbox = (NSString *)CFSTR("inbox");
NSString * const PMUTopicChat = (NSString *)CFSTR("chat");
NSString * const PMUTopicPicture = (NSString *)CFSTR("picture");
NSString * const PMUTopicLocation = (NSString *)CFSTR("location");

// inbox message types
NSString * const PMUTypeAccept = (NSString *)CFSTR("accept");
NSString * const PMUTypeTripStart = (NSString *)CFSTR("tripStart");
NSString * const PMUTypeTripEnd = (NSString *)CFSTR("tripEnd");
NSString * const PMUTypeTripProcessed = (NSString *)CFSTR("tripProcessed");

// invocation context values
NSString * const PMUContextConnect = (NSString *)CFSTR("connect");
NSString * const PMUContextDisconnect = (NSString *)CFSTR("disconnect");
NSString * const PMUContextSubscribe = (NSString *)CFSTR("subscribe");
NSString * const PMUContextUnsubscribe = (NSString *)CFSTR("unsubscribe");
NSString * const PMUContextSend = (NSString *)CFSTR("send");

// image file names
NSString * const PMUMicrophoneImage = (NSString *)CFSTR("ic_action_microphone.png");
NSString * const PMUCarImage = (NSString *)CFSTR("ic_driver.png");
NSString * const PMUStopImage = (NSString *)CFSTR("ic_action_microphone_recording.png");
NSString * const PMUBubbleDriverImage = (NSString *)CFSTR("bubbleSomeone.png");
NSString * const PMUBubblePassengerImage = (NSString *)CFSTR("bubbleMine.png");

// JSON fields
NSString * const PMUPassengerIDField = (NSString *)CFSTR("passengerId");
NSString * const PMUDriverIDField = (NSString *)CFSTR("driverId");
NSString * const PMUFormatField = (NSString *)CFSTR("format");
NSString * const PMULongitudeField = (NSString *)CFSTR("lon");
NSString * const PMULatitudeField = (NSString *)CFSTR("lat");
NSString * const PMUConnectionTimeField = (NSString *)CFSTR("connectionTime");
NSString * const PMUNameField = (NSString *)CFSTR("name");
NSString * const PMUDataField = (NSString *)CFSTR("data");
NSString * const PMUURLField = (NSString *)CFSTR("url");
NSString * const PMUTypeField = (NSString *)CFSTR("type");
NSString * const PMUDistanceField = (NSString *)CFSTR("distance");
NSString * const PMUTimeField = (NSString *)CFSTR("time");
NSString * const PMUCostField = (NSString *)CFSTR("cost");

// Text message data format
NSString * const PMUTextFormat = (NSString *)CFSTR("text");
// Audio message data format
NSString * const PMUAudioFormat = (NSString *)CFSTR("data:audio/wav;base64");
// Image message data format
NSString * const PMUImageFormat = (NSString *)CFSTR("data:image/png;base64");