package com.ethnoapp.bgita.model.audio;

import android.app.DownloadManager;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.os.AsyncTask;

import com.ethnoapp.bgita.database.Db;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ethnoapp.bgita.utils.GitaUtils;
import com.ironwaterstudio.database.DbSet;
import com.ironwaterstudio.database.DbWhere;
import com.ironwaterstudio.utils.FileUtils;

import java.io.File;
import java.util.ArrayList;

public abstract class AudioManager {
	private final Context context;
	private AsyncTask task;

	AudioManager(Context context) {
		this.context = context;
	}

	protected void add(ArrayList<String> audio) {
		File audioDir = GitaUtils.getAudioDir(context);
		if (!audioDir.exists() && !audioDir.mkdirs())
			return;
		for (String item : audio) {
			AudioState state = new AudioState(item, GitaUtils.getAudioFile(context, AudioState.getAudioName(item)).exists());
			getDbSet().add(state);
		}
		Db.get().saveChanges();
	}

	protected void update() {
		File audioDir = GitaUtils.getAudioDir(context);
		if (!audioDir.exists() && !audioDir.mkdirs())
			return;
		for (AudioState state : getDbSet().toList()) {
			if (state.isDownloaded() && !GitaUtils.getAudioFile(context, AudioState.getAudioName(state.getAudio())).exists()) {
				state.setDownloaded(false);
				state.setDownloadId(-1);
				getDbSet().update(state);
			}
		}
		Db.get().saveChanges();
	}

	protected abstract <T extends AudioState> DbSet<T> getDbSet();

	public abstract void processStates();

	public void delete() {
		for (AudioState state : getDbSet().toList()) {
			FileUtils.deleteFile(GitaUtils.getAudioFile(context, AudioState.getAudioName(state.getAudio())));
			state.setDownloaded(false);
			state.setDownloadId(-1);
			getDbSet().update(state);
		}
		Db.get().saveChanges();
	}

	public void download() {
		task = new DownloadTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
	}

	public void completeDownload() {
		if (task != null)
			return;
		if (getDbSet().where(new DbWhere("IsDownloaded", true).eq(0).and("DownloadId", true).eq(-1)).exist())
			download();
	}

	public boolean isDownloaded() {
		return task == null && !getDbSet().where(new DbWhere("IsDownloaded", true).eq(0)).exist();
	}

	public boolean queryDownloads() {
		ArrayList<AudioState> audioStates = getDownloadState();
		if (audioStates.isEmpty())
			return false;

		DownloadManager manager = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
		long[] idsArray = new long[audioStates.size()];
		for (int i = 0; i < audioStates.size(); i++)
			idsArray[i] = audioStates.get(i).getDownloadId();
		Cursor c = manager.query(new DownloadManager.Query().setFilterById(idsArray));
		int colId = c.getColumnIndex(DownloadManager.COLUMN_ID);
		int colStatus = c.getColumnIndex(DownloadManager.COLUMN_STATUS);
		while (c.moveToNext()) {
			long id = c.getLong(colId);
			AudioState state = getState(audioStates, id);
			if (state == null)
				continue;

			int status = c.getInt(colStatus);
			if (status == DownloadManager.STATUS_SUCCESSFUL) {
				state.setDownloaded(true);
				state.setDownloadId(-1);
				getDbSet().update(state);
			} else if (status == DownloadManager.STATUS_FAILED) {
				state.setDownloaded(false);
				state.setDownloadId(-1);
				getDbSet().update(state);
			}
		}
		c.close();
		Db.get().saveChanges();
		return true;
	}

	public boolean isEmpty() {
		return !getDbSet().exist();
	}

	private static AudioState getState(ArrayList<AudioState> audioStates, long downloadId) {
		for (AudioState state : audioStates)
			if (state.getDownloadId() == downloadId)
				return state;
		return null;
	}

	private ArrayList<AudioState> getDownloadState() {
		return getDbSet().where(new DbWhere("DownloadId", true).neq(-1)).toList();
	}

	private class DownloadTask extends AsyncTask<Void, Void, Void> {
		@Override
		protected Void doInBackground(Void... voids) {
			ArrayList<AudioState> audioStates = getDbSet().toList();
			for (int i = 0; i < audioStates.size(); i++) {
				if (!audioStates.get(i).isDownloaded() && audioStates.get(i).getDownloadId() == -1) {
					audioStates.get(i).download(context);
					Db.get().execute(String.format("UPDATE %s SET DownloadId = ? WHERE Audio = ?", getDbSet().getTableName()), String.valueOf(audioStates.get(i).getDownloadId()), audioStates.get(i).getAudio());
				}
			}
			return null;
		}

		@Override
		protected void onPostExecute(Void aVoid) {
			super.onPostExecute(aVoid);
			task = null;
			context.sendBroadcast(new Intent(UiConstants.ACTION_COMPLETE_ENQUEUE));
		}
	}
}