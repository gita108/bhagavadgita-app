package com.ethnoapp.bgita.screens;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SwitchCompat;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.adapters.BooksAdapter;
import com.ethnoapp.bgita.decorations.DividerDecoration;
import com.ethnoapp.bgita.model.AppSettings;
import com.ethnoapp.bgita.model.Book;
import com.ethnoapp.bgita.model.BookManager;
import com.ethnoapp.bgita.model.Books;
import com.ethnoapp.bgita.model.IFinished;
import com.ethnoapp.bgita.model.Language;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.model.audio.SanskritManager;
import com.ethnoapp.bgita.model.audio.TranslationManager;
import com.ethnoapp.bgita.server.DataService;
import com.ironwaterstudio.controls.ImageViewEx;
import com.ironwaterstudio.controls.ProgressDrawable;
import com.ironwaterstudio.dialogs.AlertFragment;
import com.ironwaterstudio.server.data.ApiResult;
import com.ironwaterstudio.server.listeners.CallListener;
import com.ironwaterstudio.utils.GaUtils;
import com.ironwaterstudio.utils.UiHelper;

import java.util.ArrayList;
import java.util.Arrays;

public class SettingsActivity extends ToolbarActivity {
	private static final int QUERY_INTERVAL = 3000;

	private final Handler handler = new Handler();
	private SwitchCompat swShowSanskrit;
	private SwitchCompat swShowTranscription;
	private SwitchCompat swShowTranslation;
	private SwitchCompat swShowComments;
	private SwitchCompat swAudioSanskrit;
	private SwitchCompat swAudioTranslation;
	private SwitchCompat swAudioPlayAuto;
	private ImageViewEx ivTranslationProgress;
	private ImageViewEx ivSanskritProgress;
	private LinearLayout btnLanguages;
	private TextView tvLanguages;
	private RecyclerView rvBooks;
	private BooksAdapter adapter;
	private AppSettings appSettings = Settings.getInstance().getAppSettings();
	private ArrayList<Language> languages = Language.getList();
	private Books books;

	private BroadcastReceiver completeEnqueueReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			queryDownloads();
		}
	};

	private CompoundButton.OnCheckedChangeListener onCheckedChangeListener = new CompoundButton.OnCheckedChangeListener() {
		@Override
		public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
			switch (buttonView.getId()) {
				case R.id.sw_show_sanskrit:
					appSettings.setShowSanskrit(isChecked);
					GaUtils.logEvent(UiConstants.GA_CATEGORY_SETTINGS, "Turn on/off sanskrit");
					break;
				case R.id.sw_show_transcription:
					appSettings.setShowTranscription(isChecked);
					GaUtils.logEvent(UiConstants.GA_CATEGORY_SETTINGS, "Turn on/off transcription");
					break;
				case R.id.sw_show_translation:
					appSettings.setShowTranslate(isChecked);
					GaUtils.logEvent(UiConstants.GA_CATEGORY_SETTINGS, "Turn on/off translation");
					break;
				case R.id.sw_show_comments:
					appSettings.setShowCommentary(isChecked);
					GaUtils.logEvent(UiConstants.GA_CATEGORY_SETTINGS, "Turn on/off comments");
					break;
				case R.id.sw_audio_translation:
					appSettings.setAudioTranslate(isChecked);
					if (isChecked) {
						if (!TranslationManager.getInstance().isDownloaded())
							showTranslationDownload();
					} else {
						showTranslationDelete();
					}
					break;
				case R.id.sw_audio_sanskrit:
					appSettings.setAudioSanskrit(isChecked);
					if (isChecked) {
						if (!SanskritManager.getInstance().isDownloaded())
							showSanskritDownload();
					} else {
						showSanskritDelete();
					}
					break;
				case R.id.sw_audio_play_auto:
					appSettings.setPlayAuto(isChecked);
					GaUtils.logEvent(UiConstants.GA_CATEGORY_SETTINGS, "Turn on/off play auto");
					break;
			}
			Settings.getInstance().save();
		}
	};

	private CallListener getBooksListener = new CallListener(true) {
		@Override
		protected void onSuccess(ApiResult result) {
			super.onSuccess(result);
			books = result.getData(Books.class);
			Book.merge(books, Language.getLanguageIds(languages));
			adapter = new BooksAdapter(getActivity(), books);
			rvBooks.setAdapter(adapter);
		}
	};

	private View.OnClickListener languagesClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			UiHelper.showActivity(SettingsActivity.this, LanguagesActivity.class, UiConstants.REQ_LANGUAGES);
		}
	};

	private IFinished iFinished = new IFinished() {
		@Override
		public void onFinished(Book book) {
			if (adapter == null)
				return;

			int index = adapter.indexAt(book.getId());
			if (index != -1) {
				adapter.getItem(index).setStatus(book.getStatus());
				adapter.notifyItemChanged(adapter.toNotifyPosition(index));
			}
		}
	};

	public SettingsActivity() {
		super(R.layout.activity_settings);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setTitle(R.string.settings);
		getBooksListener.register(this);
		TranslationManager.getInstance().processStates();
		SanskritManager.getInstance().processStates();
		BookManager.getInstance().setILoaded(iFinished);

		swShowSanskrit = findViewById(R.id.sw_show_sanskrit);
		swShowTranscription = findViewById(R.id.sw_show_transcription);
		swShowTranslation = findViewById(R.id.sw_show_translation);
		swShowComments = findViewById(R.id.sw_show_comments);
		swAudioSanskrit = findViewById(R.id.sw_audio_sanskrit);
		swAudioTranslation = findViewById(R.id.sw_audio_translation);
		swAudioPlayAuto = findViewById(R.id.sw_audio_play_auto);
		ivTranslationProgress = findViewById(R.id.iv_translation_progress);
		ivSanskritProgress = findViewById(R.id.iv_sanskrit_progress);
		btnLanguages = findViewById(R.id.btn_languages);
		tvLanguages = findViewById(R.id.tv_languages);
		rvBooks = findViewById(R.id.rv_books);

		btnLanguages.setOnClickListener(languagesClickListener);
		rvBooks.setNestedScrollingEnabled(false);
		rvBooks.getLayoutManager().setAutoMeasureEnabled(true);
		rvBooks.addItemDecoration(new DividerDecoration(this, R.color.gray_4, R.dimen.divider_height, 0, DividerDecoration.MIDDLE | DividerDecoration.BOTTOM));

		setData();
		DataService.getBooks(Language.getLanguageIds(languages), false, getBooksListener);
	}

	@Override
	protected void onStart() {
		super.onStart();
		registerReceiver(completeEnqueueReceiver, new IntentFilter(UiConstants.ACTION_COMPLETE_ENQUEUE));
		queryDownloads();
		if (appSettings.isAudioTranslate() && !TranslationManager.getInstance().isDownloaded()) {
			showTranslationProgress(true);
			TranslationManager.getInstance().completeDownload();
		}
		if (appSettings.isAudioSanskrit() && !SanskritManager.getInstance().isDownloaded()) {
			showSanskritProgress(true);
			SanskritManager.getInstance().completeDownload();
		}
	}

	@Override
	protected void onStop() {
		super.onStop();
		unregisterReceiver(completeEnqueueReceiver);
		handler.removeCallbacksAndMessages(null);
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		BookManager.getInstance().setILoaded(null);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode != Activity.RESULT_OK)
			return;
		switch (requestCode) {
			case UiConstants.REQ_LANGUAGES:
				ArrayList<Language> languages = Language.getList();
				ArrayList<Integer> languageIds = Language.getLanguageIds(languages);
				if (!Arrays.equals(Language.getLanguageIds(this.languages).toArray(), languageIds.toArray())) {
					this.languages = languages;
					tvLanguages.setText(Language.getLanguagesText(languages));
					if (adapter != null)
						adapter.clear();
					DataService.getBooks(languageIds, false, getBooksListener);
				}
				break;
		}
	}

	private void setData() {
		tvLanguages.setText(Language.getLanguagesText(languages));
		swShowSanskrit.setChecked(appSettings.isShowSanskrit());
		swShowTranscription.setChecked(appSettings.isShowTranscription());
		swShowTranslation.setChecked(appSettings.isShowTranslate());
		swShowComments.setChecked(appSettings.isShowCommentary());
		swAudioSanskrit.setChecked(appSettings.isAudioSanskrit());
		swAudioTranslation.setChecked(appSettings.isAudioTranslate());
		if (TranslationManager.getInstance().isEmpty())
			swAudioTranslation.setEnabled(false);
		if (SanskritManager.getInstance().isEmpty())
			swAudioSanskrit.setEnabled(false);
		swAudioPlayAuto.setChecked(appSettings.isPlayAuto());
		swShowSanskrit.setOnCheckedChangeListener(onCheckedChangeListener);
		swShowTranscription.setOnCheckedChangeListener(onCheckedChangeListener);
		swShowTranslation.setOnCheckedChangeListener(onCheckedChangeListener);
		swShowComments.setOnCheckedChangeListener(onCheckedChangeListener);
		swAudioSanskrit.setOnCheckedChangeListener(onCheckedChangeListener);
		swAudioTranslation.setOnCheckedChangeListener(onCheckedChangeListener);
		swAudioPlayAuto.setOnCheckedChangeListener(onCheckedChangeListener);
	}

	private void showTranslationDownload() {
		AlertFragment.create().setMessage(R.string.translation_download).setPositiveListener(new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				appSettings.setAudioTranslate(true);
				TranslationManager.getInstance().download();
				showTranslationProgress(true);
				Settings.getInstance().save();
				GaUtils.logEvent(UiConstants.GA_CATEGORY_DOWNLOAD, "Download audio from settings");
			}
		}).setNegativeListener(new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				swAudioTranslation.setOnCheckedChangeListener(null);
				swAudioTranslation.setChecked(false);
				swAudioTranslation.setOnCheckedChangeListener(onCheckedChangeListener);
				appSettings.setAudioTranslate(false);
				Settings.getInstance().save();
				GaUtils.logEvent(UiConstants.GA_CATEGORY_DOWNLOAD, "Cancel download audio from settings");
			}
		}).show(SettingsActivity.this);
	}

	private void showTranslationDelete() {
		AlertFragment.create().setMessage(R.string.translation_delete).setPositiveListener(new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				TranslationManager.getInstance().delete();
				appSettings.setAudioTranslate(false);
				Settings.getInstance().save();
				GaUtils.logEvent(UiConstants.GA_CATEGORY_AUDIO, "Remove audio translation");
			}
		}).setNegativeListener(new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				appSettings.setAudioTranslate(false);
				Settings.getInstance().save();
				GaUtils.logEvent(UiConstants.GA_CATEGORY_AUDIO, "Cancel remove audio translation");
			}
		}).show(SettingsActivity.this);
	}

	private void showSanskritDownload() {
		AlertFragment.create().setMessage(R.string.sanskrit_download).setPositiveListener(new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				appSettings.setAudioSanskrit(true);
				SanskritManager.getInstance().download();
				showSanskritProgress(true);
				Settings.getInstance().save();
				GaUtils.logEvent(UiConstants.GA_CATEGORY_DOWNLOAD, "Download audio sanskrit");
			}
		}).setNegativeListener(new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				swAudioSanskrit.setOnCheckedChangeListener(null);
				swAudioSanskrit.setChecked(false);
				swAudioSanskrit.setOnCheckedChangeListener(onCheckedChangeListener);
				appSettings.setAudioSanskrit(false);
				Settings.getInstance().save();
				GaUtils.logEvent(UiConstants.GA_CATEGORY_DOWNLOAD, "Cancel download audio sanskrit");
			}
		}).show(SettingsActivity.this);
	}

	private void showSanskritDelete() {
		AlertFragment.create().setMessage(R.string.sanskrit_delete).setPositiveListener(new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				SanskritManager.getInstance().delete();
				appSettings.setAudioSanskrit(false);
				Settings.getInstance().save();
				GaUtils.logEvent(UiConstants.GA_CATEGORY_AUDIO, "Remove audio sanskrit");
			}
		}).setNegativeListener(new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				appSettings.setAudioSanskrit(false);
				Settings.getInstance().save();
				GaUtils.logEvent(UiConstants.GA_CATEGORY_AUDIO, "Cancel remove audio sanskrit");
			}
		}).show(SettingsActivity.this);
	}

	private void showTranslationProgress(boolean show) {
		ivTranslationProgress.setVisibility(show ? View.VISIBLE : View.GONE);
		ivTranslationProgress.setImageDrawableDefault(show ? buildProgress(ivTranslationProgress) : null);
		if (!TranslationManager.getInstance().isEmpty())
			swAudioTranslation.setEnabled(!show);
	}

	private void showSanskritProgress(boolean show) {
		ivSanskritProgress.setVisibility(show ? View.VISIBLE : View.GONE);
		ivSanskritProgress.setImageDrawableDefault(show ? buildProgress(ivSanskritProgress) : null);
		if (!SanskritManager.getInstance().isEmpty())
			swAudioSanskrit.setEnabled(!show);
	}

	private void queryDownloads() {
		handler.removeCallbacksAndMessages(null);
		boolean existTranslationDownloads = TranslationManager.getInstance().queryDownloads();
		boolean existSanskritDownloads = SanskritManager.getInstance().queryDownloads();
		if (!existTranslationDownloads)
			showTranslationProgress(false);
		if (!existSanskritDownloads)
			showSanskritProgress(false);
		if (!existTranslationDownloads && !existSanskritDownloads)
			return;

		handler.postDelayed(new Runnable() {
			@Override
			public void run() {
				queryDownloads();
			}
		}, QUERY_INTERVAL);
	}

	private static ProgressDrawable buildProgress(View parent) {
		ProgressDrawable drawable = new ProgressDrawable(parent);
		drawable.setSize(21f);
		drawable.setStrokeWidth(2f);
		drawable.start();
		return drawable;
	}
}