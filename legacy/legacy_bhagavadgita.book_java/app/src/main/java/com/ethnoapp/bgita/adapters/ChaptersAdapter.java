package com.ethnoapp.bgita.adapters;

import android.content.Context;
import android.content.Intent;
import android.support.v7.widget.RecyclerView;
import android.view.ViewGroup;

import com.ethnoapp.bgita.adapters.holders.ChapterHolder;
import com.ethnoapp.bgita.adapters.holders.QuoteHolder;
import com.ethnoapp.bgita.model.Chapter;
import com.ethnoapp.bgita.model.Quote;
import com.ethnoapp.bgita.model.Sloka;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.adapters.HeaderArrayAdapter;

import java.util.ArrayList;
import java.util.List;

import static com.ethnoapp.bgita.adapters.holders.ChapterHolder.Payloads.CHANGE_BOOKMARK;
import static com.ethnoapp.bgita.adapters.holders.ChapterHolder.Payloads.COLLAPSE;
import static com.ethnoapp.bgita.adapters.holders.ChapterHolder.Payloads.EXPAND;
import static com.ethnoapp.bgita.adapters.holders.ChapterHolder.Payloads.UP_TO_DATE_SELECTION;

public class ChaptersAdapter extends HeaderArrayAdapter<Chapter, Quote> implements IExpanded {
	private RecyclerView.RecycledViewPool viewPool = new RecyclerView.RecycledViewPool();
	private int expandedId = -1;

	public ChaptersAdapter(Context context, ArrayList<Chapter> items) {
		super(context, items);
		//Need to create 160 elements of view shloks, to RecyclerView when displaying new shlok re-used the old view of the shlok, without creating new ones.
		viewPool.setMaxRecycledViews(0, 160);
	}

	@Override
	public BaseHolder onCreateViewHolder(ViewGroup parent, int viewType) {
		if (viewType == HEADER_TYPE)
			return new QuoteHolder(parent);
		return new ChapterHolder(parent, this, viewPool);
	}

	@Override
	public void onBindViewHolder(BaseHolder holder, int position, List<Object> payloads) {
		if (payloads == null || payloads.isEmpty()) {
			super.onBindViewHolder(holder, position, payloads);
			return;
		}
		if (payloads.contains(EXPAND))
			((ChapterHolder) holder).expand();
		if (payloads.contains(COLLAPSE))
			((ChapterHolder) holder).collapse();
		if (payloads.contains(UP_TO_DATE_SELECTION))
			((ChapterHolder) holder).upToDateSelection();
		if (payloads.contains(CHANGE_BOOKMARK))
			((ChapterHolder) holder).changeBookmark();
	}

	public int indexAt(int chapterId) {
		for (int i = 0; i < getItems().size(); i++) {
			if (getItem(i).getId() == chapterId)
				return i;
		}
		return -1;
	}

	@Override
	public int getExpandedId() {
		return expandedId;
	}

	@Override
	public void setExpandedId(int id) {
		if (id == expandedId)
			return;

		if (expandedId != -1) {
			int index = indexAt(expandedId);
			if (index != -1)
				notifyItemChanged(toNotifyPosition(index), COLLAPSE);
		}
		expandedId = id;
	}

	public void setExpandedIdWithExpand(int id, boolean visible) {
		int index = indexAt(id);
		if (id == expandedId && id == -1 && index == -1)
			return;

		if (visible) {
			notifyItemChanged(toNotifyPosition(index), EXPAND);
		} else {
			setExpandedId(id);
			notifyItemChanged(toNotifyPosition(index));
			getContext().sendBroadcast(new Intent(UiConstants.ACTION_EXPAND).putExtra(UiConstants.KEY_POS, index));
		}
	}

	public void upToDateSelection() {
		int index = indexAt(expandedId);
		if (index != -1)
			notifyItemChanged(toNotifyPosition(index), UP_TO_DATE_SELECTION);
	}

	public void changeBookmark() {
		Sloka sloka = Sloka.getSelectedSloka();
		for (Chapter chapter : getItems()) {
			if (chapter.getId() == sloka.getChapterId())
				chapter.updateBookmark(sloka);
		}
		int index = indexAt(expandedId);
		if (index != -1)
			notifyItemChanged(toNotifyPosition(index), CHANGE_BOOKMARK);
	}
}