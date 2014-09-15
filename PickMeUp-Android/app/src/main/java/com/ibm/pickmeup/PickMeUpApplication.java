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
package com.ibm.pickmeup;

import android.app.Application;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.util.Log;

import com.ibm.pickmeup.utils.Constants;

import java.io.File;

/**
 * PickMeUpApplication class is used to share global variables across Activities as well as setup
 * MQTT broker address and port number. This class gets executed before the main Activity
 */
public class PickMeUpApplication extends Application {

    private final static String TAG = PickMeUpApplication.class.getName();
    private String driverName;
    private String driverId;
    private Bitmap driverPhoto;
    private Bitmap passengerPhoto;
    private String currentRunningActivity;

    @Override
    public void onCreate() {
        Log.d(TAG, ".onCreate() entered");
        super.onCreate();
        SharedPreferences settings = getSharedPreferences(Constants.SETTINGS, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString(Constants.SETTINGS_MQTT_SERVER, "messagesight.demos.ibm.com");
        editor.putString(Constants.SETTINGS_MQTT_PORT, "1883");
        editor.commit();

        // cleanup old voice chat messages
        File chatDirectory = this.getExternalFilesDir(null);
        for (File file : chatDirectory.listFiles()) {
            if (file.getName().contains(Constants.CHAT)) {
                Log.d(TAG, ".onCreate() - Cleaning up old voice chat messages - "+file.getName());
                file.delete();
            }
        }
    }

    public String getDriverName() {
        return this.driverName;
    }

    public void setDriverName(String name) {
        this.driverName = name;
    }

    public Bitmap getDriverPhoto() {
        return this.driverPhoto;
    }

    public void setDriverPhoto(Bitmap photo) {
        this.driverPhoto = photo;
    }

    public Bitmap getPassengerPhoto() {
        return this.passengerPhoto;
    }

    public void setPassengerPhoto(Bitmap photo) {
        this.passengerPhoto = photo;
    }

    public String getDriverId() { return this.driverId; }

    public void setDriverId(String driverId) {
        this.driverId = driverId;
    }

    public String getCurrentRunningActivity() {
        return currentRunningActivity;
    }

    public void setCurrentRunningActivity(String currentRunningActivity) {
        this.currentRunningActivity = currentRunningActivity;
    }

    public void setCurrentRunningActivityEmpty() {
        this.currentRunningActivity = null;
    }

}
