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
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesClient;
import com.google.android.gms.location.LocationClient;
import com.ibm.pickmeup.R;

/**
 * LocationUtils is a helper class to communicate with Google Location services.
 * <p/>
 * LocationUtils is handing LocationClient connect and disconnect, provides a public getLocation
 * method for getting the last available location, sets up a LocationListener and publishes
 * location changes to the passenger location topic.
 */
public class LocationUtils implements GooglePlayServicesClient.ConnectionCallbacks,
        GooglePlayServicesClient.OnConnectionFailedListener, LocationListener {

    private final static String TAG = LocationUtils.class.getName();
    private static LocationUtils instance;
    private LocationManager locationManager;
    private Context context;
    private LocationClient locationClient;
    private Location currentLocation;
    private Criteria criteria;
    private MqttHandler mqttHandler;
    private MessageFactory messageFactory;
    private TopicFactory topicFactory;

    private LocationUtils(Context context) {
        this.context = context;
        this.locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        this.criteria = getCriteria();

        // getting hold of the utils
        mqttHandler = MqttHandler.getInstance(context);
        messageFactory = MessageFactory.getInstance(context);
        topicFactory = TopicFactory.getInstance(context);
    }

    public static LocationUtils getInstance(Context context) {
        if (instance == null) {
            instance = new LocationUtils(context);
        }
        return instance;
    }

    /**
     * Method to create LocationClient if needed and connect the client to Google Location services
     */
    public void connect() {
        Log.d(TAG, ".connect() entered");
        if (locationClient == null) {
            locationClient = new LocationClient(context, this, this);
        }
        locationClient.connect();
    }

    /**
     * Method to disconnect LocationClient from Google Location services
     */
    public void disconnect() {
        Log.d(TAG, ".disconnect() entered");
        if (locationClient != null) {
            locationClient.disconnect();
        }
    }

    /**
     * Get last location from LocationClient. This method will check if LocationClient is connected
     * before attempting to get the location
     */
    public Location getLocation() {
        Log.d(TAG, ".getLocation() entered");
        if (locationClient != null && locationClient.isConnected()) {
            currentLocation = locationClient.getLastLocation();
        }
        return currentLocation;
    }

    @Override
    public void onConnected(Bundle bundle) {
        Log.d(TAG, ".onConnected() entered");
        if (locationClient.isConnected()) {
            // set current location
            currentLocation = locationClient.getLastLocation();

            if (currentLocation == null) {
                Log.e(TAG, ".onConnected() - Location is null, location services are disabled");

                // if location is not available we need to ask the user to turn on the location services
                Toast.makeText(context, R.string.location_services_unavailable, Toast.LENGTH_LONG).show();
            }

            // register for location updates
            String bestProvider = locationManager.getBestProvider(criteria, false);
            locationManager.requestLocationUpdates(bestProvider, Constants.LOCATION_MIN_TIME, Constants.LOCATION_MIN_DISTANCE, this);
        }
    }

    @Override
    public void onDisconnected() {
        Log.d(TAG, ".onDisconnected() entered");

        // good place for error handling
    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
        Log.d(TAG, ".onConnectionFailed() entered");

        // good place for error handling
    }

    @Override
    public void onLocationChanged(Location location) {
        Log.d(TAG, ".onLocationChanged() entered");

        //publish location details
        publishLocation(location);
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {
        Log.d(TAG, ".onStatusChanged() entered");

    }

    @Override
    public void onProviderEnabled(String provider) {
        Log.d(TAG, ".onProviderEnabled() entered");

    }

    @Override
    public void onProviderDisabled(String provider) {
        Log.d(TAG, ".onProviderDisabled() entered");

    }

    /**
     * Helper method to create a criteria for location change listener
     *
     * @return criteria constructed for the listener
     */
    public Criteria getCriteria() {
        Criteria criteria = new Criteria();
        criteria.setPowerRequirement(Criteria.POWER_LOW);
        criteria.setAccuracy(Criteria.ACCURACY_FINE);
        criteria.setAltitudeRequired(false);
        criteria.setBearingRequired(false);
        criteria.setCostAllowed(true);
        criteria.setSpeedRequired(false);
        return criteria;
    }

    /**
     * Method to publish location details to the passenger location topic
     *
     * @param location to publish
     */
    private void publishLocation(Location location) {
        mqttHandler.publish(topicFactory.getPassengerLocationTopic(),
                messageFactory.getLocationMessage(location.getLatitude(),
                        location.getLongitude()), true, 0
        );
    }
}

