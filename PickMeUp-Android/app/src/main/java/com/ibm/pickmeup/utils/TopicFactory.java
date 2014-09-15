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

import android.content.Context;
import android.content.SharedPreferences;

import com.ibm.pickmeup.PickMeUpApplication;

/**
 * TopicFactory is a utils class that generates topic strings according to the Constants
 */
public class TopicFactory {

    private static TopicFactory instance;
    private SharedPreferences settings;
    private PickMeUpApplication app;

    public static TopicFactory getInstance(Context context) {
        if (instance == null) {
            instance = new TopicFactory(context);
        }
        return instance;
    }

    private TopicFactory(Context context) {
        settings = context.getSharedPreferences(Constants.SETTINGS, 0);
        app = (PickMeUpApplication) context.getApplicationContext();
    }

    public String getPassengerPhotoTopic() {
        return Constants.PASSENGER_HEAD_PREFIX+getPassengerId()+"/"+Constants.PICTURE;
    }

    public String getPassengerInboxTopic() {
        return Constants.PASSENGER_HEAD_PREFIX+getPassengerId()+"/"+Constants.INBOX;
    }

    public String getPassengerTopLevelTopic() {
        return Constants.PASSENGER_HEAD_PREFIX+getPassengerId();
    }

    public String getPassengerChatTopic() {
        return Constants.PASSENGER_HEAD_PREFIX + getPassengerId() + "/" + Constants.CHAT;
    }

    public String getPassengerLocationTopic() {
        return Constants.PASSENGER_HEAD_PREFIX + getPassengerId() + "/" + Constants.LOCATION;
    }

    public String getPassengerPaymentTopic() {
        return Constants.PICK_ME_UP + Constants.PAYMENTS;
    }

    public String getParingTopic() {
        return Constants.REQUESTS_HEAD_PREFIX +getPassengerId();
    }

    public String getDriverTopLevelTopic() {
        return Constants.DRIVER_HEAD_PREFIX + getDriverId();
    }

    public String getDriverPhotoTopic() {
        return Constants.DRIVER_HEAD_PREFIX + getDriverId() + "/" + Constants.PICTURE;
    }

    public String getDriverChatTopic() {
        return Constants.DRIVER_HEAD_PREFIX + getDriverId() + "/" + Constants.CHAT;
    }

    public String getDriverLocationTopic() {
        return Constants.DRIVER_HEAD_PREFIX + getDriverId() + "/" + Constants.LOCATION;
    }

    private String getDriverId() {
       return app.getDriverId();
    }

    private String getPassengerId() {
        return settings.getString(Constants.SETTINGS_NAME, "");
    }
}
