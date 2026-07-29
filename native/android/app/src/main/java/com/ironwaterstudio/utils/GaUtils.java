package com.ironwaterstudio.utils;

import android.content.Context;

import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;
import com.ethnoapp.bgita.R;

public class GaUtils {
	private static Tracker tracker;

	public static Tracker getTracker() {
		return tracker;
	}

	public static void init(Context context) {
		GoogleAnalytics analytics = GoogleAnalytics.getInstance(context);
		tracker = analytics.newTracker(R.xml.app_tracker);
	}

	public static void logActivity(String name) {
		tracker.setScreenName(name);
		tracker.send(new HitBuilders.ScreenViewBuilder().build());
	}

	public static void logEvent(String category, String action) {
		tracker.send(new HitBuilders.EventBuilder().setCategory(category).setAction(action).build());
	}
}
