package com.ethnoapp.bgita.model;

import android.os.AsyncTask;

import com.ethnoapp.bgita.database.Db;
import com.ethnoapp.bgita.server.DataService;
import com.ironwaterstudio.server.data.ApiResult;

import java.util.ArrayList;

public class BookManager {
	private static BookManager instance = null;

	private AsyncTask task;
	private ArrayList<Book> books = new ArrayList<>();
	private IFinished iFinished;

	public static BookManager getInstance() {
		return instance;
	}

	public static void initInstance() {
		if (instance == null)
			instance = new BookManager();
	}

	public void setILoaded(IFinished iFinished) {
		this.iFinished = iFinished;
	}

	public int getStatus(int bookId, int defStatus) {
		for (Book book : books)
			if (book.getId() == bookId)
				return book.getStatus();
		return defStatus;
	}

	public void load(Book book) {
		book.setStatus(Book.STATUS_PROGRESS_LOAD);
		books.add(book);
		if (task == null || task.getStatus() == AsyncTask.Status.FINISHED)
			start();
	}

	public void delete(Book book) {
		book.setStatus(Book.STATUS_PROGRESS_DELETE);
		books.add(book);
		if (task == null || task.getStatus() == AsyncTask.Status.FINISHED)
			start();
	}

	private void start() {
		if (!books.isEmpty()) {
			Book book = books.get(0);
			if (book.getStatus() == Book.STATUS_PROGRESS_LOAD)
				task = new LoadTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, book);
			else
				task = new DeleteTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, book);
		}
	}

	private void finish(Integer status) {
		Book book = books.get(0);
		book.setStatus(status);

		if (iFinished != null)
			iFinished.onFinished(book);
		books.remove(0);
		start();
	}

	private static class LoadTask extends AsyncTask<Book, Void, Integer> {
		@Override
		protected Integer doInBackground(Book... books) {
			Book book = books[0];
			ApiResult chaptersResult = DataService.getChaptersRequest(book.getId(), false).call();
			if (!chaptersResult.isSuccess())
				return Book.STATUS_ERROR;
			Chapters chapters = chaptersResult.getData(Chapters.class);
			Book.add(book);
			for (Chapter chapter : chapters) {
				Chapter.add(chapter, book.getId());
				for (Sloka sloka : chapter.getSlokas()) {
					Sloka.add(sloka, chapter.getId());
					for (Vocabulary vocabulary : sloka.getVocabularies()) {
						Vocabulary.add(vocabulary, sloka.getId());
					}
				}
			}
			Db.get().saveChanges();
			return Book.STATUS_SUCCESS;
		}

		@Override
		protected void onPostExecute(Integer status) {
			super.onPostExecute(status);
			getInstance().finish(status);
		}
	}

	private static class DeleteTask extends AsyncTask<Book, Void, Integer> {
		@Override
		protected Integer doInBackground(Book... books) {
			Book book = books[0];
			ArrayList<Chapter> chapters = Chapter.getList(book.getId());
			for (Chapter chapter : chapters) {
				for (Sloka sloka : Sloka.getList(chapter.getId())) {
					for (Vocabulary vocabulary : Vocabulary.getList(sloka.getId())) {
						Vocabulary.remove(vocabulary);
					}
					Sloka.remove(sloka);
				}
				Chapter.remove(chapter);
			}
			Book.remove(book);
			Db.get().saveChanges();
			return Book.STATUS_NO;
		}

		@Override
		protected void onPostExecute(Integer status) {
			super.onPostExecute(status);
			getInstance().finish(status);
		}
	}
}