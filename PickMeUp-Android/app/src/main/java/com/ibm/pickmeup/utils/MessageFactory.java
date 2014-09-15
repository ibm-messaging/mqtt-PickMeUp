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
import android.graphics.Bitmap;
import android.util.Base64;
import android.util.Log;

import com.ibm.pickmeup.PickMeUpApplication;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;

/**
 * MessageFactory is a utils class to construct messages in the format expected by the server
 */
public class MessageFactory {

    private final static String TAG = MessageFactory.class.getName();
    private static MessageFactory instance;
    private Context context;
    private SharedPreferences settings;
    private PickMeUpApplication app;

    private MessageFactory(Context context) {
        this.context = context;
        settings = context.getSharedPreferences(Constants.SETTINGS, 0);
        app = (PickMeUpApplication) context.getApplicationContext();
    }

    public static MessageFactory getInstance(Context context) {
        if (instance == null) {
            instance = new MessageFactory(context);
        }
        return instance;
    }

    /**
     * Method to create a connection message with the passenger's name and connection time
     *
     * @return msg string representation of the JSONObject
     */
    public String getConnectionMessage() {
        Log.d(TAG, ".getConnectionMessage() entered");
        JSONObject msg = new JSONObject();
        try {
            msg.put(Constants.NAME, getPassengerName());
            msg.put(Constants.CONNECTION_TIME, System.currentTimeMillis());
        } catch (JSONException e) {
            Log.d(TAG, ".getConnectionMessage() - Exception caught while generating a JSON object", e.getCause());
        }
        return msg.toString();
    }

    /**
     * Method to create a pairing message with the passenger's name, latitude and longitude
     *
     * @param lat Latitude value
     * @param lon Longitude value
     * @return msg string representation of the JSONObject
     */
    public String getPairingMessage(double lat, double lon) {
        Log.d(TAG, ".getPairingMessage() entered");
        JSONObject msg = new JSONObject();
        try {
            msg.put(Constants.NAME, getPassengerName());
            msg.put(Constants.LONGITUDE, lon);
            msg.put(Constants.LATITUDE, lat);
        } catch (JSONException e) {
            Log.d(TAG, ".getPairingMessage() - Exception caught while generating a JSON object", e.getCause());
        }
        return msg.toString();
    }

    /**
     * Method to create a message with the passenger's photo encoded as base64 string
     *
     * @return msg string representation of the JSONObject
     */
    public String getPassengerPhotoMessage() {
        Log.d(TAG, ".getPassengerPhotoMessage() entered");
        PickMeUpApplication app = (PickMeUpApplication) context.getApplicationContext();
        Bitmap passengerPhoto = app.getPassengerPhoto();
        ByteArrayOutputStream byteOutputStream = new ByteArrayOutputStream();
        passengerPhoto.compress(Bitmap.CompressFormat.PNG, 100, byteOutputStream);
        String passengerPhotoAsBase64String = Base64.encodeToString(byteOutputStream.toByteArray(), Base64.DEFAULT);

        JSONObject msg = new JSONObject();
        try {
            msg.put(Constants.URL, Constants.BASE64_PHOTO_PREFIX + passengerPhotoAsBase64String);
        } catch (JSONException e) {
            Log.d(TAG, ".getPassengerPhotoMessage() - Exception caught while generating a JSON object", e.getCause());
        }
        return msg.toString();
    }

    /**
     * Method to create a chat message
     *
     * @param format Message format - Text or Audio can be used
     * @param data   Message data as string
     * @return msg string representation of the JSONObject
     */
    public String getChatMessage(String format, String data) {
        Log.d(TAG, ".getChatMessage() entered");
        JSONObject msg = new JSONObject();
        try {
            msg.put(Constants.FORMAT, format);
            msg.put(Constants.DATA, data);
        } catch (JSONException e) {
            Log.d(TAG, ".getChatMessage() - Exception caught while generating a JSON object", e.getCause());
        }
        return msg.toString();
    }

    /**
     * Method to create the passenger's location message
     *
     * @param lat Latitude value
     * @param lon Longitude value
     * @return msg string representation of the JSONObject
     */
    public String getLocationMessage(double lat, double lon) {
        Log.d(TAG, ".getLocationMessage() entered");
        JSONObject msg = new JSONObject();
        try {
            msg.put(Constants.LONGITUDE, lon);
            msg.put(Constants.LATITUDE, lat);
        } catch (JSONException e) {
            Log.d(TAG, ".getLocationMessage() - Exception caught while generating a JSON object", e.getCause());
        }
        return msg.toString();
    }

    /**
     * Method to create the payment message
     *
     * @param cost   of the trip taken
     * @param tip    for the driver
     * @param rating for the driver
     * @return msg string representation of the JSONObject
     */
    public String getPaymentMessage(String cost, String tip, String rating) {
        Log.d(TAG, ".getPaymentMessage() entered");
        JSONObject msg = new JSONObject();
        try {
            msg.put(Constants.COST, cost);
            msg.put(Constants.TIP, tip);
            msg.put(Constants.RATING, rating);
            msg.put(Constants.DRIVER_ID, app.getDriverId());
            msg.put(Constants.PASSENGER_ID, getPassengerName());
        } catch (JSONException e) {
            Log.d(TAG, ".getPaymentMessage() - Exception caught while generating a JSON object", e.getCause());
        }
        return msg.toString();
    }

    /**
     * Helper method to get the passenger's name
     *
     * @return name as it is stored in the SharedPreferences
     */
    private String getPassengerName() {
        return settings.getString(Constants.SETTINGS_NAME, "");
    }
}
