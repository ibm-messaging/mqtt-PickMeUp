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

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Point;
import android.location.Location;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.animation.Interpolator;
import android.view.animation.LinearInterpolator;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.Projection;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.ibm.pickmeup.PickMeUpApplication;
import com.ibm.pickmeup.R;
import com.ibm.pickmeup.utils.Constants;
import com.ibm.pickmeup.utils.LocationUtils;

import java.util.Calendar;

public class MapActivity extends FragmentActivity {

    private final static String TAG = MapActivity.class.getName();
    private GoogleMap mMap; // Might be null if Google Play services APK is not available.
    private BroadcastReceiver coordinatesChangedBroadcastReceiver;
    private Marker driverMarker;
    private PickMeUpApplication app;
    private TextView distanceDetails;
    private TextView etaDetails;
    private Location passengerLocation;
    private Location driverLocation;
    private Calendar calendar;
    private String AM_PM;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d(TAG, ".onCreate() entered");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_map);

        // initialise
        initMapActivity();
    }

    @Override
    protected void onResume() {
        Log.d(TAG, ".onResume() entered");
        super.onResume();

        // register coordinatesChangedBroadcastReceiver
        registerReceivers();

        // setup google map layout
        setUpMapIfNeeded();

        // register current activity as a running activity inside our application class
        app.setCurrentRunningActivity(TAG);
    }

    @Override
    protected void onPause() {
        Log.d(TAG, ".onPause() entered");
        super.onPause();

        // unregister
        unregisterReceivers();

        // unregister current activity inside our application class
        app.setCurrentRunningActivityEmpty();
    }

    /**
     * Initialising shared properties
     */
    private void initMapActivity() {
        Log.d(TAG, ".initMapActivity() entered");
        app = (PickMeUpApplication) getApplication();
        driverLocation = new Location("");
    }


    /**
     * Sets up the map if it is possible to do so (i.e., the Google Play services APK is correctly
     * installed) and the map has not already been instantiated.. This will ensure that we only ever
     * call {@link #setUpMap()} once when {@link #mMap} is not null.
     * <p/>
     * If it isn't installed {@link SupportMapFragment} (and
     * {@link com.google.android.gms.maps.MapView MapView}) will show a prompt for the user to
     * install/update the Google Play services APK on their device.
     * <p/>
     * A user can return to this FragmentActivity after following the prompt and correctly
     * installing/updating/enabling the Google Play services. Since the FragmentActivity may not
     * have been completely destroyed during this process (it is likely that it would only be
     * stopped or paused), {@link #onCreate(Bundle)} may not be called again so we should call this
     * method in {@link #onResume()} to guarantee that it will be called.
     */
    private void setUpMapIfNeeded() {
        Log.d(TAG, ".setUpMapIfNeeded() entered");
        // Do a null check to confirm that we have not already instantiated the map.
        if (mMap == null) {
            // Try to obtain the map from the SupportMapFragment.
            mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map))
                    .getMap();
            // Check if we were successful in obtaining the map.
            if (mMap != null) {
                setUpMap();
            } else {
                mapUnavailable();
            }
        }
    }

    /**
     * Show a toast message to the user about Location services and return to the previous activity
     */
    private void mapUnavailable() {
        Toast.makeText(this,R.string.location_services_map_unavailable,Toast.LENGTH_SHORT).show();
        openChat();
    }

    /**
     * Create and register coordinatesChangedBroadcastReceiver
     */
    private void registerReceivers() {
        Log.d(TAG, ".registerReceivers() entered");
        if (coordinatesChangedBroadcastReceiver == null) {
            Log.d(TAG, ".registerReceivers() - Registering coordinatesChangedBroadcastReceiver");
            coordinatesChangedBroadcastReceiver = new BroadcastReceiver() {

                @Override
                public void onReceive(Context context, Intent intent) {
                    // update map with new coordinates
                    updateMap(intent);
                }
            };
        }

        // registering coordinatesChangedBroadcastReceiver
        getApplicationContext().registerReceiver(coordinatesChangedBroadcastReceiver,
                new IntentFilter(Constants.ACTION_INTENT_COORDINATES_CHANGED));
    }

    /**
     * Setup map, markers, ETA and Distance values
     */
    private void setUpMap() {
        Log.d(TAG, ".setUpMap() entered");

        // setup ETA and Distance values
        distanceDetails = (TextView) findViewById(R.id.distanceWithValue);
        etaDetails = (TextView) findViewById(R.id.etaWithValue);
        distanceDetails.setText(R.string.distance_calculating);
        etaDetails.setText(R.string.eta_calculating);

        // setup passenger marker and move the camera accordingly
        passengerLocation = LocationUtils.getInstance(this).getLocation();

        if (passengerLocation == null) {
            mapUnavailable();
        } else {
            LatLng passengerLatLng = new LatLng(passengerLocation.getLatitude(), passengerLocation.getLongitude());
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(passengerLatLng, 10));
            mMap.addMarker(new MarkerOptions().position(passengerLatLng).icon(BitmapDescriptorFactory.fromResource(R.drawable.ic_passenger)));
        }
    }

    /**
     * Update map with the new coordinates for the driver
     * @param intent containing driver coordinates
     */
    private void updateMap(final Intent intent) {
        // not logging entry as it will flood the logs

        // getting driver LatLng values from the intent
        final LatLng driverLatLng = new LatLng(intent.getFloatExtra(Constants.LATITUDE, 0), intent.getFloatExtra(Constants.LONGITUDE, 0));

        // create driver marker if it doesn't exist and move the camera accordingly
        if (driverMarker == null) {
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(driverLatLng, 10));
            driverMarker = mMap.addMarker(new MarkerOptions().position(driverLatLng).icon(BitmapDescriptorFactory.fromResource(R.drawable.ic_driver)));
            return;
        }

        // update driver location with LatLng
        driverLocation.setLatitude(driverLatLng.latitude);
        driverLocation.setLongitude(driverLatLng.longitude);

        // calculate current distance to the passenger
        float distance = passengerLocation.distanceTo(driverLocation) / 1000;

        // set the distance text
        distanceDetails.setText(String.format(getResources().getString(R.string.distance_with_value), distance));

        // calculating ETA - we are assuming here that the car travels at 20mph to simplify the calculations
        calendar = Calendar.getInstance();
        calendar.add(Calendar.MINUTE, Math.round(distance / 20 * 60));

        // set AM/PM to a relevant value
        AM_PM = getString(R.string.am);
        if (calendar.get(Calendar.AM_PM) == 1) {
            AM_PM = getString(R.string.pm);
        }

        // format ETA string to HH:MM
        String eta = String.format(getResources().getString(R.string.eta_with_value), calendar.get(Calendar.HOUR_OF_DAY), calendar.get(Calendar.MINUTE), AM_PM);

        // set the ETA text
        etaDetails.setText(eta);

        // as we are throttling updates to the coordinates, we might need to smooth out the moving
        // of the driver's marker. To do so we are going to draw temporary markers between the
        // previous and the current coordinates. We are going to use interpolation for this and
        // use handler/looper to set the marker's position

        // get hold of the handler
        final Handler handler = new Handler();
        final long start = SystemClock.uptimeMillis();

        // get map projection and the driver's starting point
        Projection proj = mMap.getProjection();
        Point startPoint = proj.toScreenLocation(driverMarker.getPosition());
        final LatLng startLatLng = proj.fromScreenLocation(startPoint);
        final long duration = 150;

        // create new Interpolator
        final Interpolator interpolator = new LinearInterpolator();

        // post a Runnable to the handler
        handler.post(new Runnable() {
            @Override
            public void run() {
                // calculate how soon we need to redraw the marker
                long elapsed = SystemClock.uptimeMillis() - start;
                float t = interpolator.getInterpolation((float) elapsed
                        / duration);
                double lng = t * intent.getFloatExtra(Constants.LONGITUDE, 0) + (1 - t)
                        * startLatLng.longitude;
                double lat = t * intent.getFloatExtra(Constants.LATITUDE, 0) + (1 - t)
                        * startLatLng.latitude;

                // set the driver's marker position
                driverMarker.setPosition(new LatLng(lat, lng));
                if (t < 1.0) {
                    handler.postDelayed(this, 10);
                }
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.chat_map_actions, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle presses on the action bar items
        switch (item.getItemId()) {
            case R.id.action_chat:
                openChat();
                return true;
            case R.id.action_map:
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    /**
     * We want to go back to the previous activity therefore we just finish the current one to go
     * back through the stack
     */
    private void openChat() {
        Log.d(TAG, ".openChat() entered");
        finish();
    }

    /**
     * Unregister all local BroadcastReceivers
     */
    private void unregisterReceivers() {
        Log.d(TAG, ".unregisterReceivers() entered");
        if (coordinatesChangedBroadcastReceiver != null) {
            getApplicationContext().unregisterReceiver(coordinatesChangedBroadcastReceiver);
            coordinatesChangedBroadcastReceiver = null;
        }

    }

}
