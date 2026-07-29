package com.ethnoapp.bgita.server;

import android.text.TextUtils;

import com.ethnoapp.bgita.BuildConfig;
import com.ethnoapp.bgita.model.Settings;
import com.ironwaterstudio.server.http.HttpRequest;

import java.util.Locale;

public class GitaRequest extends HttpRequest {
	public GitaRequest(GitaRequest request) {
		super(request);
	}

	public GitaRequest(String action) {
		super(BuildConfig.HOST + "/api/" + action);
		addHeader("accept-language", Locale.getDefault().getLanguage());
		if (!TextUtils.isEmpty(Settings.getInstance().getDeviceToken()))
			addHeader("Authorization", "Gita " + Settings.getInstance().getDeviceToken());
	}

	@Override
	protected HttpRequest copy() {
		return new GitaRequest(this);
	}
}