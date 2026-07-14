package com.ethnoapp.bgita.server;

import android.annotation.SuppressLint;
import android.content.Context;
import android.provider.Settings;

import com.ironwaterstudio.server.listeners.OnCallListener;
import com.ironwaterstudio.utils.Utils;

import java.util.Date;

public class AuthService {
	private static final String NAME = "Auth/";

	public static void updatePushToken(String token) {
		new GitaRequest(NAME + "UpdatePushToken").buildParams("token", token).call();
	}

	public static void updateDevice(Context context, OnCallListener listener) {
		@SuppressLint("HardwareIds") String deviceId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
		new GitaRequest(NAME + "UpdateDevice").buildParams("deviceId", deviceId, "localTime", Utils.toUnixTimeStamp(new Date())).call(listener);
	}
}
