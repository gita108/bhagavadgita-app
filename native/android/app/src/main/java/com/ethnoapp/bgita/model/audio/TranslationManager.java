package com.ethnoapp.bgita.model.audio;

import android.content.Context;

import com.ethnoapp.bgita.database.Db;
import com.ethnoapp.bgita.model.Book;
import com.ethnoapp.bgita.model.Settings;
import com.ironwaterstudio.database.DbSet;

public class TranslationManager extends AudioManager {
	private static TranslationManager instance = null;

	public static TranslationManager getInstance() {
		return instance;
	}

	public static void initInstance(Context context) {
		if (instance == null)
			instance = new TranslationManager(context);
	}

	private TranslationManager(Context context) {
		super(context);
	}

	@Override
	protected <T extends AudioState> DbSet<T> getDbSet() {
		return Db.get().translateStates();
	}

	@Override
	public void processStates() {
		if (!getDbSet().exist())
			add(Book.getTranslationList(Settings.getInstance().getBookId()));
		else
			update();
	}
}