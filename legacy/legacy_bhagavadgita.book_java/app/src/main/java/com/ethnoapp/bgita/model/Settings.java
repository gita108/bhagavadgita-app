package com.ethnoapp.bgita.model;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;

import com.ironwaterstudio.server.serializers.JsonSerializer;
import com.ironwaterstudio.server.serializers.Serializer;

public class Settings {
	private static Settings instance = null;

	private static final String PERSISTENCE_NAME = "Settings";
	private static final String KEY_APP_STATE = "appState";
	private static final String KEY_BOOK_ID = "bookId";
	private static final String KEY_LANGUAGE_ID = "languageId";
	private static final String KEY_APP_SETTINGS = "appSettings";
	private static final String KEY_SELECTED_ID = "slokaId";
	private static final String KEY_DEVICE_TOKEN = "deviceToken";

	private SharedPreferences sharedPrefs = null;
	private AppState appState = AppState.DOWNLOAD;
	private int bookId = -1;
	private int languageId = -1;
	private int selectedId = -1;
	private AppSettings appSettings = new AppSettings();
	private String deviceToken = null;

	public static Settings getInstance() {
		return instance;
	}

	public static void initInstance(Context context) {
		if (instance == null)
			instance = new Settings(context);
	}

	private Settings(Context context) {
		sharedPrefs = context.getSharedPreferences(PERSISTENCE_NAME, Activity.MODE_PRIVATE);
		load();
	}

	private void load() {
		appState = AppState.values()[sharedPrefs.getInt(KEY_APP_STATE, appState.ordinal())];
		bookId = sharedPrefs.getInt(KEY_BOOK_ID, bookId);
		languageId = sharedPrefs.getInt(KEY_LANGUAGE_ID, languageId);
		selectedId = sharedPrefs.getInt(KEY_SELECTED_ID, selectedId);
		appSettings = load(KEY_APP_SETTINGS, AppSettings.class, appSettings);
		deviceToken = sharedPrefs.getString(KEY_DEVICE_TOKEN, deviceToken);
	}

	@SuppressWarnings("ConstantConditions")
	private <T> T load(String key, Class<T> cls, T defValue) {
		String str = sharedPrefs.getString(key, null);
		T result = Serializer.get(JsonSerializer.class).read(str, cls);
		if (result == null)
			result = defValue;
		return result;
	}

	public void save() {
		SharedPreferences.Editor editor = sharedPrefs.edit();
		editor.putInt(KEY_APP_STATE, appState.ordinal());
		editor.putInt(KEY_BOOK_ID, bookId);
		editor.putInt(KEY_LANGUAGE_ID, languageId);
		editor.putInt(KEY_SELECTED_ID, selectedId);
		editor.putString(KEY_APP_SETTINGS, Serializer.get(JsonSerializer.class).write(appSettings));
		editor.putString(KEY_DEVICE_TOKEN, deviceToken);
		editor.apply();
	}

	public AppState getAppState() {
		return appState;
	}

	public void setAppState(AppState appState) {
		this.appState = appState;
	}

	public int getBookId() {
		return bookId;
	}

	public void setBookId(int bookId) {
		this.bookId = bookId;
	}

	public int getLanguageId() {
		return languageId;
	}

	public void setLanguageId(int languageId) {
		this.languageId = languageId;
	}

	public int getSelectedId() {
		return selectedId;
	}

	public void setSelectedId(int selectedId) {
		this.selectedId = selectedId;
	}

	public AppSettings getAppSettings() {
		return appSettings;
	}

	public String getDeviceToken() {
		return deviceToken;
	}

	public void setDeviceToken(String deviceToken) {
		this.deviceToken = deviceToken;
	}
}