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
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.ibm.pickmeup.R;
import com.ibm.pickmeup.utils.Constants;
import com.ibm.pickmeup.utils.LocationUtils;

public class LoginActivity extends Activity {

    private final static String TAG = LoginActivity.class.getName();
    private Context context;
    private TextView name;
    private SharedPreferences settings;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d(TAG, ".onCreate() entered");

        super.onCreate(savedInstanceState);

        // hide the Action bar
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        if (getActionBar() != null) {
            getActionBar().hide();
        }

        setContentView(R.layout.activity_login);
    }

    @Override
    protected void onResume() {
        Log.d(TAG, ".onResume() entered");

        super.onResume();

        // initialise
        initialiseLoginActivity();

        // connect to location services
        LocationUtils.getInstance(context).connect();
    }

    @Override
    protected void onDestroy() {
        Log.d(TAG, ".onDestroy() entered");

        super.onDestroy();

        // disconnect from location services
        LocationUtils.getInstance(context).disconnect();
    }

    /**
     * Initialising onscreen elements and shared properties
     */
    private void initialiseLoginActivity() {
        Log.d(TAG, ".initialiseLoginActivity() entered");

        context = getApplicationContext();
        settings = getSharedPreferences(Constants.SETTINGS, 0);

        // setting up the name input field
        name = (TextView) findViewById(R.id.loginName);
        name.setText(settings.getString(Constants.SETTINGS_NAME, ""));
        name.setBackgroundResource(R.drawable.edittext);

        Button button = (Button) findViewById(R.id.loginButton);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                handleOnLogin();
            }
        });
    }

    /**
     * Method to handle passenger name on login and start serching for available drivers
     */
    private void handleOnLogin() {
        Log.d(TAG, ".handleOnLogin() entered");

        String passengerName = name.getText().toString();
        // check if name is empty
        if (name.getText() == null || name.getText().length() == 0) {
            Log.d(TAG, ".handleOnLogin() - Passenger name was left empty");
            Toast.makeText(context, R.string.name_not_specified, Toast.LENGTH_LONG).show();
        } else {
            Log.d(TAG, ".handleOnLogin() - Passenger name is "+passengerName);

            // save passenger name to shared preferences
            SharedPreferences.Editor editor = settings.edit();
            editor.putString(Constants.SETTINGS_NAME, passengerName);
            editor.commit();

            // start next activity
            prepareProfile();
        }
    }

    /**
     * Starts next activity
     */
    private void prepareProfile() {
        Log.d(TAG, ".searchForDrivers() entered");
        // call next activity
        Intent chatPrepIntent = new Intent(context, ChatPrepActivity.class);
        startActivity(chatPrepIntent);
    }

    @Override
    public void onBackPressed() {
    }
}
