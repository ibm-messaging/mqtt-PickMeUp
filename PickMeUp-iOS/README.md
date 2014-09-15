PickMeUp iOS Application
========================

PickMeUp-iOS provides a native iOS implementation of the PickMeUp passenger application.

The application makes use of the iOS MQTT Objective-C client library which is
delivered as part of the IBM WebSphere MQ Client Pack available here:
  https://www.ibm.com/developerworks/community/blogs/c565c720-fe84-4f63-873f-607d87787327/entry/download?lang=en
  (Download Mobile & M2M Client Pack)
  
Class Overview
--------------

main.m: 
    Launches the application

PMUAppDelegate.h / PMUAppDelegate.m: 
    UIApplicationDelegate

PMUCallbacks.h / PMUCallbacks.m:
    Implementation for iOS MQTT client callback protocols

PMUConstants.h / PMUConstants.m:
    Define constants used throughout the application

PMUDriver.h / PMUDriver.m:
    Object to store driver related properties

PMUMessage.h / PMUMessage.m:
    Object to store individual chat message properties

PMUMessenger.h / PMUMessenger.m:
    Wrapper around MqttClient
    
PMUTopicFactory.h / PMUTopicFactory.m:
    Functions for returning MQTT topic strings
    
PMUMessageFactory.h / PMUMessageFactory.m:
    Functions for returning JSON formatted message strings

PMURequest.h / PMURequest.m:
    Object to store passenger and ride related properties

PMUChatViewController.h / PMUChatViewController.m:
    View controller for chatting

PMUFinalizeViewController.h / PMUFinalizeViewController.m:
    View controller for paying

PMUMapViewController.h / PMUMapViewController.m:
    View controller for map

PMUMessageTableView.h / PMUMessageTableView.m:
    View for chat table

PMUMessageTableViewDataSource.h:
    Data source protocol for chat table

PMUPairingViewController.h / PMUPairingViewController.m:
    View controller for pairing passenger with driver

PMURequestViewController.h / PMURequestViewController.m:
    View controller for submitting passenger request

PMUSpinnerViewController.h / PMUSpinnerViewController.m:
    View controller for spinner waiting for accept request

Main_iPad.storyboard:
    Storyboard for iPad

Main_iPhone.storyboard:
    Storyboard for 4inch iPhone

Secondary_iPhone.storyboard:
    Storyboard for 3.5inch iPhone
