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
 ******************************************************************************/
package com.ibm.pickmeup.utils;

/**
 * Constants utils class
 */
public class Constants {

    public final static String APP_ID = "com.ibm.pickmeup";

    public final static String SETTINGS_MQTT_SERVER = "messagesight.demos.ibm.com";
    public final static String SETTINGS_MQTT_PORT = "1883";
    public final static String SETTINGS_NAME = "name";
    public final static String SETTINGS = APP_ID+".Settings";

    public enum ActionStateStatus {
        CONNECTING, CONNECTED, DISCONNECTED, SUBSCRIBE, UNSIBSCRIBE, PUBLISH
    }

    public final static String PICK_ME_UP = "pickmeup/";
    public final static String PASSENGER_HEAD_PREFIX = PICK_ME_UP+"passengers/";
    public final static String REQUESTS_HEAD_PREFIX = PICK_ME_UP+"requests/";
    public final static String DRIVER_HEAD_PREFIX = PICK_ME_UP+"drivers/";
    public final static String INBOX = "inbox";
    public final static String PICTURE = "picture";
    public final static String PAYMENTS = "payments";

    public final static String NAME = "name";
    public final static String TRIP_START = "tripStart";
    public final static String TRIP_END = "tripEnd";
    public final static String TRIP_PROCESSED = "tripProcessed";
    public final static String COST = "cost";
    public final static String TIP = "tip";
    public final static String RATING = "rating";
    public final static String TIME = "time";
    public final static String DISTANCE= "distance";
    public final static String MILES= "mi";
    public final static String CONNECTION_TIME = "connectionTime";
    public final static String LONGITUDE = "lon";
    public final static String LATITUDE = "lat";
    public final static String LOCATION = "location";
    public final static String TYPE = "type";
    public final static String ACCEPT = "accept";
    public final static String DRIVER_ID = "driverId";
    public final static String PASSENGER_ID = "passengerId";
    public final static String URL = "url";
    public final static String CHAT = "chat";
    public final static String FORMAT = "format";
    public final static String DATA = "data";
    public final static String TEXT = "text";
    public final static String PAYMENT_TOTAL = "paymentTotal";
    public final static String DRIVER_PICTURE = "driverPicture";
    public final static String CONNECTIVITY_MESSAGE = "connectivityMessage";
    public final static String ROUTE_MESSAGE_TYPE = "routeMessageType";
    public final static String BASE64_PHOTO_PREFIX = "data:image/png;base64,";

    public final static String ACTION_INTENT_DRIVER_ACCEPTED = Constants.APP_ID + "." + "DRIVER_ACCEPTED";
    public final static String ACTION_INTENT_DRIVER_DETAILS_RECEIVED = Constants.APP_ID + "." + "DRIVER_DETAILS_RECEIVED";
    public final static String ACTION_INTENT_DRIVER_DETAILS_UPDATE = Constants.APP_ID + "." + "DRIVER_DETAILS_UPDATE";
    public final static String ACTION_INTENT_CHAT_MESSAGE_RECEIVED = Constants.APP_ID + "." + "CHAT_MESSAGE_RECEIVED";
    public final static String ACTION_INTENT_CHAT_MESSAGE_PROCESSED = Constants.APP_ID + "." + "CHAT_MESSAGE_PROCESSED";
    public final static String ACTION_INTENT_CONNECTIVITY_MESSAGE_RECEIVED = Constants.APP_ID + "." + "CONNECTIVITY_MESSAGE_RECEIVED";
    public final static String ACTION_INTENT_COORDINATES_CHANGED = Constants.APP_ID + "." + "COORDINATES_CHANGED";
    public final static String ACTION_INTENT_START_TRIP = Constants.APP_ID + "." + "START_TRIP";
    public final static String ACTION_INTENT_END_TRIP = Constants.APP_ID + "." + "END_TRIP";
    public final static String ACTION_INTENT_ROUTE_MESSAGE = Constants.APP_ID + "." + "ROUTER";
    public final static String ACTION_INTENT_PAYMENT_RECEIVED = Constants.APP_ID + "." + "PAYMENT_RECEIVED";

    public final static int LOCATION_MIN_TIME = 30000;
    public final static float LOCATION_MIN_DISTANCE = 5;
    public final static double DEFAULT_LATITUDE = 30.390361;
    public final static double DEFAULT_LONGITUDE = -97.7110845;

    public final static String AUDIO_FORMAT = ".3gp";
    public final static String VOICE = "data:audio/wav;base64";
    public final static String LOW_BEEP = "lowBeep";
    public final static String HIGH_BEEP = "highBeep";

    public final static int ERROR_BROKER_UNAVAILABLE = 3;
}
