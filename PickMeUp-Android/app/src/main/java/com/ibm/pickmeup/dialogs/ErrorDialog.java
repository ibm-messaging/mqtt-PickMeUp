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
package com.ibm.pickmeup.dialogs;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;

import com.ibm.pickmeup.R;
import com.ibm.pickmeup.utils.MqttHandler;

/**
 * ErrorDialog is a dialog that displays an error message when the client cannot connect to the
 * MQTT broker. The dialog will offer the user to go to the previous screen (Exit) or retry
 * connecting to the server (Retry)
 */

public class ErrorDialog extends DialogFragment {

    private static final String TAG = ErrorDialog.class.getName();
    private Activity currentActivity;

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Log.d(TAG, ".onCreateDialog() entered");

        // get hold of the current activity
        currentActivity = getActivity();

        // Use the Builder class for convenient dialog construction
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setMessage(R.string.broker_unavailable_check_connectivity)
                .setPositiveButton(R.string.retry,
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog,
                                                int id) {
                                Log.d(TAG, ".onClick() entered - retry button");

                                // attempt to reconnect
                                MqttHandler.getInstance(currentActivity.getApplicationContext()).connect();
                            }
                        }
                ).setNegativeButton(R.string.exit,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog,
                                        int id) {
                        Log.d(TAG, ".onClick() entered - exit button");

                        // go back to the previous screen
                        currentActivity.finish();
                    }
                }
        );

        return builder.create();
    }
}
