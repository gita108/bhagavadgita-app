package com.ethnoapp.bgita.adapters;

import android.content.Context;
import android.view.ViewGroup;

import com.ethnoapp.bgita.adapters.holders.SlokaHolder;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.model.Sloka;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.adapters.RecyclerArrayAdapter;

import java.util.ArrayList;
import java.util.List;

import static com.ethnoapp.bgita.adapters.holders.SlokaHolder.Payloads.CHANGE_BOOKMARK;
import static com.ethnoapp.bgita.adapters.holders.SlokaHolder.Payloads.UPDATE_BACKGROUND;

public class SlokasAdapter extends RecyclerArrayAdapter<Sloka> implements ISelected {
	private int currentSlokaId;

	public SlokasAdapter(Context context, ArrayList<Sloka> items) {
		super(context, items);
		currentSlokaId = Settings.getInstance().getSelectedId();
	}

	@Override
	public BaseHolder onCreateViewHolder(ViewGroup parent, int viewType) {
		return new SlokaHolder(parent);
	}

	@Override
	public int getSelectedId() {
		return Settings.getInstance().getSelectedId();
	}

	@Override
	public void setSelectedId(int id) {
		currentSlokaId = id;
		if (id == Settings.getInstance().getSelectedId())
			return;

		Settings.getInstance().setSelectedId(id);
		Settings.getInstance().save();
		notifyItemRangeChanged(0, getItemCount(), UPDATE_BACKGROUND);
	}

	// Method setISelected placed in onBindViewHolder bc views from nested lists recycle in global view pool. Therefore need to update link on adapter.
	@Override
	public void onBindViewHolder(BaseHolder holder, int position) {
		if (holder instanceof SlokaHolder)
			((SlokaHolder) holder).setISelected(this);
		super.onBindViewHolder(holder, position);
	}

	@Override
	public void onBindViewHolder(BaseHolder holder, int position, List<Object> payloads) {
		if (payloads != null && !payloads.isEmpty() && holder instanceof SlokaHolder) {
			if (payloads.contains(UPDATE_BACKGROUND))
				((SlokaHolder) holder).updateBackground();
			if (payloads.contains(CHANGE_BOOKMARK))
				((SlokaHolder) holder).updateBookmark();
		} else
			super.onBindViewHolder(holder, position, payloads);
	}

	public void upToDateSelection() {
		if (currentSlokaId == Settings.getInstance().getSelectedId())
			return;

		notifyItemRangeChanged(0, getItemCount(), UPDATE_BACKGROUND);
		currentSlokaId = Settings.getInstance().getSelectedId();
	}

	public void changeBookmark(int id) {
		for (int i = 0; i < getItems().size(); i++) {
			if (getItem(i).getId() == id)
				notifyItemChanged(toNotifyPosition(i), CHANGE_BOOKMARK);
		}
	}

	public void setCurrentId(int id) {
		currentSlokaId = id;
	}
}