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
package com.ibm.pickmeup.activities;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;
import android.view.Window;

import com.ibm.pickmeup.R;
import com.ibm.pickmeup.dialogs.ErrorDialog;
import com.ibm.pickmeup.utils.Constants;
import com.ibm.pickmeup.utils.MessageFactory;
import com.ibm.pickmeup.utils.MqttHandler;
import com.ibm.pickmeup.utils.TopicFactory;

public class SearchDriversActivity extends Activity {

    private final static String TAG = SearchDriversActivity.class.getName();
    private BroadcastReceiver connectivityReceiver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d(TAG, ".onCreate() entered");
        super.onCreate(savedInstanceState);

        // hide action bar
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        if (getActionBar() != null) {
            getActionBar().hide();
        }

        setContentView(R.layout.activity_search_drivers);
    }

    @Override
    protected void onResume() {
        Log.d(TAG, ".onResume() entered");
        super.onResume();

        //register receivers
        registerReceivers();

        //connect to MQTT broker
        connectToMqtt();
    }

    @Override
    protected void onPause() {
        super.onPause();

        // unregister connectivityReceiver
        unregisterReceivers();
    }

    /**
     * Message to initiate an MQTT connection
     */
    private void connectToMqtt() {
        Log.d(TAG, ".connectToMqtt() entered");
        // grab hold of MqttHandler to connect to the server
        MqttHandler.getInstance(this).connect();
    }

    /**
     * Create and register connectivityReceiver
     */
    private void registerReceivers() {

        // create connectivityReceiver if it doesn't exist
        if (connectivityReceiver == null) {
            Log.d(TAG, ".onResume() - Registering connectivityReceiver");
            connectivityReceiver = new BroadcastReceiver() {

                @Override
                public void onReceive(Context context, Intent intent) {
                    Log.d(TAG, ".onReceive() - Received intent for connectivityReceiver");
                    if (intent.getIntExtra(Constants.CONNECTIVITY_MESSAGE, -1) == Constants.ERROR_BROKER_UNAVAILABLE) {
                        // the connection was unsuccessful - show the error dialog to the user
                        ErrorDialog dialog = new ErrorDialog();
                        dialog.setCancelable(false);
                        dialog.show(getFragmentManager(), "");
                    }
                }
            };
        }

        // register connectivityReceiver
        getApplicationContext().registerReceiver(connectivityReceiver,
                new IntentFilter(Constants.ACTION_INTENT_CONNECTIVITY_MESSAGE_RECEIVED));
    }

    /**
     * Unregister all local BroadcastReceivers
     */
    private void unregisterReceivers() {
        Log.d(TAG, ".unregisterReceivers() entered");
        if (connectivityReceiver != null) {
            getApplicationContext().unregisterReceiver(connectivityReceiver);
            connectivityReceiver = null;
        }
    }

    @Override
    public void onBackPressed() {
    }
}
