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
import android.database.DataSetObserver;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.media.ToneGenerator;
import android.net.Uri;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;

import com.ibm.pickmeup.PickMeUpApplication;
import com.ibm.pickmeup.R;
import com.ibm.pickmeup.utils.ChatRowAdapter;
import com.ibm.pickmeup.utils.ChatUtils;
import com.ibm.pickmeup.utils.Constants;
import com.ibm.pickmeup.utils.MessageFactory;
import com.ibm.pickmeup.utils.MqttHandler;
import com.ibm.pickmeup.utils.TopicFactory;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;

public class ChatActivity extends Activity {


    private final static String TAG = ChatActivity.class.getName();
    private ChatRowAdapter adapter;
    private ListView listView;
    private EditText chatBox;
    private MqttHandler mqttHandler;
    private TopicFactory topicFactory;
    private MessageFactory messageFactory;
    private ChatUtils chatUtils;
    private PickMeUpApplication app;
    private BroadcastReceiver chatBroadcastReceiver;
    private MediaRecorder mediaRecorder;
    private String lastVoiceMessageFilePath;
    private boolean recording;
    private boolean recorded;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d(TAG, ".onCreate() entered");

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);

        // hide the soft keyboard
        this.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);

        // initialise
        initChatActivity();

        // subscribe to MQTT chat topics
        subscribeToChatTopics();
    }

    @Override
    protected void onResume() {
        Log.d(TAG, ".onResume() entered");
        super.onResume();

        // register current activity as a running activity inside our application class
        app.setCurrentRunningActivity(TAG);

        // create chatBroadcastReceiver if it doesn't exist
        if (chatBroadcastReceiver == null) {
            Log.d(TAG, ".onResume() - Registering chatBroadcastReceiver");
            chatBroadcastReceiver = new BroadcastReceiver() {

                @Override
                public void onReceive(Context context, Intent intent) {
                    Log.d(TAG, ".onReceive() - Received intent for chatBroadcastReceiver");
                    processChatMessage(intent);
                }
            };
        }

        // register chat broadcast receiver
        getApplicationContext().registerReceiver(chatBroadcastReceiver,
                new IntentFilter(Constants.ACTION_INTENT_CHAT_MESSAGE_PROCESSED));

        // while outside of the ChatActivity we are storing chat messages in a list within ChatUtils
        // onResume we need to check the list for any chat messages from the driver received while
        // the ChatActivity was not opened.
        ArrayList<String> chatMessageList = chatUtils.getChatMessagesIfAny();
        if (chatMessageList != null) {
            for (String chatMessage : chatMessageList) {
                // process each individual chat message from the list
                receivedDriverMessage(chatMessage);
            }
        }
    }

    @Override
    protected void onPause() {
        Log.d(TAG, ".onPause() entered");
        super.onPause();

        // unregister the ChatAvtivity as the running activity
        app.setCurrentRunningActivityEmpty();

        // unregister chatBroadcastReceiver
        unregisterReceivers();
    }

    /**
     * Initialising onscreen elements and util classes.
     */
    private void initChatActivity() {
        Log.d(TAG, "initChatActivity() entered");
        // get hold of the util classes
        messageFactory = MessageFactory.getInstance(this);
        chatUtils = ChatUtils.getInstance(this);
        app = (PickMeUpApplication) getApplication();

        // ChatRowAdapter is used to populate chat rows inside the chat list view
        adapter = new ChatRowAdapter(this, R.layout.row_layout);
        listView = (ListView) findViewById(R.id.chatList);
        listView.setAdapter(adapter);

        // setup user input view
        chatBox = (EditText) findViewById(R.id.chatInput);
        chatBox.setBackgroundResource(R.drawable.edittext);

        // link enter key to sending the chat message
        chatBox.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            public boolean onEditorAction(TextView v, int actionId,
                                          KeyEvent event) {
                if (event.getKeyCode() == KeyEvent.KEYCODE_ENTER) {
                    sendPassengerMessage();
                    return true;
                }
                return false;
            }
        });

        // register observer to set active row inside the chat list
        adapter.registerDataSetObserver(new DataSetObserver() {
            @Override
            public void onChanged() {
                super.onChanged();
                listView.setSelection(adapter.getCount() - 1);
            }
        });

        // setup the send message button
        ImageButton sendMessageButton = (ImageButton) findViewById(R.id.sendMessage);
        sendMessageButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sendPassengerMessage();
            }
        });

        // setup voice recording button
        ImageButton recordMessageButton = (ImageButton) findViewById(R.id.recordMessageButton);
        recordMessageButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                recordVoiceMessage();
            }
        });
    }

    /**
     * Method that deals with voice chat message recoding and playback
     */
    private void recordVoiceMessage() {
        Log.d(TAG, ".recordVoiceMessage() entered");
        ImageButton button = (ImageButton) findViewById(R.id.recordMessageButton);

        if (!recording && !recorded) {
            Log.d(TAG, ".recordVoiceMessage() - Started recording");

            recording = true;

            // make a beeping sound
            playBeep(Constants.HIGH_BEEP);

            // change the mic icon to show we're recording
            button.setImageResource(R.drawable.ic_action_microphone_recording);

            // initialise voice recorder
            mediaRecorder = new MediaRecorder();
            mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
            mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
            mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);

            // get the message file path
            lastVoiceMessageFilePath = getAudioMessageFilePath();

            Log.d(TAG, ".recordVoiceMessage() - Voice message file path is: " + lastVoiceMessageFilePath);

            // set the output to our message file path
            mediaRecorder.setOutputFile(lastVoiceMessageFilePath);

            try {
                mediaRecorder.prepare();

                // start recording
                mediaRecorder.start();
            } catch (IOException e) {
                Log.e(TAG, "recordVoiceMessage - prepare() failed");
            }
        } else if (mediaRecorder != null && !recorded) {
            Log.d(TAG, ".recordVoiceMessage() - Stopped recording");

            recording = false;
            recorded = true;

            // change the button to play icon
            button = (ImageButton) findViewById(R.id.recordMessageButton);
            button.setImageResource(R.drawable.ic_action_play);

            // cleanup the recorder
            mediaRecorder.stop();
            mediaRecorder.reset();
            mediaRecorder.release();
            mediaRecorder = null;

            // beep
            playBeep(Constants.LOW_BEEP);

            // set the chat input filed to voice message
            chatBox = (EditText) findViewById(R.id.chatInput);
            chatBox.setText(R.string.send_voice_message);
        } else if (recorded) {
            Log.d(TAG, ".recordVoiceMessage() - Starting playback");

            // beep
            playBeep(Constants.HIGH_BEEP);

            // create a media player instance and play a file from uri
            MediaPlayer mediaPlayer = MediaPlayer.create(this, Uri.fromFile(new File(lastVoiceMessageFilePath)));
            mediaPlayer.start();

            // change the button back to mic
            button = (ImageButton) findViewById(R.id.recordMessageButton);
            button.setImageResource(R.drawable.ic_action_microphone);

            recorded = false;
        }
    }

    /**
     * Helper method to beep
     */
    private void playBeep(String beep) {
        ToneGenerator toneG = new ToneGenerator(AudioManager.STREAM_ALARM, 100);
        if (beep.equals(Constants.LOW_BEEP)) {
            toneG.startTone(ToneGenerator.TONE_CDMA_ABBR_INTERCEPT, 200);
        } else {
            toneG.startTone(ToneGenerator.TONE_CDMA_ABBR_ALERT, 200);
        }
    }

    /**
     * Subscribe to MQTT chat and driver location topics
     */
    private void subscribeToChatTopics() {
        Log.d(TAG, ".subscribeToChatTopics() entered");
        mqttHandler = MqttHandler.getInstance(this);
        topicFactory = TopicFactory.getInstance(this);
        mqttHandler.subscribe(topicFactory.getPassengerChatTopic(), 0);
        mqttHandler.subscribe(topicFactory.getDriverLocationTopic(), 0);
    }

    /**
     * Get the chat message from the chat box and send it to the driver's MQTT topic.
     */
    private void sendPassengerMessage() {
        Log.d(TAG, ".sendPassengerMessage() entered");
        chatBox = (EditText) findViewById(R.id.chatInput);
        String chatMessage = chatBox.getText().toString();
        String messageType = Constants.TEXT;

        if (chatMessage.equals(getString(R.string.send_voice_message))) {
            chatMessage = getEncodedVoiceMessage(lastVoiceMessageFilePath);
            messageType = Constants.VOICE;
        }

        // create a ChatMessage object and add it to the list view adapter
        adapter.add(chatUtils.new ChatMessage(chatMessage, ChatUtils.ChatSenderType.PASSENGER, messageType));

        // publish the chat message to the driver's MQTT topic
        mqttHandler.publish(topicFactory.getDriverChatTopic(), messageFactory.getChatMessage(messageType, chatMessage), false, 0);

        // clean up the chat input field and remove focus from it
        chatBox.setText("");
        chatBox.clearFocus();
        InputMethodManager imm = (InputMethodManager) getSystemService(
                getApplicationContext().INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(chatBox.getWindowToken(), 0);
    }

    /**
     * Helper method to encode a voice chat message to a Base64 String
     *
     * @param messagePath
     * @return encodedVoiceMessage as Base64 String
     */
    private String getEncodedVoiceMessage(String messagePath) {
        Log.d(TAG, ".getEncodedVoiceMessage() entered");
        String encodedVoiceMessage = "";

        Log.d(TAG, ".getEncodedVoiceMessage() - messagePath is " + messagePath);
        // get a file
        File file = new File(messagePath);
        FileInputStream fis = null;
        try {
            // create an input stream
            fis = new FileInputStream(file);

            // get file length for creating byte array
            int fileLength = (int) file.length();

            // create the byte array and read in the file
            byte[] bytes = new byte[fileLength];
            fis.read(bytes);
            // create a base64 String
            encodedVoiceMessage = Base64.encodeToString(bytes, 0);
            Log.d(TAG, ".getEncodedVoiceMessage() - voice message is " + encodedVoiceMessage);
        } catch (FileNotFoundException e) {
            Log.e(TAG, "Exception caught while trying to locate the voice message file", e.getCause());
        } catch (IOException e) {
            Log.e(TAG, "Exception caught while trying to locate the voice message file", e.getCause());
        } finally {
            if (fis != null) {
                try {
                    fis.close();
                } catch (IOException e) {
                    Log.e(TAG, "Exception caught while trying to close FileInputStream", e.getCause());
                }
            }
        }

        return encodedVoiceMessage;
    }

    /**
     * Helper method to create a ChatMessage object from a String and add it to the list view adapter
     *
     * @param chatMessage chat message (String) received from the driver
     */
    private void receivedDriverMessage(String chatMessage) {
        Log.d(TAG, ".receivedDriverMessage() entered");
        // create a ChatMessage object and add it to the list view adapter
        adapter.add(chatUtils.new ChatMessage(chatMessage, ChatUtils.ChatSenderType.DRIVER, Constants.TEXT));
    }

    /**
     * Get a chat message as String from the intent caught by the chatBroadcastReceiver and process
     * it to display in the list view
     *
     * @param intent caught by the chatBroadcastReceiver
     */
    private void processChatMessage(Intent intent) {
        Log.d(TAG, ".processChatMessage() entered");
        String msg = intent.getStringExtra(Constants.DATA);
        receivedDriverMessage(msg);
    }

    /**
     * Unregister all local BroadcastReceivers
     */
    private void unregisterReceivers() {
        Log.d(TAG, ".unregisterReceivers() entered");
        if (chatBroadcastReceiver != null) {
            getApplicationContext().unregisterReceiver(chatBroadcastReceiver);
            chatBroadcastReceiver = null;
        }
    }

    /**
     * Helper method to open the map activity
     */
    private void openMap() {
        Log.d(TAG, ".openMap() entered");
        Intent mapIntent = new Intent(getApplicationContext(), MapActivity.class);
        startActivity(mapIntent);
    }

    public String getAudioMessageFilePath() {
        Log.d(TAG, ".getAudioMessageFilePath() entered");
        return new File(this.getExternalFilesDir(null), Constants.CHAT + "_" + System.currentTimeMillis() + Constants.AUDIO_FORMAT).getAbsolutePath();
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
                return true;
            case R.id.action_map:
                openMap();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    public void onBackPressed() {
    }
}
