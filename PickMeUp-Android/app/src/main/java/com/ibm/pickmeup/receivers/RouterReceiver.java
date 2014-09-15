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
package com.ibm.pickmeup.receivers;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import com.ibm.pickmeup.PickMeUpApplication;
import com.ibm.pickmeup.activities.DriverArrivedActivity;
import com.ibm.pickmeup.activities.DriverDetailsActivity;
import com.ibm.pickmeup.activities.TripEndDetailsActivity;
import com.ibm.pickmeup.utils.ChatUtils;
import com.ibm.pickmeup.utils.Constants;

/**
 * RouterReceiver acts as an intermediate between the MessageConductor, Utils and Activities.
 * Depending on the ROUTE_MESSAGE_TYPE, RouterReceiver will either process the message, pass it
 * down to an Activity by re-broadcasting the message or pass it to a Utils class for processing.
 * <p/>
 * RouterReceiver is registered on the Manifest level and is available throughout the lifecycle
 * of the app.
 */
public class RouterReceiver extends BroadcastReceiver {
    private final static String TAG = RouterReceiver.class.getName();

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d(TAG, ".onReceive() entered");

        // route the message depending on the ROUTE_MESSAGE_TYPE value

        if (intent.getStringExtra(Constants.ROUTE_MESSAGE_TYPE).equals(Constants.ACTION_INTENT_DRIVER_DETAILS_RECEIVED)) {
            // driver details received
            driverDetailsReceived(context, intent);
        } else if (intent.getStringExtra(Constants.ROUTE_MESSAGE_TYPE).equals(Constants.ACTION_INTENT_START_TRIP)) {
            // start trip message received
            startTripMessageReceived(context, intent);
        } else if (intent.getStringExtra(Constants.ROUTE_MESSAGE_TYPE).equals(Constants.ACTION_INTENT_END_TRIP)) {
            // end trip message received
            endTripMessageReceived(context, intent);
        } else if (intent.getStringExtra(Constants.ROUTE_MESSAGE_TYPE).equals(Constants.ACTION_INTENT_CHAT_MESSAGE_RECEIVED)) {
            // chat message received
            chatMessageReceived(context, intent);
        } else if (intent.getStringExtra(Constants.ROUTE_MESSAGE_TYPE).equals(Constants.ACTION_INTENT_DRIVER_ACCEPTED)) {
            // driver accepted passenger message received
            driverAcceptedMessageReceived(context, intent);
        }

    }

    /**
     * Save the driverId to the shared variables within PickMeUpApplication and
     * start DriverDetailsActivity
     *
     * @param context of the received broadcast
     * @param intent  of the received broadcast
     */
    private void driverAcceptedMessageReceived(Context context, Intent intent) {
        Log.d(TAG, ".driverAcceptedMessageReceived() entered");

        // save driver id to the shared variable within the app
        String driverId = intent.getStringExtra(Constants.DRIVER_ID);
        PickMeUpApplication app = (PickMeUpApplication) context.getApplicationContext();
        app.setDriverId(driverId);

        // call the DriverDetailsActivity - setting FLAG_ACTIVITY_NEW_TASK because we're
        // calling the activity from a BroadcastReceiver
        Intent driverFoundIntent = new Intent(context.getApplicationContext(), DriverDetailsActivity.class);
        driverFoundIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(driverFoundIntent);
    }

    /**
     * Simply start DriverArrivedActivity
     *
     * @param context of the received broadcast
     * @param intent  of the received broadcast
     */
    private void startTripMessageReceived(Context context, Intent intent) {
        Log.d(TAG, ".startTripMessageReceived() entered");

        // call the DriverArrivedActivity - setting FLAG_ACTIVITY_NEW_TASK because we're
        // calling the activity from a BroadcastReceiver
        Intent driverArrivedIntent = new Intent(context, DriverArrivedActivity.class);
        driverArrivedIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(driverArrivedIntent);
    }

    /**
     * Set values received from the broadcast intent to a start activity intent
     * and start TripEndDetailsActivity
     *
     * @param context of the received broadcast
     * @param intent  of the received broadcast
     */
    private void endTripMessageReceived(Context context, Intent intent) {
        Log.d(TAG, ".endTripMessageReceived() entered");

        // call the TripEndDetailsActivity - setting FLAG_ACTIVITY_NEW_TASK because we're
        // calling the activity from a BroadcastReceiver
        Intent tripEndIntent = new Intent(context, TripEndDetailsActivity.class);
        tripEndIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        tripEndIntent.putExtra(Constants.COST, intent.getStringExtra(Constants.COST));
        tripEndIntent.putExtra(Constants.DISTANCE, intent.getStringExtra(Constants.DISTANCE));
        tripEndIntent.putExtra(Constants.TIME, intent.getStringExtra(Constants.TIME));
        context.startActivity(tripEndIntent);
    }

    /**
     * Pass the chat message to the ChatUtils
     *
     * @param context of the received broadcast
     * @param intent  of the received broadcast
     */
    private void chatMessageReceived(Context context, Intent intent) {
        Log.d(TAG, ".chatMessageReceived() entered");

        // check if the chat message is in text format
        if (intent.getStringExtra(Constants.FORMAT).equals(Constants.TEXT)) {

            // get the message string from the intent
            String msg = intent.getStringExtra(Constants.DATA);

            // pass the message to the ChatUtils
            ChatUtils.getInstance(context).addTextMessageToChat(msg);
        }
    }

    /**
     * Save the driver name and driver photo to the shared variables within PickMeUpApplication
     * and broadcast the update
     *
     * @param context of the received broadcast
     * @param intent  of the received broadcast
     */
    private void driverDetailsReceived(Context context, Intent intent) {
        Log.d(TAG, ".driverDetailsReceived() entered");

        // get hold of the app
        PickMeUpApplication app = (PickMeUpApplication) context.getApplicationContext();
        if (intent.getStringExtra(Constants.NAME) != null) {
            // store driver name
            app.setDriverName(intent.getStringExtra(Constants.NAME));
        } else if (intent.getByteArrayExtra(Constants.DRIVER_PICTURE) != null &&
                intent.getByteArrayExtra(Constants.DRIVER_PICTURE).length > 0) {
            // decode the picture and store as bitmap
            byte[] decodedPictureAsBytes = intent.getByteArrayExtra(Constants.DRIVER_PICTURE);
            Bitmap decodedPictureAsBitmap = BitmapFactory.decodeByteArray(decodedPictureAsBytes, 0, decodedPictureAsBytes.length);
            app.setDriverPhoto(decodedPictureAsBitmap);
        }

        // broadcast the update - to be caught in DriverDetailsActivity
        Intent actionIntent = new Intent(Constants.ACTION_INTENT_DRIVER_DETAILS_UPDATE);
        context.sendBroadcast(actionIntent);
    }
}
