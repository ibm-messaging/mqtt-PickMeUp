#Set up the PickMeUp Android project

##Prerequisites
The following are the prerequisites for running the PickMeUp Android application:

* PickMeUp Android application requires an Android device with Android 4.1 Jelly Bean (API level 16) or higher to run.
* Running PickMeUp on an emulator is not advised as PickMeUp is using Google Play Services and Location Services. Using an emulator might cause the application to run with reduced functionality.
* The application has been tested using Google Nexus 4, Google Nexus 7 and Samsung Galaxy S4. Using a smaller display or lower screen resolution is not recommended.
* Google Account and Google Maps Android API v2 key is required to build the application.
* Android SDK toolkit is required to build PickMeUp application. Stand-alone SDK tools as well as Eclipse or Android Studio bundle can be used.
* PickMeUp source code includes a Gradle build file which can be run using Gradle command line tools, Android Studio IDE or using Eclipse with the Gradle plugin.

##Registering for Google Maps API
Opening a Google account and registering for Google Maps API is free of charge. Any Google account can be used to obtain the key for debug and development purposes.

**Note:** Before building the PickMeUp application, a Google Maps API key is required. To get a Google Maps API key simply follow this link and press *Create*:

https://console.developers.google.com/flows/enableapi?apiid=maps_android_backend&keyType=CLIENT_SIDE_ANDROID&r=9F:22:30:50:6D:43:4D:E7:FB:98:79:76:DC:67:E1:1B:CF:9A:01:10%3Bcom.ibm.pickmeup

To add the credentials to an existing key the following line can be used: 

9F:22:30:50:6D:43:4D:E7:FB:98:79:76:DC:67:E1:1B:CF:9A:01:10;com.ibm.pickmeup

Once the key is generated, replace the google_maps_key entry with the key inside the following file:
<workspace>/PickMeUp/app/src/debug/res/values/google_maps_api.xml

The key should start with *AIza*.

##Android SDK Packages
The following SDK packages are required to build the PickMeUp application:
* Android 4.4.2 (API 19) - SDK Platform
* Google Repository
* Android Support Repository
* Android SDK Build-tools 19.1