package com.ethnoapp.bgita.screens;

import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.model.AppState;
import com.ethnoapp.bgita.model.DataManager;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.model.UpdateDeviceResult;
import com.ethnoapp.bgita.model.audio.TranslationManager;
import com.ethnoapp.bgita.server.AuthService;
import com.ironwaterstudio.dialogs.AlertFragment;
import com.ironwaterstudio.server.data.ApiResult;
import com.ironwaterstudio.server.listeners.CallListener;
import com.ironwaterstudio.utils.GaUtils;
import com.ironwaterstudio.utils.UiHelper;

public class SplashActivity extends AppCompatActivity {
	private static final int WAIT_DELAY = 1000;
	private long startTime = 0;
	private boolean backEnabled = false;

	private View llProgress;
	private TextView tvProgress;
	private ProgressBar progressBar;
	private Handler handler = new Handler();

	private CallListener updateDeviceListener = new CallListener(this, false) {
		@Override
		public void onSuccess(ApiResult result) {
			UpdateDeviceResult updateDeviceResult = result.getData(UpdateDeviceResult.class);
			Settings.getInstance().setDeviceToken(updateDeviceResult.getToken());
			Settings.getInstance().save();
			handleStart();
		}

		@Override
		protected void onError(ApiResult result) {
			if (!TextUtils.isEmpty(Settings.getInstance().getDeviceToken())) {
				handleStart();
			} else {
				super.onError(result);
				backEnabled = true;
			}
		}
	};

	private DataManager.OnProgressChangedListener progressChangedListener = new DataManager.OnProgressChangedListener() {
		@Override
		public void onProgressChanged(int currentValue) {
			tvProgress.setText(getString(R.string.percent_template, currentValue));
			progressBar.setProgress(currentValue);
		}

		@Override
		public void onCompleted() {
			Settings.getInstance().setAppState(AppState.GUIDE);
			Settings.getInstance().save();
			AlertFragment.create().setMessage(R.string.audio_download_answer).setPositiveListener(new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					Settings.getInstance().getAppSettings().setAudioTranslate(true);
					TranslationManager.getInstance().processStates();
					TranslationManager.getInstance().download();
					Settings.getInstance().save();
					showActivity(0);
					GaUtils.logEvent(UiConstants.GA_CATEGORY_DOWNLOAD, "Download audio from SplashActivity");
				}
			}).setNegativeListener(new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					showActivity(0);
					GaUtils.logEvent(UiConstants.GA_CATEGORY_DOWNLOAD, "Cancel download audio from SplashActivity");
				}
			}).show(SplashActivity.this);
		}
	};

	@Override
	protected void onCreate(@Nullable Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_splash);
		llProgress = findViewById(R.id.ll_progress);
		tvProgress = findViewById(R.id.tv_progress);
		progressBar = findViewById(R.id.progress_bar);

		tvProgress.setText(getString(R.string.percent_template, 0));
		progressBar.setProgress(0);
		llProgress.setVisibility(Settings.getInstance().getAppState() == AppState.DOWNLOAD ? View.VISIBLE : View.GONE);

		updateDeviceListener.register(this);

		startTime = System.currentTimeMillis();
		AuthService.updateDevice(this, updateDeviceListener);
	}

	@Override
	public void onBackPressed() {
		if (backEnabled)
			super.onBackPressed();
	}

	private void showActivity(int delay) {
		handler.postDelayed(new Runnable() {
			@Override
			public void run() {
				UiHelper.showActivity(SplashActivity.this, Settings.getInstance().getAppState() == AppState.GUIDE ? GuideActivity.class : MainActivity.class);
				finish();
			}
		}, delay);
	}

	private void handleStart() {
		if (Settings.getInstance().getAppState() == AppState.DOWNLOAD) {
			handler.post(new Runnable() {
				@Override
				public void run() {
					new DataManager(progressChangedListener).load(SplashActivity.this);
				}
			});
		} else {
			showActivity((int) Math.max(0, WAIT_DELAY - (System.currentTimeMillis() - startTime)));
		}
	}
}
