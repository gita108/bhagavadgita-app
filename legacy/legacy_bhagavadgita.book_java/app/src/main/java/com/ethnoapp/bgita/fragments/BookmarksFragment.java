package com.ethnoapp.bgita.fragments;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
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
import com.ethnoapp.bgita.decorations.DividerDecoration;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.model.SlokaInfo;
import com.ethnoapp.bgita.screens.ToolbarActivity;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ironwaterstudio.server.ActionRequest;
import com.ironwaterstudio.server.data.ApiResult;
import com.ironwaterstudio.server.listeners.CallListener;
import com.ironwaterstudio.utils.GaUtils;

import java.util.ArrayList;

public class BookmarksFragment extends Fragment {
	private View emptyView;
	private RecyclerView rvBookmarks;
	private BookmarksAdapter adapter;
	private String searchText;
	private ArrayList<SlokaInfo> bookmarks;

	private BroadcastReceiver deleteReceiver = new BroadcastReceiver() {
		@SuppressWarnings("unchecked")
		@Override
		public void onReceive(Context context, Intent intent) {
			int pos = intent.getIntExtra(UiConstants.KEY_POS, -1);
			SlokaInfo slokaInfo = adapter.removeItem(pos);
			bookmarks.remove(slokaInfo);
			getContext().sendBroadcast(new Intent(UiConstants.ACTION_CHANGE_BOOKMARK_SLOKA).putExtra(UiConstants.KEY_ID, slokaInfo.getId()));
		}
	};

	private BroadcastReceiver searchReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			searchText = intent.getStringExtra(UiConstants.KEY_SEND_SEARCH_TEXT);
			filterListener.cancelLoad();
			if (TextUtils.isEmpty(searchText)) {
				adapter.animateTo(bookmarks);
				emptyView.setVisibility(bookmarks.isEmpty() ? View.VISIBLE : View.GONE);
			} else {
				filterRequest.call(filterListener);
			}
		}
	};

	private BroadcastReceiver changeNoteReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			updateNote();
		}
	};

	private BroadcastReceiver changeBookmarkReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			changeBookmark();
		}
	};

	private ActionRequest filterRequest = new ActionRequest(new ActionRequest.Runnable() {
		@Override
		public Object run() {
			ArrayList<SlokaInfo> filteredItems = new ArrayList<>();
			for (SlokaInfo slokaInfo : bookmarks) {
				if (String.format("%s %s", slokaInfo.getSlokaName(), slokaInfo.getChapterName()).toLowerCase().contains(searchText.toLowerCase())
						|| slokaInfo.getNote() != null && slokaInfo.getNote().toLowerCase().contains(searchText.toLowerCase()))
					filteredItems.add(slokaInfo);
			}
			return ApiResult.fromObject(filteredItems);
		}
	});

	private CallListener filterListener = new CallListener(false) {
		@SuppressWarnings("unchecked")
		@Override
		public void onSuccess(ApiResult result) {
			super.onSuccess(result);
			ArrayList<SlokaInfo> filteredItems = (ArrayList<SlokaInfo>) result.getObject();
			adapter.animateTo(filteredItems);
			emptyView.setVisibility(filteredItems.isEmpty() ? View.VISIBLE : View.GONE);
		}
	};

	@Nullable
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle inState) {
		View v = inflater.inflate(R.layout.fragment_bookmarks, container, false);
		rvBookmarks = v.findViewById(R.id.rv_bookmarks);
		emptyView = v.findViewById(R.id.empty_view);

		return v;
	}

	@Override
	public void onActivityCreated(Bundle inState) {
		super.onActivityCreated(inState);
		((ToolbarActivity) getActivity()).getToolbar().setNavigationIcon(R.drawable.ic_back);
		getActivity().setTitle(R.string.bookmarks);
		setHasOptionsMenu(true);
		rvBookmarks.addItemDecoration(new DividerDecoration(getContext(), R.color.gray_4, R.dimen.divider_height, 0, DividerDecoration.MIDDLE | DividerDecoration.BOTTOM));
		adapter = new BookmarksAdapter(getContext(), new ArrayList<SlokaInfo>(), true);
		rvBookmarks.setAdapter(adapter);
		filterListener.register(this);

		setData();
	}

	@Override
	public void onResume() {
		super.onResume();
		getActivity().registerReceiver(searchReceiver, new IntentFilter(UiConstants.ACTION_SEARCH));
		getActivity().registerReceiver(deleteReceiver, new IntentFilter(UiConstants.ACTION_DELETE_BOOKMARK));
		getActivity().registerReceiver(changeNoteReceiver, new IntentFilter(UiConstants.ACTION_CHANGE_NOTE));
		getActivity().registerReceiver(changeBookmarkReceiver, new IntentFilter(UiConstants.ACTION_CHANGE_BOOKMARK));
	}

	@Override
	public void onPause() {
		super.onPause();
		getActivity().unregisterReceiver(changeBookmarkReceiver);
		getActivity().unregisterReceiver(changeNoteReceiver);
		getActivity().unregisterReceiver(deleteReceiver);
		getActivity().unregisterReceiver(searchReceiver);
	}

	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
		menu.findItem(R.id.action_search).setVisible(true);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			case R.id.action_search:
				GaUtils.logEvent(UiConstants.GA_CATEGORY_UI, "Click bookmarks search");
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}

	public void changeBookmark() {
		for (SlokaInfo slokaInfo : bookmarks)
			if (slokaInfo.getId() == Settings.getInstance().getSelectedId()) {
				bookmarks.remove(slokaInfo);
				adapter.animateTo(bookmarks);
				return;
			}
		SlokaInfo slokaInfo = SlokaInfo.getSlokaInfo(Settings.getInstance().getSelectedId());
		for (int i = 0; i < bookmarks.size(); i++) {
			if (bookmarks.get(i).getChapterOrder() > slokaInfo.getChapterOrder()
					|| bookmarks.get(i).getChapterOrder() == slokaInfo.getChapterOrder() && bookmarks.get(i).getSlokaOrder() > slokaInfo.getSlokaOrder()) {
				bookmarks.add(i, slokaInfo);
				adapter.animateTo(bookmarks);
				return;
			}
		}
		bookmarks.add(slokaInfo);
		adapter.animateTo(bookmarks);
	}

	public void updateNote() {
		SlokaInfo slokaInfo = SlokaInfo.getSlokaInfo(Settings.getInstance().getSelectedId());
		for (int i = 0; i < bookmarks.size(); i++)
			if (bookmarks.get(i).getId() == slokaInfo.getId()) {
				bookmarks.remove(i);
				bookmarks.add(i, slokaInfo);
				adapter.animateTo(bookmarks);
				return;
			}
	}

	private void setData() {
		bookmarks = SlokaInfo.getBookmarksList();
		adapter.animateTo(bookmarks);
		rvBookmarks.setVisibility(bookmarks.isEmpty() ? View.GONE : View.VISIBLE);
		emptyView.setVisibility(bookmarks.isEmpty() ? View.VISIBLE : View.GONE);
	}

	public static void show(FragmentManager fm) {
		BookmarksFragment bookmarksFragment = new BookmarksFragment();
		fm.beginTransaction().replace(R.id.container, bookmarksFragment).addToBackStack(null).commitAllowingStateLoss();
	}
}
