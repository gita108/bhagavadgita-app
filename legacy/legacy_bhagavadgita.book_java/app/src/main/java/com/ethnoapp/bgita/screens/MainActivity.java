package com.ethnoapp.bgita.screens;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.content.ContextCompat;
import android.view.Menu;
import android.view.MenuItem;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.controls.SearchPanelView;
import com.ethnoapp.bgita.fragments.BookmarksFragment;
import com.ethnoapp.bgita.fragments.ChaptersFragment;
import com.ethnoapp.bgita.fragments.NoteFragment;
import com.ethnoapp.bgita.fragments.SlokasFragment;
import com.ethnoapp.bgita.model.Settings;
import com.ironwaterstudio.utils.GaUtils;
import com.ironwaterstudio.utils.UiHelper;

public class MainActivity extends ToolbarActivity {
	private SearchPanelView searchPanelView;

	private BroadcastReceiver showSlokaReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			SlokasFragment.show(MainActivity.this, getSupportFragmentManager(), intent.getBooleanExtra(UiConstants.KEY_IS_BOOKMARK, false));
		}
	};

	private FragmentManager.FragmentLifecycleCallbacks fragmentLifecycleCallbacks = new FragmentManager.FragmentLifecycleCallbacks() {
		@Override
		public void onFragmentStarted(FragmentManager fm, Fragment f) {
			super.onFragmentStarted(fm, f);
			if (f instanceof SlokasFragment && !getResources().getBoolean(R.bool.is_tablet)) {
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
					getWindow().setStatusBarColor(ContextCompat.getColor(MainActivity.this, R.color.black_20));
				getToolbar().setBackgroundColor(getResources().getColor(R.color.white));
				setTextColorId(R.color.red_1);
			}
		}

		@Override
		public void onFragmentStopped(FragmentManager fm, Fragment f) {
			super.onFragmentStopped(fm, f);
			if (!getResources().getBoolean(R.bool.is_tablet) || f instanceof BookmarksFragment) {
				if (searchPanelView.isOpen())
					searchPanelView.close();
			}
			if (f instanceof SlokasFragment && !getResources().getBoolean(R.bool.is_tablet)) {
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
					getWindow().setStatusBarColor(ContextCompat.getColor(MainActivity.this, R.color.red_3));
				getToolbar().setBackgroundColor(getResources().getColor(R.color.red_1));
				setTextColorId(R.color.white);
			}
		}

		@Override
		public void onFragmentViewDestroyed(FragmentManager fm, Fragment f) {
			super.onFragmentViewDestroyed(fm, f);
			if (getResources().getBoolean(R.bool.is_tablet) && f instanceof NoteFragment) {
				Fragment fragment = fm.findFragmentById(R.id.container);
				getToolbar().setNavigationIcon(fragment instanceof ChaptersFragment ? R.drawable.ic_settings : R.drawable.ic_back);
				setTitle(fragment instanceof ChaptersFragment ? R.string.app_name : R.string.bookmarks);
			}
		}
	};

	public MainActivity() {
		super(R.layout.activity_main);
	}

	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		searchPanelView = findViewById(R.id.search_panel_view);
		if (savedInstanceState == null)
			getSupportFragmentManager().beginTransaction().replace(R.id.container, new ChaptersFragment()).commitAllowingStateLoss();
		if (savedInstanceState == null && getResources().getBoolean(R.bool.is_tablet) && Settings.getInstance().getSelectedId() != -1)
			SlokasFragment.show(this, getSupportFragmentManager(), false);
		getSupportFragmentManager().registerFragmentLifecycleCallbacks(fragmentLifecycleCallbacks, false);
		if (savedInstanceState != null) {
			if (savedInstanceState.getBoolean(UiConstants.KEY_SEARCH_OPEN)) {
				UiHelper.onGlobalLayout(searchPanelView, new Runnable() {
					@Override
					public void run() {
						searchPanelView.open();
						searchPanelView.setSearchText(savedInstanceState.getString(UiConstants.KEY_SEARCH_TEXT));
					}
				});
			}
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.menus, menu);
		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			case android.R.id.home:
				if (getSupportFragmentManager().getBackStackEntryCount() == 0) {
					UiHelper.showActivity(this, SettingsActivity.class);
					return true;
				}
				return super.onOptionsItemSelected(item);
			case R.id.action_bookmarks:
				setTitle(R.string.bookmarks);
				getToolbar().setNavigationIcon(R.drawable.ic_back);
				return false;
			case R.id.action_search:
				searchPanelView.open();
				GaUtils.logEvent(UiConstants.GA_CATEGORY_UI, "Click global search");
				return true;
			case R.id.action_note:
				setTitle(R.string.note);
				getToolbar().setNavigationIcon(R.drawable.ic_back);
				return false;
			default:
				return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public void onBackPressed() {
		if (getSupportFragmentManager().getBackStackEntryCount() > 0) {
			getSupportFragmentManager().popBackStack();
			return;
		}
		super.onBackPressed();
	}

	@Override
	protected void onStart() {
		super.onStart();
		registerReceiver(showSlokaReceiver, new IntentFilter(UiConstants.ACTION_SHOW_SLOKA));
	}

	@Override
	protected void onStop() {
		super.onStop();
		unregisterReceiver(showSlokaReceiver);
	}

	@Override
	protected void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
		outState.putBoolean(UiConstants.KEY_SEARCH_OPEN, searchPanelView.isOpen());
		outState.putString(UiConstants.KEY_SEARCH_TEXT, searchPanelView.getSearchText());
	}

	@Override
	protected void onNewIntent(final Intent intent) {
		searchPanelView.handleIntent(intent);
	}
}