package com.ethnoapp.bgita.model;

import android.os.AsyncTask;
import android.support.v4.app.FragmentActivity;

import com.ethnoapp.bgita.database.Db;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ethnoapp.bgita.server.DataService;
import com.ironwaterstudio.server.Request;
import com.ironwaterstudio.server.data.ApiResult;
import com.ironwaterstudio.server.listeners.ProgressCallListener;
import com.ironwaterstudio.utils.GaUtils;

import java.util.Collections;

public class DataManager {
	private static final int LANGUAGES_SIZE = 1;
	private static final int BOOKS_SIZE = 1;
	private static final int PART_LANGUAGES = 15;
	private static final int PART_BOOKS = 15;
	private static final int PART_CHAPTERS = 30;
	private static final int PART_DB = 40;

	private int counter = 0;
	private OnProgressChangedListener listener = null;
	private Language language;
	private Book book;
	private Chapters chapters;

	private ProgressCallListener getLanguagesListener = new ProgressCallListener(false) {
		@Override
		public void onSuccess(Request request, ApiResult result) {
			super.onSuccess(request, result);
			counter += PART_LANGUAGES;
			Languages languages = result.getData(Languages.class);
			language = Language.getDefaultLanguage(languages);
			if (language != null) {
				Settings.getInstance().setLanguageId(language.getId());
				Settings.getInstance().save();
				DataService.getBooks(Collections.singleton(language.getId()), true, getBooksListener);
			}
		}

		@Override
		public void onDownloadProgress(Request request, float progress) {
			super.onDownloadProgress(request, progress);
			reportProgress(progress, PART_LANGUAGES);
		}
	};

	private ProgressCallListener getBooksListener = new ProgressCallListener(false) {
		@Override
		public void onSuccess(Request request, ApiResult result) {
			super.onSuccess(request, result);
			counter += PART_BOOKS;
			Books books = result.getData(Books.class);
			book = books != null && !books.isEmpty() ? books.get(0) : null;
			Settings.getInstance().setBookId(book != null ? book.getId() : -1);
			Settings.getInstance().save();
			DataService.getChapters(Settings.getInstance().getBookId(), true, getChaptersListener);
		}

		@Override
		public void onDownloadProgress(Request request, float progress) {
			super.onDownloadProgress(request, progress);
			reportProgress(progress, PART_BOOKS);
		}
	};

	private ProgressCallListener getChaptersListener = new ProgressCallListener(false) {
		@Override
		public void onSuccess(Request request, ApiResult result) {
			super.onSuccess(request, result);
			counter += PART_CHAPTERS;
			chapters = result.getData(Chapters.class);
			Settings.getInstance().setSelectedId(!chapters.isEmpty() && !chapters.get(0).getSlokas().isEmpty() ? chapters.get(0).getSlokas().get(0).getId() : -1);
			Settings.getInstance().save();
			new DbTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
		}

		@Override
		public void onDownloadProgress(Request request, float progress) {
			super.onDownloadProgress(request, progress);
			reportProgress(progress, PART_CHAPTERS);
		}
	};

	private class DbTask extends AsyncTask<Void, Integer, Void> {
		private int count;

		public DbTask() {
			count = fletchInsertsCount();
		}

		@Override
		protected Void doInBackground(Void... params) {
			int progress = 0;
			Language.add(language);
			publishProgress(++progress);
			Book.add(book);
			publishProgress(++progress);
			for (Chapter chapter : chapters) {
				Chapter.add(chapter, Settings.getInstance().getBookId());
				publishProgress(++progress);
				for (Sloka sloka : chapter.getSlokas()) {
					Sloka.add(sloka, chapter.getId());
					publishProgress(++progress);
					for (Vocabulary vocabulary : sloka.getVocabularies()) {
						Vocabulary.add(vocabulary, sloka.getId());
						publishProgress(++progress);
					}
				}
			}
			Db.get().saveChanges();
			return null;
		}

		@Override
		protected void onProgressUpdate(Integer... values) {
			super.onProgressUpdate(values);
			reportProgress(values[0] / (float) count, PART_DB);
		}

		@Override
		protected void onPostExecute(Void aVoid) {
			super.onPostExecute(aVoid);
			GaUtils.logEvent(UiConstants.GA_CATEGORY_DOWNLOAD, "Finish download main book");
			if (listener != null)
				listener.onCompleted();
		}
	}

	public DataManager(OnProgressChangedListener listener) {
		this.listener = listener;
	}

	public void load(FragmentActivity activity) {
		getLanguagesListener.setActivity(activity);
		getBooksListener.setActivity(activity);
		getChaptersListener.setActivity(activity);
		GaUtils.logEvent(UiConstants.GA_CATEGORY_DOWNLOAD, "Start download main book");
		DataService.getLanguages(true, getLanguagesListener);
	}

	private void reportProgress(float progress, int part) {
		if (listener != null) {
			listener.onProgressChanged(counter + Math.round(progress * part));
		}
	}

	private int fletchInsertsCount() {
		int part = LANGUAGES_SIZE + BOOKS_SIZE + chapters.size();
		for (Chapter chapter : chapters) {
			part += chapter.getSlokas() != null ? chapter.getSlokas().size() : 0;
			for (Sloka sloka : chapter.getSlokas()) {
				part += sloka.getVocabularies() != null ? sloka.getVocabularies().size() : 0;
			}
		}
		return part;
	}

	public interface OnProgressChangedListener {
		void onProgressChanged(int currentValue);

		void onCompleted();
	}
}
