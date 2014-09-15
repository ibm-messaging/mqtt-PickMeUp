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
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.view.Window;
import android.widget.ImageView;
import android.widget.TextView;

import com.ibm.pickmeup.PickMeUpApplication;
import com.ibm.pickmeup.R;

public class DriverArrivedActivity extends Activity {

    private final static String TAG = DriverArrivedActivity.class.getName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d(TAG, ".onCreate() entered");

        super.onCreate(savedInstanceState);

        // hide the Action bar
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        if (getActionBar() != null) {
            getActionBar().hide();
        }

        setContentView(R.layout.activity_driver_arrived);

        // initialse
        initDriverArrivedActivity();
    }

    /**
     * Initialising onscreen elements
     */
    private void initDriverArrivedActivity() {
        Log.d(TAG, ".initDriverArrivedActivity() entered");

        PickMeUpApplication app = (PickMeUpApplication) getApplication();

        // setting driver name
        TextView driverName = (TextView) findViewById(R.id.driverArrivedName);
        driverName.setText(app.getDriverName());

        // setting driver picture
        ImageView picture = (ImageView) findViewById(R.id.driverArrivedPhoto);
        Bitmap driverPhoto = app.getDriverPhoto();
        if (driverPhoto == null) {
            driverPhoto = BitmapFactory.decodeResource(getResources(), R.drawable.ic_user);
        }
        picture.setImageBitmap(driverPhoto);
    }

    @Override
    public void onBackPressed() {
    }
}
