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
import android.util.Log;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.ibm.pickmeup.PickMeUpApplication;
import com.ibm.pickmeup.R;

import java.util.ArrayList;

/**
 * ChatRowAdapter is used to create new chat rows as well as setup the chat row display.
 */
public class ChatRowAdapter extends ArrayAdapter {

    private final static String TAG = ChatRowAdapter.class.getName();
    private ArrayList chatMessageList = new ArrayList();

    public ChatRowAdapter(Context context, int resource) {
        super(context, resource);
    }

    @Override
    public void add(Object msg) {
        Log.d(TAG, ".add() entered");
        chatMessageList.add(msg);
        super.add(msg);
    }

    /**
     * Get the size of the chatMessageList
     *
     * @return chatMessageList size
     */
    public int getCount() {
        return this.chatMessageList.size();
    }

    /**
     * Get an item from the chatMessageList
     *
     * @param index of the object
     * @return object from chatMessageList at index
     */
    public Object getItem(int index) {
        return this.chatMessageList.get(index);
    }

    /**
     * Method that is called automatically whenever an object is added to ChatRowAdapter. This method
     * is responsible for inflating the row layout, setting the chat text and images as well as
     * modifying the row layout according the the message sender (driver or passenger)
     *
     * @param position The position of the item within the adapter's data set of the item whose view we want.
     * @param convertView The old view to reuse, if possible. Note: You should check that this view is non-null
     *                    and of an appropriate type before using. If it is not possible to convert this view
     *                    to display the correct data, this method can create a new view. Heterogeneous lists
     *                    can specify their number of view types, so that this View is always of the right type
     *                    (see getViewTypeCount() and getItemViewType(int)).
     * @param parent The parent that this view will eventually be attached to
     *
     * @return view corresponding to the data at the specified position.
     */
    public View getView(int position, View convertView, ViewGroup parent) {
        Log.d(TAG, ".getView() entered");

        // reuse the view if it was already created
        View chatRow = convertView;
        if (chatRow == null) {
            LayoutInflater inflater = (LayoutInflater) this.getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            chatRow = inflater.inflate(R.layout.row_layout, parent, false);
        }

        // get a ChatMessage object from the chatMessageList
        ChatUtils.ChatMessage chatMessageObj = (ChatUtils.ChatMessage) getItem(position);

        // set the chat message text
        TextView chatText = (TextView) chatRow.findViewById(R.id.rowText);

        if (chatMessageObj.getChatMessageType().equals(Constants.VOICE)) {
            chatText.setText(R.string.voice_message_sent);
        } else {
            chatText.setText(chatMessageObj.getMessage());
        }

        // get the photo from the app and set it for the row
        ImageView photoView = (ImageView) chatRow.findViewById(R.id.rowImage);
        PickMeUpApplication app = (PickMeUpApplication) this.getContext().getApplicationContext();
        ChatUtils.ChatSenderType type = chatMessageObj.getSenderType();
        if (type == ChatUtils.ChatSenderType.DRIVER) {
            photoView.setImageBitmap(app.getDriverPhoto());
        } else {
            photoView.setImageBitmap(app.getPassengerPhoto());
        }

        // setup generic layout params
        FrameLayout chatRowFrameLayout = (FrameLayout) chatRow.findViewById(R.id.chatRowFrameLayout);

        RelativeLayout.LayoutParams chatRowFrameLayoutParams = new RelativeLayout.LayoutParams(
                getPixelsFromDp(80), getPixelsFromDp(80));

        RelativeLayout.LayoutParams textViewLayoutParams = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);

        chatRowFrameLayoutParams.addRule(RelativeLayout.CENTER_VERTICAL);
        chatRowFrameLayoutParams.setMargins(0, getPixelsFromDp(5), 0, getPixelsFromDp(5));

        // change the layout parameters according to the message sender
        if (chatMessageObj.getSenderType() == ChatUtils.ChatSenderType.PASSENGER) {
            chatRowFrameLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT);

            textViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            textViewLayoutParams.setMargins(getPixelsFromDp(120), getPixelsFromDp(10), getPixelsFromDp(8), 0);
        } else {
            chatRowFrameLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            textViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
            textViewLayoutParams.setMargins(getPixelsFromDp(8), getPixelsFromDp(10), getPixelsFromDp(120), getPixelsFromDp(10));
        }
        chatRowFrameLayout.setLayoutParams(chatRowFrameLayoutParams);
        chatText.setLayoutParams(textViewLayoutParams);
        chatText.requestLayout();
        return chatRow;
    }

    /**
     * Helper method to transform dp to px
     *
     * @param dp value as integer
     * @return value in pixels as integer
     */
    private int getPixelsFromDp(int dp) {
        Log.d(TAG, ".getPixelsFromDp() entered");

        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, getContext().getResources().getDisplayMetrics());
    }
}
