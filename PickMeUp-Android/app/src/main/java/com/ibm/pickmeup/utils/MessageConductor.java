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
import android.content.Intent;
import android.util.Base64;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;


/**
 * MessageConductor is a Utils method to orchestrate the data flow coming from the MqttHandler.
 * This helper class will use the topic and payload data to construct an intent and decide which
 * action should be used when broadcasting it.
 */
public class MessageConductor {

    private final static String TAG = MessageConductor.class.getName();
    private static MessageConductor instance;
    private Context context;
    private long previousCoordinatesReceivedTime;

    private MessageConductor(Context context) {
        this.context = context;
        this.previousCoordinatesReceivedTime = System.currentTimeMillis();
    }

    public static MessageConductor getInstance(Context context) {
        if (instance == null) {
            instance = new MessageConductor(context);
        }
        return instance;
    }

    /**
     * Steer the message according to the rules related to the message payload and topic
     *
     * @param payload as a String
     * @param topic   as a String
     * @throws JSONException
     */
    public void steerMessage(String payload, String topic) throws JSONException {
        Log.d(TAG, ".steerMessage() entered");

        // create a JSONObject from the payload string
        JSONObject jsonPayload = new JSONObject(payload);

        if (jsonPayload.has(Constants.TYPE) &&
                jsonPayload.has(Constants.DRIVER_ID) &&
                jsonPayload.get(Constants.TYPE).equals(Constants.ACCEPT)) {

            // pairing message - get the driverId and send it to the router
            String driverId = jsonPayload.getString(Constants.DRIVER_ID);
            Intent actionIntent = new Intent(Constants.ACTION_INTENT_ROUTE_MESSAGE);
            actionIntent.putExtra(Constants.ROUTE_MESSAGE_TYPE, Constants.ACTION_INTENT_DRIVER_ACCEPTED);
            actionIntent.putExtra(Constants.DRIVER_ID, driverId);
            context.sendBroadcast(actionIntent);
        } else if (topic.contains(Constants.PICTURE) &&
                jsonPayload.has(Constants.URL)) {

            // driver picture message - get the driverPicture as bytes array and send it to the router
            String urlStr = jsonPayload.getString(Constants.URL);
            byte[] decodedPictureAsBytes = Base64.decode(urlStr.substring(urlStr.indexOf(",")), Base64.DEFAULT);
            Intent actionIntent = new Intent(Constants.ACTION_INTENT_ROUTE_MESSAGE);
            actionIntent.putExtra(Constants.ROUTE_MESSAGE_TYPE, Constants.ACTION_INTENT_DRIVER_DETAILS_RECEIVED);
            actionIntent.putExtra(Constants.DRIVER_PICTURE, decodedPictureAsBytes);
            context.sendBroadcast(actionIntent);
        } else if (topic.contains(Constants.DRIVER_HEAD_PREFIX) &&
                jsonPayload.has(Constants.NAME) &&
                jsonPayload.has(Constants.CONNECTION_TIME)) {

            // driver name message - get the name and send it to the router
            String driverName = jsonPayload.getString(Constants.NAME);
            Intent actionIntent = new Intent(Constants.ACTION_INTENT_ROUTE_MESSAGE);
            actionIntent.putExtra(Constants.ROUTE_MESSAGE_TYPE, Constants.ACTION_INTENT_DRIVER_DETAILS_RECEIVED);
            actionIntent.putExtra(Constants.NAME, driverName);
            context.sendBroadcast(actionIntent);
        } else if (topic.equals(TopicFactory.getInstance(context).getPassengerChatTopic()) &&
                jsonPayload.has(Constants.FORMAT) &&
                jsonPayload.has(Constants.DATA)) {

            // chat message - get the format and data and send it to the router
            Intent actionIntent = new Intent(Constants.ACTION_INTENT_ROUTE_MESSAGE);
            actionIntent.putExtra(Constants.ROUTE_MESSAGE_TYPE, Constants.ACTION_INTENT_CHAT_MESSAGE_RECEIVED);
            String format = jsonPayload.getString(Constants.FORMAT);
            String data = jsonPayload.getString(Constants.DATA);
            actionIntent.putExtra(Constants.DATA, data);
            actionIntent.putExtra(Constants.FORMAT, format);
            context.sendBroadcast(actionIntent);
        } else if (topic.equals(TopicFactory.getInstance(context).getDriverLocationTopic()) &&
                jsonPayload.has(Constants.LATITUDE) &&
                jsonPayload.has(Constants.LONGITUDE)) {

            // driver location message - send it directly to the map
            // check for previousCoordinatesReceivedTime to throttle messages within 100 milliseconds
            if (System.currentTimeMillis() - previousCoordinatesReceivedTime > 100) {
                Intent actionIntent = new Intent(Constants.ACTION_INTENT_COORDINATES_CHANGED);
                float lon = Float.parseFloat(jsonPayload.getString(Constants.LONGITUDE));
                float lat = Float.parseFloat(jsonPayload.getString(Constants.LATITUDE));
                actionIntent.putExtra(Constants.LONGITUDE, lon);
                actionIntent.putExtra(Constants.LATITUDE, lat);
                context.sendBroadcast(actionIntent);
                previousCoordinatesReceivedTime = System.currentTimeMillis();
            }
        } else if (topic.equals(TopicFactory.getInstance(context).getPassengerInboxTopic()) &&
                jsonPayload.has(Constants.TYPE)) {
            if (jsonPayload.get(Constants.TYPE).equals(Constants.TRIP_START)) {

                // trip started message - send it to the router
                Intent actionIntent = new Intent(Constants.ACTION_INTENT_ROUTE_MESSAGE);
                actionIntent.putExtra(Constants.ROUTE_MESSAGE_TYPE, Constants.ACTION_INTENT_START_TRIP);
                context.sendBroadcast(actionIntent);
            } else if (jsonPayload.get(Constants.TYPE).equals(Constants.TRIP_END) &&
                    jsonPayload.has(Constants.TIME) &&
                    jsonPayload.has(Constants.COST) &&
                    jsonPayload.has(Constants.DISTANCE)) {

                // trip ended message - collect time, distance, cost and send to the router
                Intent actionIntent = new Intent(Constants.ACTION_INTENT_ROUTE_MESSAGE);
                actionIntent.putExtra(Constants.ROUTE_MESSAGE_TYPE, Constants.ACTION_INTENT_END_TRIP);
                String time = jsonPayload.getString(Constants.TIME);
                String distance = jsonPayload.getString(Constants.DISTANCE);
                String cost = jsonPayload.getString(Constants.COST);
                actionIntent.putExtra(Constants.TIME, time);
                actionIntent.putExtra(Constants.DISTANCE, distance);
                actionIntent.putExtra(Constants.COST, cost);
                context.sendBroadcast(actionIntent);
            } else if (jsonPayload.get(Constants.TYPE).equals(Constants.TRIP_PROCESSED)) {

                // payment processed message - send it directly to the waiting activity
                Intent actionIntent = new Intent(Constants.ACTION_INTENT_PAYMENT_RECEIVED);
                context.sendBroadcast(actionIntent);
            }
        }
    }
}
