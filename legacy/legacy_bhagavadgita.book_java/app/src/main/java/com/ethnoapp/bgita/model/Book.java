package com.ethnoapp.bgita.model;

import android.content.Context;
import android.text.TextUtils;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.database.Db;
import com.ironwaterstudio.database.DbWhere;
import com.ironwaterstudio.database.Key;
import com.ironwaterstudio.database.NotMapped;
import com.ironwaterstudio.database.Table;

import java.util.ArrayList;

@Table("Books")
public class Book {
	public static final int STATUS_NO = -1;
	public static final int STATUS_PROGRESS_LOAD = 0;
	public static final int STATUS_PROGRESS_DELETE = 1;
	public static final int STATUS_SUCCESS = 2;
	public static final int STATUS_ERROR = 3;

	@Key(false)
	private int id;
	private int languageId;
	private String name;
	private String initials;
	private int chaptersCount;
	@NotMapped
	private transient int status = STATUS_NO;

	public Book() {
	}

	public int getId() {
		return id;
	}

	public int getLanguageId() {
		return languageId;
	}

	public String getName() {
		return name;
	}

	public String getInitials() {
		return initials;
	}

	public int getChaptersCount() {
		return chaptersCount;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public String getStatusText(Context context) {
		switch (status) {
			case STATUS_NO:
				return context.getString(R.string.download);
			case STATUS_PROGRESS_LOAD:
				return context.getString(R.string.loading);
			case STATUS_ERROR:
				return context.getString(R.string.retry);
			case STATUS_PROGRESS_DELETE:
				return context.getString(R.string.deleting);
		}
		return "";
	}

	public static void add(Book book) {
		Db.get().books().add(book);
	}

	public static void remove(Book book) {
		Db.get().books().remove(book);
	}

	public static boolean contains(ArrayList<Book> books, int bookId) {
		for (Book item : books)
			if (item.getId() == bookId)
				return true;
		return false;
	}

	public static void merge(ArrayList<Book> books, ArrayList<Integer> languageIds) {
		ArrayList<Book> booksFromDb = Book.getList(languageIds.toArray(new Integer[languageIds.size()]));
		for (Book item : booksFromDb)
			item.setStatus(Book.STATUS_SUCCESS);
		int i = 0;
		while (i < books.size()) {
			if (contains(booksFromDb, books.get(i).getId()))
				books.remove(books.get(i));
			else
				i++;
		}
		books.addAll(0, booksFromDb);
	}

	public static ArrayList<String> getTranslationList(int bookId) {
		ArrayList<String> result = new ArrayList<>();
		ArrayList<Sloka> slokas = Db.get().slokas().join("Chapters", new DbWhere("Chapters.Id", false).eq("Slokas.ChapterId")).where(new DbWhere("Chapters.BookId").eq(bookId)).select("audio").toList();
		for (Sloka sloka : slokas)
			if (!TextUtils.isEmpty(sloka.getAudio()))
				result.add(sloka.getAudio());
		return result;
	}

	public static ArrayList<String> getSanskritList(int bookId) {
		ArrayList<String> result = new ArrayList<>();
		ArrayList<Sloka> slokas = Db.get().slokas().join("Chapters", new DbWhere("Chapters.Id", false).eq("Slokas.ChapterId")).where(new DbWhere("Chapters.BookId").eq(bookId)).select("audioSanskrit").toList();
		for (Sloka sloka : slokas)
			if (!TextUtils.isEmpty(sloka.getAudioSanskrit()))
				result.add(sloka.getAudioSanskrit());
		return result;
	}

	public static ArrayList<Book> getList() {
		return Db.get().books().toList();
	}

	public static ArrayList<Book> getList(Integer[] languageIds) {
		return Db.get().books().where(new DbWhere("LanguageId", true).in(languageIds)).toList();
	}
}