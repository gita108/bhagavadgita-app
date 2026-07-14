package com.ethnoapp.bgita.database;

import android.content.Context;

import com.ethnoapp.bgita.model.Book;
import com.ethnoapp.bgita.model.Chapter;
import com.ethnoapp.bgita.model.Language;
import com.ethnoapp.bgita.model.Sloka;
import com.ethnoapp.bgita.model.SlokaInfo;
import com.ethnoapp.bgita.model.Vocabulary;
import com.ethnoapp.bgita.model.audio.AudioState;
import com.ethnoapp.bgita.model.audio.SanskritState;
import com.ethnoapp.bgita.model.audio.TranslateState;
import com.ironwaterstudio.database.DbContext;
import com.ironwaterstudio.database.DbSet;

public class Db extends DbContext {
	public static final String DB_NAME = "gita.sqlite";
	private static final int DB_VERSION = 1;

	private static Db instance = null;

	public static Db get() {
		return instance;
	}

	public static void init(Context context) {
		instance = new Db(context);
	}

	private Db(Context context) {
		super(context, DB_NAME, DB_VERSION, true);
	}

	private final DbSet<Language> languages = new DbSet<>(this, Language.class);
	private final DbSet<Book> books = new DbSet<>(this, Book.class);
	private final DbSet<Chapter> chapters = new DbSet<>(this, Chapter.class);
	private final DbSet<Sloka> slokas = new DbSet<>(this, Sloka.class);
	private final DbSet<Vocabulary> vocabularies = new DbSet<>(this, Vocabulary.class);
	private final DbSet<TranslateState> translateStates = new DbSet<>(this, TranslateState.class);
	private final DbSet<SanskritState> sanskritStates = new DbSet<>(this, SanskritState.class);

	public DbSet<Language> languages() {
		return languages;
	}

	public DbSet<Book> books() {
		return books;
	}

	public DbSet<Chapter> chapters() {
		return chapters;
	}

	public DbSet<Sloka> slokas() {
		return slokas;
	}

	public DbSet<Vocabulary> vocabularies() {
		return vocabularies;
	}

	@SuppressWarnings("unchecked")
	public <T extends AudioState> DbSet<T> translateStates() {
		return (DbSet<T>) translateStates;
	}

	@SuppressWarnings("unchecked")
	public <T extends AudioState> DbSet<T> sanskritStates() {
		return (DbSet<T>) sanskritStates;
	}
}