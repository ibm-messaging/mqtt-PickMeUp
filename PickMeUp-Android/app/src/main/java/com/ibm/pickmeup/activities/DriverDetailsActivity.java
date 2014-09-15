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
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.ibm.pickmeup.PickMeUpApplication;
import com.ibm.pickmeup.R;
import com.ibm.pickmeup.utils.Constants;
import com.ibm.pickmeup.utils.MqttHandler;
import com.ibm.pickmeup.utils.TopicFactory;

public class DriverDetailsActivity extends Activity {

    private final static String TAG = DriverDetailsActivity.class.getName();
    private BroadcastReceiver updateDriverDetailsBroadcastReceiver;
    private PickMeUpApplication app;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d(TAG, ".onCreate() entered");

        super.onCreate(savedInstanceState);

        // hide the Action bar
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        if (getActionBar() != null) {
            getActionBar().hide();
        }

        setContentView(R.layout.activity_driver_details);

        // initialise
        initialiseDriverDetailsActivity();
    }

    /**
     * Initialising onscreen elements
     */
    private void initialiseDriverDetailsActivity() {
        Log.d(TAG, ".initialiseDriverDetailsActivity() entered");

        Button button = (Button) findViewById(R.id.driverFoundButton);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent chatIntent = new Intent(getApplicationContext(), ChatActivity.class);
                startActivity(chatIntent);
            }
        });
    }

    @Override
    protected void onResume() {
        Log.d(TAG, ".onResume() entered");
        super.onResume();

        // create updateDriverDetailsBroadcastReceiver  if it doesn't exist
        if (updateDriverDetailsBroadcastReceiver == null) {
            Log.d(TAG, ".onResume() - Registering updateDriverDetailsBroadcastReceiver");
            updateDriverDetailsBroadcastReceiver = new BroadcastReceiver() {

                @Override
                public void onReceive(Context context, Intent intent) {
                    Log.d(TAG, ".onReceive() - Received intent for updateDriverDetailsBroadcastReceiver");
                    updateDriverDetails();
                }
            };
        }

        // register updateDriverDetailsBroadcastReceiver
        getApplicationContext().registerReceiver(updateDriverDetailsBroadcastReceiver,
                new IntentFilter(Constants.ACTION_INTENT_DRIVER_DETAILS_UPDATE));

        // subscribe to driver topics
        subscribeForDriver();
    }

    @Override
    protected void onPause() {
        Log.d(TAG, ".onPause() entered");
        super.onPause();

        // unregister updateDriverDetailsBroadcastReceiver
        unregisterReceivers();
    }

    /**
     * Update driver details on the screen
     */
    private void updateDriverDetails() {
        Log.d(TAG, ".updateDriverDetails() entered");
        app = (PickMeUpApplication) getApplication();

        // update driver name
        TextView driverName = (TextView) findViewById(R.id.driverName);
        driverName.setText(app.getDriverName());

        // update driver picture
        ImageView picture = (ImageView) findViewById(R.id.driverFoundPhoto);
        Bitmap driverPhoto = app.getDriverPhoto();
        if (driverPhoto == null) {
            driverPhoto = BitmapFactory.decodeResource(getResources(), R.drawable.ic_user);
        }
        picture.setImageBitmap(driverPhoto);

        // hiding loading spinner
        ProgressBar loading = (ProgressBar) findViewById((R.id.loadingPhotoProgressBar));
        loading.setVisibility(View.GONE);

        // set driver name as visible
        driverName.setVisibility(View.VISIBLE);

        // set driver picture as visible
        picture.setVisibility(View.VISIBLE);
    }

    /**
     * Subscribe to MQTT driver topics
     */
    private void subscribeForDriver() {
        Log.d(TAG, ".subscribeForDriver() entered");
        app = (PickMeUpApplication) getApplication();

        // get hold of the MqttHandler
        MqttHandler mqttHandler = MqttHandler.getInstance(this);
        TopicFactory topicFactory = TopicFactory.getInstance(this);

        // subscribe
        mqttHandler.subscribe(topicFactory.getDriverTopLevelTopic(), 0);
        mqttHandler.subscribe(topicFactory.getDriverPhotoTopic(), 0);
    }

    /**
     * Unregister all local BroadcastReceivers
     */
    private void unregisterReceivers() {
        Log.d(TAG, ".unregisterReceivers() entered");
        if (updateDriverDetailsBroadcastReceiver != null) {
            getApplicationContext().unregisterReceiver(updateDriverDetailsBroadcastReceiver);
            updateDriverDetailsBroadcastReceiver = null;
        }
    }

    @Override
    public void onBackPressed() {
    }
}
