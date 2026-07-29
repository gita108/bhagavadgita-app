package com.ethnoapp.bgita.model.audio;

import android.content.Context;

import com.ethnoapp.bgita.database.Db;
import com.ethnoapp.bgita.model.Book;
import com.ethnoapp.bgita.model.Settings;
import com.ironwaterstudio.database.DbSet;

public class SanskritManager extends AudioManager {
	private static SanskritManager instance = null;

	public static SanskritManager getInstance() {
		return instance;
	}

	public static void initInstance(Context context) {
		if (instance == null)
			instance = new SanskritManager(context);
	}

	private SanskritManager(Context context) {
		super(context);
	}

	@Override
	protected <T extends AudioState> DbSet<T> getDbSet() {
		return Db.get().sanskritStates();
	}

	@Override
	public void processStates() {
		if (!getDbSet().exist())
			add(Book.getSanskritList(Settings.getInstance().getBookId()));
		else
			update();
	}
}
