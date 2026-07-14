package com.ethnoapp.bgita.fragments;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.adapters.BookmarksAdapter;
import com.ethnoapp.bgita.adapters.ChaptersAdapter;
import com.ethnoapp.bgita.adapters.holders.ChapterHolder;
import com.ethnoapp.bgita.controls.SnapToStartScroller;
import com.ethnoapp.bgita.decorations.DividerDecoration;
import com.ethnoapp.bgita.model.Chapter;
import com.ethnoapp.bgita.model.Quote;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.model.SlokaInfo;
import com.ethnoapp.bgita.screens.ToolbarActivity;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ethnoapp.bgita.server.DataService;
import com.ironwaterstudio.server.Request;
import com.ironwaterstudio.server.data.ApiResult;
import com.ironwaterstudio.server.listeners.CallListener;
import com.ironwaterstudio.utils.GaUtils;

import java.util.ArrayList;

public class ChaptersFragment extends Fragment {
	private View emptyView;
	private RecyclerView rvChapters;
	private RecyclerView rvSearch;
	private Handler handler = new Handler();
	private BookmarksAdapter adapterSearch;
	private ChaptersAdapter adapter;
	private Quote quote = null;
	private long startTime = -1;
	private ArrayList<SlokaInfo> searchSlokas;
	private String searchText;

	private BroadcastReceiver expandReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(final Context context, final Intent intent) {
			handler.removeCallbacksAndMessages(null);
			handler.postDelayed(new Runnable() {
				@Override
				public void run() {
					RecyclerView.SmoothScroller smoothScroller = new SnapToStartScroller(context);
					smoothScroller.setTargetPosition(intent.getIntExtra(UiConstants.KEY_POS, 0));
					rvChapters.getLayoutManager().startSmoothScroll(smoothScroller);
				}
			}, ChapterHolder.EXPAND_DURATION);
		}
	};

	private BroadcastReceiver changeBookmarkReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			updateBookmark();
		}
	};

	private BroadcastReceiver changeSelectedIdReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			updateSelectedId();
			if (getChapterId() != intent.getIntExtra(UiConstants.KEY_ID, -1))
				expand(intent.getIntExtra(UiConstants.KEY_ID, -1));
		}
	};

	private CallListener getQuoteCallListener = new CallListener(false) {
		@Override
		protected void onSuccess(ApiResult result) {
			super.onSuccess(result);
			adapter.setHeader(quote = result.getData(Quote.class));
			if (startTime == -1 || (System.currentTimeMillis() - startTime) > 200)
				return;

			RecyclerView.SmoothScroller smoothScroller = new SnapToStartScroller(getContext());
			smoothScroller.setTargetPosition(0);
			rvChapters.getLayoutManager().startSmoothScroll(smoothScroller);
		}

		@Override
		protected void showError(Request request, ApiResult result) {
		}
	};

	private BroadcastReceiver searchSlokasReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			searchText = intent.getStringExtra(UiConstants.KEY_SEND_SEARCH_TEXT);
			search();
		}
	};

	@Nullable
	@Override
	public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
		View v = inflater.inflate(R.layout.fragment_main, container, false);
		rvChapters = v.findViewById(R.id.rv_chapters);
		rvSearch = v.findViewById(R.id.rv_search);
		emptyView = v.findViewById(R.id.empty_view);
		return v;
	}

	@Override
	public void onActivityCreated(@Nullable Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		((ToolbarActivity) getActivity()).getToolbar().setNavigationIcon(R.drawable.ic_settings);
		getActivity().setTitle(R.string.app_name);
		setHasOptionsMenu(true);
		int expandedId = savedInstanceState != null ? savedInstanceState.getInt(UiConstants.KEY_ID) : adapter != null ? adapter.getExpandedId() : -1;
		quote = savedInstanceState != null ? (Quote) savedInstanceState.getSerializable(UiConstants.KEY_QUOTE) : quote;

		rvChapters.setAdapter(adapter = new ChaptersAdapter(getContext(), Chapter.getList(Settings.getInstance().getBookId())));
		rvChapters.addItemDecoration(new DividerDecoration(getContext(), R.color.gray_4, R.dimen.divider_height, 0, DividerDecoration.MIDDLE | DividerDecoration.BOTTOM));
		rvSearch.setAdapter(adapterSearch = new BookmarksAdapter(getContext(), new ArrayList<SlokaInfo>(), false));
		rvSearch.addItemDecoration(new DividerDecoration(getContext(), R.color.gray_4, R.dimen.divider_height, 0, DividerDecoration.MIDDLE | DividerDecoration.BOTTOM));

		adapter.setExpandedId(expandedId);
		getQuoteCallListener.register(this);
		startTime = savedInstanceState == null ? System.currentTimeMillis() : -1;
		if (savedInstanceState != null) {
			if (savedInstanceState.getString(UiConstants.KEY_SEARCH_TEXT) != null) {
				searchText = savedInstanceState.getString(UiConstants.KEY_SEARCH_TEXT);
				search();
			}
		}
		if (quote == null)
			DataService.getQuote(getQuoteCallListener);
		else
			adapter.setHeader(quote);
	}

	@Override
	public void onResume() {
		super.onResume();
		getActivity().registerReceiver(expandReceiver, new IntentFilter(UiConstants.ACTION_EXPAND));
		getActivity().registerReceiver(changeBookmarkReceiver, new IntentFilter(UiConstants.ACTION_CHANGE_BOOKMARK));
		getActivity().registerReceiver(changeSelectedIdReceiver, new IntentFilter(UiConstants.ACTION_CHANGE_SELECTED_ID));
		getActivity().registerReceiver(searchSlokasReceiver, new IntentFilter(UiConstants.ACTION_SEARCH));
	}

	@Override
	public void onPause() {
		super.onPause();
		getActivity().unregisterReceiver(searchSlokasReceiver);
		getActivity().unregisterReceiver(changeSelectedIdReceiver);
		getActivity().unregisterReceiver(changeBookmarkReceiver);
		getActivity().unregisterReceiver(expandReceiver);
	}

	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
		super.onCreateOptionsMenu(menu, inflater);
		menu.findItem(R.id.action_search).setVisible(true);
		menu.findItem(R.id.action_bookmarks).setVisible(true);

	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			case R.id.action_bookmarks:
				BookmarksFragment.show(getFragmentManager());
				GaUtils.logEvent(UiConstants.GA_CATEGORY_UI, "Click bookmarks");
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
		outState.putInt(UiConstants.KEY_ID, adapter.getExpandedId());
		outState.putSerializable(UiConstants.KEY_QUOTE, quote);
		outState.putString(UiConstants.KEY_SEARCH_TEXT, searchText);
	}

	public void updateBookmark() {
		adapter.changeBookmark();
	}

	public void updateSelectedId() {
		adapter.upToDateSelection();
	}

	public void expand(int id) {
		boolean visible = false;
		for (int i = 0; i < rvChapters.getChildCount(); i++) {
			if (i == 0 && adapter.getHeader() != null)
				continue;
			ChapterHolder holder = (ChapterHolder) rvChapters.getChildViewHolder(rvChapters.getChildAt(i));
			if (holder != null && holder.getObject().getId() == id) {
				visible = true;
				break;
			}
		}
		adapter.setExpandedIdWithExpand(id, visible);
	}

	public int getChapterId() {
		return adapter.getExpandedId();
	}

	public void search() {
		if (!TextUtils.isEmpty(searchText)) {
			searchSlokas = SlokaInfo.getFindSlokaInfos(searchText);
			rvSearch.setVisibility(!searchSlokas.isEmpty() ? View.VISIBLE : View.GONE);
			emptyView.setVisibility(searchSlokas.isEmpty() ? View.VISIBLE : View.GONE);
			rvChapters.setVisibility(View.GONE);
			adapterSearch.animateTo(searchSlokas);
		} else {
			rvSearch.setVisibility(View.GONE);
			rvChapters.setVisibility(View.VISIBLE);
			emptyView.setVisibility(View.GONE);
		}
	}
}