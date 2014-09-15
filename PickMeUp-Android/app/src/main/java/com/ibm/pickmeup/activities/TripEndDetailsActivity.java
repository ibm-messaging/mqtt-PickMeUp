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
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.TextView;

import com.ibm.pickmeup.PickMeUpApplication;
import com.ibm.pickmeup.R;
import com.ibm.pickmeup.utils.Constants;

import java.util.Currency;
import java.util.Locale;

public class TripEndDetailsActivity extends Activity {

    private final static String TAG = TripEndDetailsActivity.class.getName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d(TAG, ".onCreate() entered");
        super.onCreate(savedInstanceState);

        // hide action bar
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        if (getActionBar() != null) {
            getActionBar().hide();
        }

        setContentView(R.layout.activity_trip_end_details);

        initTripEndDetailsActivity();
    }

    /**
     * Initialising onscreen elements and util classes.
     */
    private void initTripEndDetailsActivity() {
        Log.d(TAG, ".initTripEndDetailsActivity() entered");
        PickMeUpApplication app = (PickMeUpApplication) getApplication();

        // setup the tip box
        EditText tipBox = (EditText) findViewById(R.id.tripEndTipEntry);
        tipBox.setBackgroundResource(R.drawable.edittext);
        tipBox.setHint(Currency.getInstance(Locale.getDefault()).getSymbol());

        // set the driver's name
        TextView driverName = (TextView) findViewById(R.id.driverTripEndName);
        driverName.setText(app.getDriverName());

        // set the driver's picture
        ImageView picture = (ImageView) findViewById(R.id.driverTripEndPhoto);
        Bitmap driverPhoto = app.getDriverPhoto();
        if (driverPhoto == null) {
            driverPhoto = BitmapFactory.decodeResource(getResources(), R.drawable.ic_user);
        }
        picture.setImageBitmap(driverPhoto);

        // get hold of the cost, distance and time elements
        TextView cost = (TextView) findViewById(R.id.tripEndCost);
        TextView distance = (TextView) findViewById(R.id.tripEndDistance);
        TextView time = (TextView) findViewById(R.id.tripEndTime);

        // set cost based on the value passed down in the startActivity intent
        // use default locale currency symbol in front of the cost value
        cost.setText(Currency.getInstance(Locale.getDefault()).getSymbol() + this.getIntent().getStringExtra(Constants.COST));
        distance.setText(this.getIntent().getStringExtra(Constants.DISTANCE) + Constants.MILES);

        // set time based on the value passed down in the startActivity intent
        int timeInSeconds = Integer.valueOf(this.getIntent().getStringExtra(Constants.TIME));
        // format time to HH:MM:SS
        time.setText(String.format("%02d:%02d:%02d", timeInSeconds / 3600, (timeInSeconds % 3600) / 60, timeInSeconds % 60));

        // setup the dropdown field for the rating
        Spinner spinner = (Spinner) findViewById(R.id.tripEndRatingSpinner);
        ArrayAdapter<Integer> arrayAdapter = new ArrayAdapter(this, android.R.layout.simple_spinner_item, new Integer[]{0, 1, 2, 3, 4, 5});
        arrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(arrayAdapter);

        // setup submit payment button
        Button submitPaymentButton = (Button) findViewById(R.id.submitPaymentButton);
        submitPaymentButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                submitPayment();
            }
        });
    }

    /**
     * Helper method to collect required payment data and pass it to the PaymentSent activity
     */
    private void submitPayment() {
        Log.d(TAG, ".submitPayment() entered");

        // getting the payment value (minus the currency sign)
        float payment = Float.valueOf(((TextView) findViewById(R.id.tripEndCost)).getText().toString().substring(1));

        // getting the tip value
        int tip = 0;
        String tipString = ((EditText) findViewById(R.id.tripEndTipEntry)).getText().toString();
        if (tipString.length() > 0) {
            tip = Integer.valueOf(tipString);
        }

        // getting the rating value
        String rating = ((Spinner) findViewById(R.id.tripEndRatingSpinner)).getSelectedItem().toString();

        // setting all collected data to an intent
        Intent paymentSentIntent = new Intent(getApplicationContext(), PaymentSentActivity.class);

        paymentSentIntent.putExtra(Constants.PAYMENT_TOTAL, tip + payment);
        paymentSentIntent.putExtra(Constants.COST, String.valueOf(payment));
        paymentSentIntent.putExtra(Constants.TIP, String.valueOf(tip));
        paymentSentIntent.putExtra(Constants.RATING, rating);

        // starting PaymentSent activity
        startActivity(paymentSentIntent);
    }

    @Override
    public void onBackPressed() {
    }
}
