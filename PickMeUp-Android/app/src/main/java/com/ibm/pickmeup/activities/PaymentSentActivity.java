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
import android.widget.TextView;

import com.ibm.pickmeup.PickMeUpApplication;
import com.ibm.pickmeup.R;
import com.ibm.pickmeup.utils.Constants;
import com.ibm.pickmeup.utils.MessageFactory;
import com.ibm.pickmeup.utils.MqttHandler;
import com.ibm.pickmeup.utils.TopicFactory;

import java.util.Currency;
import java.util.Locale;

public class PaymentSentActivity extends Activity {

    private final static String TAG = PaymentSentActivity.class.getName();
    private BroadcastReceiver paymentConfirmationReceiver;
    private float paymentTotal = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d(TAG, ".onCreate() entered");
        super.onCreate(savedInstanceState);

        // hide action bar
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        if (getActionBar() != null) {
            getActionBar().hide();
        }

        setContentView(R.layout.activity_payment_sent);

        // initialise
        initPaymentSentActivity();
    }

    @Override
    protected void onResume() {
        Log.d(TAG, ".onResume() entered");
        super.onResume();

        // creating paymentConfirmationReceiver if it doesn't exist
        if (paymentConfirmationReceiver == null) {
            Log.d(TAG, ".onResume() - Registering paymentConfirmationReceiver");
            paymentConfirmationReceiver = new BroadcastReceiver() {

                @Override
                public void onReceive(Context context, Intent intent) {
                    Log.d(TAG, ".onReceive() - Received intent for paymentConfirmationReceiver");
                    paymentReceived();
                }
            };
        }

        // registering paymentConfirmationReceiver
        getApplicationContext().registerReceiver(paymentConfirmationReceiver,
                new IntentFilter(Constants.ACTION_INTENT_PAYMENT_RECEIVED));
    }

    @Override
    protected void onPause() {
        Log.d(TAG, ".onPause() entered");
        super.onPause();

        // unregistering paymentConfirmationReceiver
        unregisterReceivers();
    }

    /**
     * Initialising onscreen elements and util classes.
     */
    private void initPaymentSentActivity() {
        Log.d(TAG, ".initPaymentSentActivity() entered");

        PickMeUpApplication app = (PickMeUpApplication) getApplication();

        // set driver name
        TextView driverName = (TextView) findViewById(R.id.paymentSentDriverName);
        driverName.setText(app.getDriverName());

        // set driver picture
        ImageView picture = (ImageView) findViewById(R.id.paymentSentDriverPhoto);
        Bitmap driverPhoto = app.getDriverPhoto();
        if (driverPhoto == null) {
            driverPhoto = BitmapFactory.decodeResource(getResources(), R.drawable.ic_user);
        }
        picture.setImageBitmap(driverPhoto);

        // get trip cost, total payment, rating and the tip passed inside the startActivity intent
        String cost = getIntent().getStringExtra(Constants.COST);
        String tip = getIntent().getStringExtra(Constants.TIP);
        String rating = getIntent().getStringExtra(Constants.RATING);
        paymentTotal = getIntent().getFloatExtra(Constants.PAYMENT_TOTAL, 0);

        // get hold of the utils
        MqttHandler mqttHandler = MqttHandler.getInstance(this);
        TopicFactory topicFactory = TopicFactory.getInstance(this);
        MessageFactory messageFactory = MessageFactory.getInstance(this);

        // publishing payment message
        mqttHandler.publish(topicFactory.getPassengerPaymentTopic(),
                messageFactory.getPaymentMessage(cost, tip, rating), false, 2);
    }

    /**
     * Set the payment received message on the screen with the payment amount
     */
    private void paymentReceived() {
        Log.d(TAG, ".paymentReceived() entered");

        // change the header text
        TextView paymentSent = (TextView) findViewById(R.id.paymentSentHeader);
        paymentSent.setText(R.string.payment_sent);

        // set the payment sent text
        TextView paymentConfirmation = (TextView) findViewById(R.id.paymentSentMessage);
        String paymentSentText = String.format(getResources().getString(R.string.payment_sent_message),Currency.getInstance(Locale.getDefault()).getSymbol(),paymentTotal);
        paymentConfirmation.setText(paymentSentText);
        paymentConfirmation.setVisibility(View.VISIBLE);

        // setup submit payment button
        Button submitPaymentButton = (Button) findViewById(R.id.paymentSentHomeButton);
        submitPaymentButton.setVisibility(View.VISIBLE);
        submitPaymentButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startLoginActivity();
            }
        });
    }

    /**
     * Starts LoginActivity
     */
    private void startLoginActivity() {
        Log.d(TAG, ".startLoginActivity() entered");

        // disconnect from the mqtt broker

        MqttHandler.getInstance(this).disconnect();
        // call LoginActivity
        Intent loginActivityIntent = new Intent(this, LoginActivity.class);
        startActivity(loginActivityIntent);
    }

    /**
     * Unregister all local BroadcastReceivers
     */
    private void unregisterReceivers() {
        Log.d(TAG, ".unregisterReceivers() entered");
        if (paymentConfirmationReceiver != null) {
            getApplicationContext().unregisterReceiver(paymentConfirmationReceiver);
            paymentConfirmationReceiver = null;
        }
    }

    @Override
    public void onBackPressed() {
    }
}
