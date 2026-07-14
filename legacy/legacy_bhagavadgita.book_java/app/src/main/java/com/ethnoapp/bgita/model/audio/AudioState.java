package com.ethnoapp.bgita.model.audio;

import android.app.DownloadManager;
import android.content.Context;
import android.net.Uri;

import com.ethnoapp.bgita.BuildConfig;
import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.utils.GitaUtils;
import com.ironwaterstudio.database.Key;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AudioState {
	@Key(false)
	private String audio;
	private boolean isDownloaded = false;
	private long downloadId = -1;

	public AudioState() {
	}

	public AudioState(String audio, boolean isDownloaded) {
		this.audio = audio;
		this.isDownloaded = isDownloaded;
	}

	public String getAudio() {
		return audio;
	}

	public boolean isDownloaded() {
		return isDownloaded;
	}

	public void setDownloaded(boolean isDownloaded) {
		this.isDownloaded = isDownloaded;
	}

	public long getDownloadId() {
		return downloadId;
	}

	public void setDownloadId(long downloadId) {
		this.downloadId = downloadId;
	}

	public void download(Context context) {
		DownloadManager manager = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
		Uri uri = Uri.parse(BuildConfig.HOST + audio);
		long id = manager.enqueue(new DownloadManager.Request(uri)
				.setVisibleInDownloadsUi(false)
				.setTitle(context.getString(R.string.app_name))
				.setDescription(context.getString(R.string.audio))
				.setDestinationUri(Uri.fromFile(GitaUtils.getAudioFile(context, getAudioName(audio))))
				.setNotificationVisibility(DownloadManager.Request.VISIBILITY_HIDDEN));
		setDownloadId(id);
	}

	public static String getAudioName(String audio) {
		Pattern p = Pattern.compile("^.*\\W.*\\/");
		Matcher m = p.matcher(audio);
		return m.find() ? audio.substring(m.end()) : "";
	}
}