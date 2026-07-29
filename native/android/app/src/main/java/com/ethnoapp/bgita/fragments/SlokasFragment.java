package com.ethnoapp.bgita.fragments;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.support.v4.graphics.drawable.DrawableCompat;
import android.support.v4.view.ViewPager;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.adapters.SlokaPagerAdapter;
import com.ethnoapp.bgita.database.Db;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.model.Sloka;
import com.ethnoapp.bgita.model.SlokaIds;
import com.ethnoapp.bgita.model.audio.AudioState;
import com.ethnoapp.bgita.model.audio.SanskritManager;
import com.ethnoapp.bgita.model.audio.TranslationManager;
import com.ethnoapp.bgita.screens.ToolbarActivity;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ethnoapp.bgita.utils.GitaUtils;
import com.ironwaterstudio.utils.GaUtils;
import com.ironwaterstudio.utils.SoundManager;

import java.util.ArrayList;
import java.util.List;

public class SlokasFragment extends Fragment {
	private Sloka sloka;
	private ImageView ivPlayPause;
	private TextView tvAudio;
	private RelativeLayout rlAudioPlayer;
	private ProgressBar progressBar;
	private ArrayList<SlokaIds> slokas = Sloka.getSortedIds();
	private boolean isBookmark;
	private SoundManager soundManager = null;
	private Handler handler = new Handler();

	private Drawable bookmarkDrawable;
	private Drawable noteDrawable;
	private int soundPosition = 0;
	private int oldPosition = -1;

	private ViewPager vpSlokas;
	private SlokaPagerAdapter adapter = null;

	private View.OnClickListener playPauseClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			ivPlayPause.setActivated(!ivPlayPause.isActivated());
			if (!soundManager.isInitialized()) {
				if (Settings.getInstance().getAppSettings().isAudioSanskrit()) {
					if (sloka.getAudioSanskrit() != null)
						soundManager.play(GitaUtils.getAudioFile(getContext(), AudioState.getAudioName(sloka.getAudioSanskrit())).getAbsolutePath());
				} else if (sloka.getAudio() != null) {
					soundManager.play(GitaUtils.getAudioFile(getContext(), AudioState.getAudioName(sloka.getAudio())).getAbsolutePath());
				}
			} else {
				soundManager.playPause(ivPlayPause.isActivated());
			}
			GaUtils.logEvent(UiConstants.GA_CATEGORY_UI, "Play or pause audio");
		}
	};

	private SoundManager.SoundListener soundListener = new SoundManager.SoundListener() {
		@Override
		public void onPrepare() {
			soundManager.seekTo(soundPosition);
			soundPosition = 0;
		}

		@Override
		public void onPlay(boolean isPlaying, int position) {
			ivPlayPause.setEnabled(true);
			if (isPlaying)
				soundRunnable.run();
			else
				handler.removeCallbacksAndMessages(null);
		}

		@Override
		public void onCompleted() {
			GaUtils.logEvent(UiConstants.GA_CATEGORY_UI, "Completed playing audio");
			ivPlayPause.setActivated(false);
			handler.removeCallbacksAndMessages(null);
			progressBar.setProgress(100);
			soundManager.release();
			if (Settings.getInstance().getAppSettings().isPlayAuto()) {
				if (!(slokas.get(slokas.size() - 1).getId() == sloka.getId())) {
					vpSlokas.setCurrentItem(vpSlokas.getCurrentItem() + 1);
					playPauseClickListener.onClick(ivPlayPause);
					GaUtils.logEvent(UiConstants.GA_CATEGORY_SHOW_SLOKA, "AutoPlay change sloka");
				}
			}
		}

		@Override
		public void onError() {
			//Empty
		}
	};

	ViewPager.OnPageChangeListener pageChangeListener = new ViewPager.OnPageChangeListener() {
		@Override
		public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
			//Empty
		}

		@Override
		public void onPageSelected(final int position) {
			sloka = Sloka.getSelectedSloka();
			if (oldPosition != -1 && oldPosition != position)
				setPrevNextSlokas(position > oldPosition ? 1 : -1);
			getContext().sendBroadcast(new Intent(UiConstants.ACTION_CHANGE_SELECTED_ID).putExtra(UiConstants.KEY_ID, sloka.getChapterId()));
			oldPosition = find(sloka);
			ivPlayPause.setActivated(false);
			progressBar.setProgress(0);
			if (soundManager != null)
				soundManager.release();
			showAudioPlayer();
			updateAudioTitle(position);
		}

		@Override
		public void onPageScrollStateChanged(int state) {
			//Empty
		}
	};

	private Runnable soundRunnable = new Runnable() {
		@Override
		public void run() {
			if (soundManager != null) {
				progressBar.setProgress(soundManager.getDuration() > 0 ? Math.round((float) soundManager.getCurrentPosition() / soundManager.getDuration() * 100) : 0);
				handleProgress();
			}
		}
	};

	private BroadcastReceiver changeSlokaBookmarkReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			if (getResources().getBoolean(R.bool.is_tablet))
				updateBookmark(intent.getIntExtra(UiConstants.KEY_ID, -1));
		}
	};

	private BroadcastReceiver moveReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			vpSlokas.setCurrentItem(vpSlokas.getCurrentItem() + intent.getIntExtra(UiConstants.KEY_DIR, 0));
		}
	};

	@Nullable
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle inState) {
		View v = inflater.inflate(R.layout.fragment_slokas, container, false);

		rlAudioPlayer = v.findViewById(R.id.rl_audio_player);
		ivPlayPause = v.findViewById(R.id.iv_play_pause);
		tvAudio = v.findViewById(R.id.tv_audio);
		progressBar = v.findViewById(R.id.progress_bar);
		vpSlokas = v.findViewById(R.id.vp_slokas);

		return v;
	}

	@Override
	public void onActivityCreated(Bundle inState) {
		super.onActivityCreated(inState);
		isBookmark = getArguments().getBoolean(UiConstants.KEY_IS_BOOKMARK, false);
		setHasOptionsMenu(true);

		adapter = new SlokaPagerAdapter(getChildFragmentManager());
		vpSlokas.setAdapter(adapter);
		vpSlokas.addOnPageChangeListener(pageChangeListener);
		int index = find(Settings.getInstance().getSelectedId());
		if (index == 0)
			pageChangeListener.onPageSelected(0);
		else
			vpSlokas.setCurrentItem(index);

		updateDrawableTint(getBookmarkDrawable(), sloka.isBookmark());
		updateDrawableTint(getNoteDrawable(), !TextUtils.isEmpty(sloka.getNote()));

		if (soundManager == null) {
			soundManager = new SoundManager(getContext());
			soundManager.addSoundListener(soundListener);
		}
		showAudioPlayer();
		if (inState != null) {
			soundPosition = inState.getInt(UiConstants.KEY_POS, -1);
			if (inState.getBoolean(UiConstants.KEY_PLAY_PAUSE, false))
				playPauseClickListener.onClick(ivPlayPause);
		}
	}

	@Override
	public void onResume() {
		super.onResume();
		if (!getContext().getResources().getBoolean(R.bool.is_tablet)) {
			((ToolbarActivity) getActivity()).getToolbar().setNavigationIcon(GitaUtils.getTintedDrawable(getContext(), R.drawable.ic_back, R.color.red_1));
			getActivity().setTitle(isBookmark ? R.string.to_bookmarks : R.string.table_of_contents);
		}
		getActivity().registerReceiver(moveReceiver, new IntentFilter(UiConstants.ACTION_SLOKA_MOVE));
		getActivity().registerReceiver(changeSlokaBookmarkReceiver, new IntentFilter(UiConstants.ACTION_CHANGE_BOOKMARK_SLOKA));
	}

	@Override
	public void onPause() {
		super.onPause();
		getActivity().unregisterReceiver(changeSlokaBookmarkReceiver);
		getActivity().unregisterReceiver(moveReceiver);
	}

	@Override
	public void onDestroy() {
		if (soundManager != null)
			soundManager.release();
		super.onDestroy();
	}

	@Override
	public void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
		if (soundManager != null && soundManager.isInitialized()) {
			outState.putInt(UiConstants.KEY_POS, soundManager.getCurrentPosition());
			outState.putBoolean(UiConstants.KEY_PLAY_PAUSE, ivPlayPause.isActivated());
		}
	}

	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
		super.onCreateOptionsMenu(menu, inflater);
		menu.findItem(R.id.action_note).setVisible(true).setIcon(getNoteDrawable());
		menu.findItem(R.id.action_bookmark).setVisible(true).setIcon(getBookmarkDrawable());
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			case R.id.action_note:
				NoteFragment.show(getContext(), getFragmentManager());
				GaUtils.logEvent(UiConstants.GA_CATEGORY_UI, "Edited user comment");
				return true;
			case R.id.action_bookmark:
				sloka.setBookmark(!sloka.isBookmark());
				Db.get().slokas().update(sloka);
				Db.get().saveChanges();
				updateDrawableTint(getBookmarkDrawable(), sloka.isBookmark());
				getContext().sendBroadcast(new Intent(UiConstants.ACTION_CHANGE_BOOKMARK));
				GaUtils.logEvent(UiConstants.GA_CATEGORY_UI, sloka.isBookmark() ? "Added bookmark" : "Removed bookmark");
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}

	public void showAudioPlayer() {
		TranslationManager.getInstance().queryDownloads();
		SanskritManager.getInstance().queryDownloads();
		if (Settings.getInstance().getAppSettings().isAudioTranslate() && TranslationManager.getInstance().isDownloaded()
				|| Settings.getInstance().getAppSettings().isAudioSanskrit() && SanskritManager.getInstance().isDownloaded()) {
			rlAudioPlayer.setVisibility(View.VISIBLE);
			ivPlayPause.setOnClickListener(playPauseClickListener);
			ivPlayPause.setActivated(false);
		}
	}

	public void updateBookmark(int id) {
		if (sloka.getId() == id)
			sloka.setBookmark(false);
		updateDrawableTint(getBookmarkDrawable(), sloka.isBookmark());
	}

	public int find(Sloka sloka) {
		return find(sloka.getId());
	}

	public int find(int slokaId) {
		for (int i = 0; i < slokas.size(); i++)
			if (slokaId == slokas.get(i).getId())
				return i;

		return 0;
	}

	private void setPrevNextSlokas(int dir) {
		int prevSlokaId = -1;
		int nextSlokaId = -1;
		for (int i = 0; i < slokas.size(); i++) {
			if (slokas.get(i).getId() == sloka.getId()) {
				prevSlokaId = i > 0 ? slokas.get(i - 1).getId() : -1;
				nextSlokaId = i < slokas.size() - 1 ? slokas.get(i + 1).getId() : -1;
			}
		}
		switch (dir) {
			case 1:
				if (nextSlokaId == -1)
					return;
				Settings.getInstance().setSelectedId(nextSlokaId);
				break;
			case -1:
				if (prevSlokaId == -1)
					return;
				Settings.getInstance().setSelectedId(prevSlokaId);
				break;
		}
		Settings.getInstance().save();
		sloka = Sloka.getSelectedSloka();
		updateDrawableTint(getBookmarkDrawable(), sloka.isBookmark());
		updateDrawableTint(getNoteDrawable(), !TextUtils.isEmpty(sloka.getNote()));
	}

	private Drawable getBookmarkDrawable() {
		if (bookmarkDrawable == null)
			bookmarkDrawable = GitaUtils.getTintedDrawable(getContext(), R.drawable.ic_bookmark, R.color.gray_3);
		return bookmarkDrawable;
	}

	private Drawable getNoteDrawable() {
		if (noteDrawable == null)
			noteDrawable = GitaUtils.getTintedDrawable(getContext(), R.drawable.ic_note, R.color.gray_3);
		return noteDrawable;
	}

	private void updateDrawableTint(Drawable drawable, boolean condition) {
		DrawableCompat.setTint(drawable, ContextCompat.getColor(getContext(), condition ? getResources().getBoolean(R.bool.is_tablet) ? R.color.white : R.color.red_1 : R.color.gray_3));
	}

	private void handleProgress() {
		handler.postDelayed(soundRunnable, 500);
	}

	private void updateAudioTitle(final int position) {
		String audioTitle = getAudioTitle(position);
		if (audioTitle != null) {
			tvAudio.setText(audioTitle);
			return;
		}

		getChildFragmentManager().registerFragmentLifecycleCallbacks(new FragmentManager.FragmentLifecycleCallbacks() {
			@Override
			public void onFragmentActivityCreated(FragmentManager fm, Fragment f, Bundle savedInstanceState) {
				super.onFragmentActivityCreated(fm, f, savedInstanceState);
				if (f instanceof SlokaFragment && ((SlokaFragment) f).getPosition() == position) {
					tvAudio.setText(((SlokaFragment) f).getAudioTitle());
					getChildFragmentManager().unregisterFragmentLifecycleCallbacks(this);
				}
			}
		}, false);
	}

	private String getAudioTitle(int position) {
		List<Fragment> fragments = getChildFragmentManager().getFragments();
		for (Fragment item : fragments) {
			if (item instanceof SlokaFragment && ((SlokaFragment) item).getPosition() == position)
				return ((SlokaFragment) item).getAudioTitle();
		}
		return null;
	}

	public static void show(Context context, FragmentManager fm, boolean isBookmark) {
		if (context.getResources().getBoolean(R.bool.is_tablet) && !(fm.findFragmentById(R.id.container_right) instanceof SlokasFragment))
			fm.popBackStack();
		SlokasFragment slokasFragment = new SlokasFragment();
		Bundle args = new Bundle();
		args.putBoolean(UiConstants.KEY_IS_BOOKMARK, isBookmark);
		slokasFragment.setArguments(args);
		FragmentTransaction ft = fm.beginTransaction()
				.replace(GitaUtils.getRightContainer(context), slokasFragment);
		if (!context.getResources().getBoolean(R.bool.is_tablet))
			ft.addToBackStack(null);
		ft.commitAllowingStateLoss();
	}
}