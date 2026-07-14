package com.ethnoapp.bgita.adapters;

import android.content.Context;
import android.view.ViewGroup;

import com.ethnoapp.bgita.adapters.holders.BookmarkHolder;
import com.ethnoapp.bgita.model.SlokaInfo;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.adapters.RecyclerArrayAdapter;

import java.util.ArrayList;

public class BookmarksAdapter extends RecyclerArrayAdapter<SlokaInfo> {
	private final boolean fromBookmark;

	public BookmarksAdapter(Context context, ArrayList<SlokaInfo> items, boolean fromBookmark) {
		super(context, items);
		this.fromBookmark = fromBookmark;
	}

	@Override
	public BaseHolder onCreateViewHolder(ViewGroup parent, int viewType) {
		return new BookmarkHolder(parent, fromBookmark);
	}
}
