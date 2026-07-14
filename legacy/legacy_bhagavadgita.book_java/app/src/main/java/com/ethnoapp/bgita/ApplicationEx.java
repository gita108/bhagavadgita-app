package com.ethnoapp.bgita;

import android.app.Application;

import com.ethnoapp.bgita.database.Db;
import com.ethnoapp.bgita.model.BookManager;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.model.audio.SanskritManager;
import com.ethnoapp.bgita.model.audio.TranslationManager;
import com.ironwaterstudio.server.http.HttpHelper;
import com.ironwaterstudio.utils.GaUtils;

public class ApplicationEx extends Application {
	@Override
	public void onCreate() {
		super.onCreate();
		GaUtils.init(this);
		Db.init(this);
		HttpHelper.init(this);
		Settings.initInstance(this);
		BookManager.initInstance();
		TranslationManager.initInstance(this);
		SanskritManager.initInstance(this);
	}
}
