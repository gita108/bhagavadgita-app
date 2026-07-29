package com.ethnoapp.bgita.services;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.support.v4.app.NotificationCompat;
import android.text.TextUtils;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.screens.MainActivity;
import com.ethnoapp.bgita.screens.UiConstants;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.ironwaterstudio.utils.Utils;

public class FirebaseMessagingServiceEx extends FirebaseMessagingService {
	public static final String ANDROID_CHANNEL_ID = "com.ethnoapp.bgita";
	private static final int NOTIFICATION_ID = 1;
	private static final String KEY_TEXT = "text";
	private static final String KEY_TYPE = "type";
	private static final String KEY_TITLE = "title";
	private static final int TYPE_QUOTE = 1;

	@Override
	public void onMessageReceived(RemoteMessage remoteMessage) {
		if (remoteMessage.getData().isEmpty())
			return;

		switch (Utils.parseInt(remoteMessage.getData().get(KEY_TYPE), -1)) {
			case TYPE_QUOTE:
				sendNotification(remoteMessage.getData().get(KEY_TITLE), remoteMessage.getData().get(KEY_TEXT));
				break;
		}
	}

	private void sendNotification(String title, String message) {
		if (TextUtils.isEmpty(message))
			return;

		NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
		Intent intent = new Intent(this, MainActivity.class);
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
		PendingIntent contentIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_ONE_SHOT);

		createChannelIfNeeded(manager);
		NotificationCompat.Builder builder = new NotificationCompat.Builder(this, ANDROID_CHANNEL_ID)
				.setContentIntent(contentIntent)
				.setSmallIcon(R.drawable.launcher)
				.setContentTitle(title)
				.setContentText(message)
				.setTicker(message)
				.setDefaults(Notification.DEFAULT_ALL)
				.setAutoCancel(true);
		try {
			manager.notify(NOTIFICATION_ID, builder.build());
		} catch (Exception e) {
			// On some devices it can throw java.lang.SecurityException: Requires VIBRATE permission
			e.printStackTrace();
		}
	}

	private void createChannelIfNeeded(NotificationManager manager) {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O)
			return;

		NotificationChannel channel = manager.getNotificationChannel(ANDROID_CHANNEL_ID);
		if (channel == null) {
			channel = new NotificationChannel(ANDROID_CHANNEL_ID, getString(R.string.app_name), NotificationManager.IMPORTANCE_DEFAULT);
			manager.createNotificationChannel(channel);
		}
	}
}
