package com.ethnoapp.bgita.server;

import com.ethnoapp.bgita.model.Books;
import com.ethnoapp.bgita.model.Chapters;
import com.ethnoapp.bgita.model.Languages;
import com.ethnoapp.bgita.model.Quote;
import com.ironwaterstudio.server.Request;
import com.ironwaterstudio.server.listeners.OnCallListener;

import java.util.Collection;

public class DataService {
	private static final String NAME = "Data/";

	public static void getLanguages(boolean publishProgress, OnCallListener listener) {
		new GitaRequest(NAME + "Languages").setPublishProgress(publishProgress).setResultClass(Languages.class).call(listener);
	}

	public static void getBooks(Collection<Integer> ids, boolean publishProgress, OnCallListener listener) {
		new GitaRequest(NAME + "Books").setPublishProgress(publishProgress).setResultClass(Books.class).buildParams("ids", ids).setTag(ids).call(listener);
	}

	public static Request getChaptersRequest(int bookId, boolean publishProgress) {
		return new GitaRequest(NAME + "Chapters").setPublishProgress(publishProgress).setResultClass(Chapters.class).buildParams("bookId", bookId);
	}

	public static void getChapters(int bookId, boolean publishProgress, OnCallListener listener) {
		getChaptersRequest(bookId, publishProgress).call(listener);
	}

	public static void getQuote(OnCallListener listener) {
		new GitaRequest(NAME + "Quotes").setResultClass(Quote.class).call(listener);
	}
}
