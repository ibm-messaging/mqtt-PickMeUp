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
import android.content.SharedPreferences;
import android.util.Log;

import org.eclipse.paho.android.service.MqttAndroidClient;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.MqttPersistenceException;
import org.json.JSONException;

/**
 * MqttHandler is a utils class that interacts with the MQTT service. Use this class to perform the
 * basic operations on the MQTT service such as connect, subscribe, unsubscribe and
 * publish.
 * <p/>
 * MqttHandler implements MqttCallback which allows it to process incoming message from the MQTT
 * service.
 */
public class MqttHandler implements MqttCallback {

    private final static String TAG = MqttHandler.class.getName();
    private static MqttHandler instance;
    private MqttAndroidClient client;
    private Context context;

    private MqttHandler(Context context) {
        this.context = context;
        initMqttConnection();
    }

    public static MqttHandler getInstance(Context context) {
        if (instance == null) {
            instance = new MqttHandler(context);
        }
        return instance;
    }

    /**
     * Initialisation method to create an MqttAndroidClient base on the connection preferences
     */
    private void initMqttConnection() {
        Log.d(TAG, ".initMqttConnection() entered");

        //connection setting are stored in SharedPreferences
        SharedPreferences settings = context.getSharedPreferences(Constants.SETTINGS,
                context.MODE_PRIVATE);
        String serverHost = settings.getString(Constants.SETTINGS_MQTT_SERVER, "");
        String serverPort = settings.getString(Constants.SETTINGS_MQTT_PORT, "");
        String clientId = settings.getString(Constants.SETTINGS_NAME, "");

        Log.d(TAG, ".initMqttConnection() - Host name: " + serverHost + ", Port: " + serverPort
                + ", client id: " + clientId);

        String connectionUri = "tcp://" + serverHost + ":" + serverPort;
        client = new MqttAndroidClient(context, connectionUri, clientId);
        client.setCallback(this);
    }

    /**
     * Connect MqttAndroidClient to the MQTT broker
     */
    public void connect() {
        Log.d(TAG, ".connect() entered");

        // check if client is already connected
        if (!isMqttConnected()) {
            // create ActionListener to handle connection results
            ActionListener listener = new ActionListener(context, Constants.ActionStateStatus.CONNECTING);
            // create MqttConnectOptions and set the clean session and the Last Will message
            MqttConnectOptions options = new MqttConnectOptions();
            options.setCleanSession(true);
            options.setWill(TopicFactory.getInstance(context).getPassengerTopLevelTopic(), new byte[0], 0, true);

            try {
                // connect
                client.connect(options, context, listener);
            } catch (MqttException e) {
                Log.e(TAG, "Exception caught while attempting to connect to server", e.getCause());
                if (e.getReasonCode() == (Constants.ERROR_BROKER_UNAVAILABLE)) {
                    // error while connecting to the broker - send an intent to inform the user
                    Intent actionIntent = new Intent(Constants.ACTION_INTENT_CONNECTIVITY_MESSAGE_RECEIVED);
                    actionIntent.putExtra(Constants.CONNECTIVITY_MESSAGE, Constants.ERROR_BROKER_UNAVAILABLE);
                    context.sendBroadcast(actionIntent);
                }
            }
        }
    }

    /**
     * Disconnect MqttAndroidClient from the MQTT broker
     */
    public void disconnect() {
        Log.d(TAG, ".disconnect() entered");

        // check if client is actually connected
        if (isMqttConnected()) {
            try {
                // disconnect
                client.disconnect();
            } catch (MqttException e) {
                Log.e(TAG, "Exception caught while attempting to disconnect from server", e.getCause());
            }
        }
    }

    /**
     * Subscribe MqttAndroidClient to a topic
     *
     * @param topic to subscribe to
     * @param qos   to subscribe with
     */
    public void subscribe(String topic, int qos) {
        Log.d(TAG, ".subscribe() entered");

        // check if client is connected
        if (isMqttConnected()) {
            try {
                // create ActionListener to handle subscription results
                ActionListener listener = new ActionListener(context, Constants.ActionStateStatus.SUBSCRIBE);
                Log.d(TAG, ".subscribe() - Subscribing to: " + topic + ", with QoS: " + qos);
                client.subscribe(topic, qos, context, listener);
            } catch (MqttException e) {
                Log.e(TAG, "Exception caught while attempting to subscribe to topic " + topic, e.getCause());
            }
        } else {
            handleMqttDisconnected();
        }
    }

    /**
     * Unsubscribe MqttAndroidClient from a topic
     *
     * @param topic to unsubscribe from
     */
    public void unsubscribe(String topic) {
        Log.d(TAG, ".unsubscribe() entered");

        // check if client is connected
        if (isMqttConnected()) {
            try {
                // create ActionListener to handle unsubscription results
                ActionListener listener = new ActionListener(context, Constants.ActionStateStatus.UNSIBSCRIBE);
                client.unsubscribe(topic, context, listener);
            } catch (MqttException e) {
                Log.e(TAG, "Exception caught while attempting to unsubscribe from topic " + topic, e.getCause());
            }
        } else {
            handleMqttDisconnected();
        }
    }

    /**
     * Publish message to a topic
     *
     * @param topic    to publish the message to
     * @param message  JSON object representation as a string
     * @param retained true if retained flag is requred
     * @param qos      quality of service (0, 1, 2)
     */
    public void publish(String topic, String message, boolean retained, int qos) {
        Log.d(TAG, ".publish() entered");

        // check if client is connected
        if (isMqttConnected()) {
            // create a new MqttMessage from the message string
            MqttMessage mqttMsg = new MqttMessage(message.getBytes());
            // set retained flag
            mqttMsg.setRetained(retained);
            // set quality of service
            mqttMsg.setQos(qos);
            try {
                // create ActionListener to handle message published results
                ActionListener listener = new ActionListener(context, Constants.ActionStateStatus.PUBLISH);
                Log.d(TAG, ".publish() - Publishing " + message + " to: " + topic + ", with QoS: " + qos + " with retained flag set to " + retained);
                client.publish(topic, mqttMsg, context, listener);
            } catch (MqttPersistenceException e) {
                Log.e(TAG, "MqttPersistenceException caught while attempting to publish a message", e.getCause());
            } catch (MqttException e) {
                Log.e(TAG, "MqttException caught while attempting to publish a message", e.getCause());
            }
        } else {
            handleMqttDisconnected();
        }
    }

    /**
     * Helper method to handle situations when MQTT client is not connected while attempting
     * actions on the client
     */
    private void handleMqttDisconnected() {
        Log.d(TAG, ".handleMqttDisconnected() entered");
        Log.d(TAG, "MqttAndroidClient is not connected");

        // add error handling and reconnect logic
    }

    @Override
    public void connectionLost(Throwable throwable) {
        Log.d(TAG, ".connectionLost() entered");
    }

    @Override
    public void messageArrived(String topic, MqttMessage mqttMessage) throws Exception {
        Log.d(TAG, ".messageArrived() entered");
        String payload = new String(mqttMessage.getPayload());
        Log.d(TAG, ".messageArrived - Message received on topic " + topic
                + ": message is " + payload);
        try {
            // send the message through the application logic
            MessageConductor.getInstance(context).steerMessage(payload, topic);
        } catch (JSONException e) {
            Log.e(TAG, ".messageArrived() - Exception caught while steering a message", e.getCause());
            e.printStackTrace();
        }
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken iMqttDeliveryToken) {
        Log.d(TAG, ".deliveryComplete() entered");
    }

    /**
     * Checks if the MQTT client has an active connection
     */
    private boolean isMqttConnected() {
        Log.d(TAG, ".isMqttConnected() entered");
        boolean connected = false;
        try {
            if ((client != null) && (client.isConnected())) {
                connected = true;
            }
        } catch (Exception e) {
            // swallowing the exception as it means the client is not connected
        }
        Log.d(TAG, ".isMqttConnected() - returning " + connected);
        return connected;
    }
}