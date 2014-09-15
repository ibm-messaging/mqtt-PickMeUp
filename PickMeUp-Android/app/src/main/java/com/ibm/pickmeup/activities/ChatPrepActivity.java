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
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.ibm.pickmeup.PickMeUpApplication;
import com.ibm.pickmeup.R;
import com.ibm.pickmeup.utils.Constants;
import com.ibm.pickmeup.utils.MessageFactory;
import com.ibm.pickmeup.utils.MqttHandler;
import com.ibm.pickmeup.utils.TopicFactory;

public class ChatPrepActivity extends Activity {

    private final static String TAG = ChatPrepActivity.class.getName();
    private static final int CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE = 1;
    private ImageView cameraButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d(TAG, ".onCreate() entered");

        super.onCreate(savedInstanceState);

        // hide the Action bar
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        if (getActionBar() != null) {
            getActionBar().hide();
        }
        setContentView(R.layout.activity_chat_prep);

        // initialise
        initChatPrepActivity();
    }

    /**
     * Initialising onscreen elements
     */
    private void initChatPrepActivity() {
        Log.d(TAG, ".initChatPrepActivity() entered");

        // get passenger name from the preferences
        SharedPreferences settings = getSharedPreferences(Constants.SETTINGS, 0);
        TextView name = (TextView) findViewById(R.id.passengerName);
        name.setText(settings.getString(Constants.SETTINGS_NAME, ""));

        // setup camera button for taking a selfie
        cameraButton = (ImageView) findViewById(R.id.selfieButton);
        cameraButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                //snapping a picture using an existing default camera app
                Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                if (intent.resolveActivity(getPackageManager()) != null) {
                    startActivityForResult(intent, CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE);
                }
            }
        });

        // setup continue button
        Button button = (Button) findViewById(R.id.pickmeupButton);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // move to the next screen
                Intent searchDriverIntent = new Intent(getApplicationContext(), SearchDriversActivity.class);
                startActivity(searchDriverIntent);
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d(TAG, ".onActivityResult() entered");
        if (requestCode == CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE && resultCode == RESULT_OK) {
            Log.d(TAG, ".onActivityResult() - Result code is OK");

            // getting selfie bitmap
            Bundle extras = data.getExtras();
            Bitmap imageBitmap = (Bitmap) extras.get(Constants.DATA);

            // scaling selfie to 256x256
            Bitmap passengerSelfie = Bitmap.createScaledBitmap(imageBitmap, 256, 256, true);
            if (cameraButton == null) {
                cameraButton = (ImageView) findViewById(R.id.selfieButton);
            }

            // setting selfie to the camera button
            cameraButton.setAdjustViewBounds(false);
            cameraButton.setScaleType(ImageView.ScaleType.FIT_CENTER);
            cameraButton.setImageBitmap(passengerSelfie);

            // recording selfie bitmap in memory for other activities to use
            PickMeUpApplication app = (PickMeUpApplication) getApplication();
            app.setPassengerPhoto(passengerSelfie);

            // making the continue button visible
            Button continueButton = (Button) findViewById(R.id.pickmeupButton);
            continueButton.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onBackPressed() {
    }
}
