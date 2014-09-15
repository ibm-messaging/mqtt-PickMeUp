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
import android.util.Log;

import com.ibm.pickmeup.PickMeUpApplication;
import com.ibm.pickmeup.activities.ChatActivity;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * ChatUtils is used to create ChatMessages, save ChatMessages in a list to be displayed in a
 * chat window at a later stage (i.e. when the ChatActivity gets opened) or emit broadcasts to
 * ChatActivity to display chat messages if the activity is on the foreground.
 */
public class ChatUtils {
    private final static String TAG = ChatUtils.class.getName();
    private static ChatUtils instance;
    private Context context;
    private PickMeUpApplication app;
    private List<String> chatMessageList;

    private ChatUtils(Context context) {
        this.context = context;
        this.app = (PickMeUpApplication) context.getApplicationContext();
        this.chatMessageList = new CopyOnWriteArrayList<String>();
    }

    public static ChatUtils getInstance(Context context) {
        Log.d(TAG, ".getInstance() entered");
        if (instance == null) {
            instance = new ChatUtils(context);
        }
        return instance;
    }

    /**
     * Method to process a chat message string. If ChatActivity is in the foreground, this method
     * will send a broadcast to the activity to display the chat message. Alternatively the message
     * is added to the chatMessageList to be collected later.
     *
     * @param msg chat message string
     */
    public void addTextMessageToChat(String msg) {
        Log.d(TAG, ".addTextMessageToChat() entered");
        String runningActivity = app.getCurrentRunningActivity();
        if (runningActivity != null && runningActivity.equals(ChatActivity.class.getName())) {
            // current running activity is ChatActivity
            Intent actionIntent = new Intent(Constants.ACTION_INTENT_CHAT_MESSAGE_PROCESSED);
            actionIntent.putExtra(Constants.DATA, msg);
            actionIntent.putExtra(Constants.FORMAT, Constants.TEXT);
            context.sendBroadcast(actionIntent);
        } else {
            // current running activity is not ChatActivity
            chatMessageList.add(msg);
        }
    }

    /**
     * Get chat message off the chatMessageList if there are any. This method will remove chat
     * messages off the chatMessageList while processing them
     *
     * @return messageListInstance list of messages collected from chatMessageList or null if none
     * were available
     */
    public ArrayList<String> getChatMessagesIfAny() {
        Log.d(TAG, ".getChatMessagesIfAny() entered");
        if (chatMessageList.size() > 0) {
            ArrayList<String> messageListInstance = new ArrayList<String>();
            for (String message : chatMessageList) {
                messageListInstance.add(message);
                // once we added the message to the messageListInstance we can remove it
                chatMessageList.remove(message);
            }
            return messageListInstance;
        }
        // no messages in the list - return null
        return null;
    }

    public enum ChatSenderType {
        PASSENGER, DRIVER
    }

    /**
     * ChatMessage class is a simple wrapper object around a chat string, sender type
     * (driver or passenger) and chat message type (text or voice)
     */
    public class ChatMessage {

        private String message;
        private ChatSenderType type;
        private String chatMessageType;

        public ChatMessage(String chatMessage, ChatSenderType type, String chatMessageType) {
            this.type = type;
            this.message = chatMessage;
            this.chatMessageType = chatMessageType;
        }

        public String getMessage() {
            return this.message;
        }

        public ChatSenderType getSenderType() {
            return this.type;
        }

        public String getChatMessageType() { return this.chatMessageType; }
    }
}
