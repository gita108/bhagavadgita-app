package com.ironwaterstudio.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

public abstract class RecyclerArrayAdapter<Model> extends RecyclerView.Adapter<BaseHolder> {
	private final Context context;
	private final ArrayList<Model> items;
	private OnScrollToLastItemListener onScrollToLastItemListener = null;

	public RecyclerArrayAdapter(Context context, ArrayList<Model> items) {
		this.context = context;
		this.items = items;
	}

	public Context getContext() {
		return context;
	}

	public OnScrollToLastItemListener getOnScrollToLastItemListener() {
		return onScrollToLastItemListener;
	}

	public void setOnScrollToLastItemListener(OnScrollToLastItemListener onScrollToLastItemListener) {
		this.onScrollToLastItemListener = onScrollToLastItemListener;
	}

	public ArrayList<Model> getItems() {
		return items;
	}

	public Model getItem(int position) {
		return items.get(position);
	}

	public Model removeItem(int position) {
		final Model model = items.remove(position);
		notifyItemRemoved(toNotifyPosition(position));
		return model;
	}

	public int indexAt(Model item) {
		for (int i = 0; i < getItems().size(); i++) {
			if (getItem(i).equals(item))
				return i;
		}
		return -1;
	}

	public void clear() {
		int size = items.size();
		items.clear();
		notifyItemRangeRemoved(0, size);
	}

	public void addItem(Model model) {
		addItem(getItems().size(), model);
	}

	public void addItem(int position, Model model) {
		items.add(position, model);
		notifyItemInserted(toNotifyPosition(position));
	}

	public void addAll(ArrayList<Model> models) {
		addAll(getItems().size(), models);
	}

	public void addAll(int position, ArrayList<Model> models) {
		for (int i = 0; i < models.size(); i++)
			addItem(position++, models.get(i));
	}

	public void moveItem(int fromPosition, int toPosition) {
		final Model model = items.remove(fromPosition);
		items.add(toPosition, model);
		notifyItemMoved(toNotifyPosition(fromPosition), toNotifyPosition(toPosition));
	}

	@SuppressWarnings("unchecked")
	@Override
	public void onBindViewHolder(BaseHolder holder, int position) {
		holder.update(getItem(toItemsPosition(position)));
	}

	public int toNotifyPosition(int position) {
		return position;
	}

	public int toItemsPosition(int position) {
		return position;
	}

	@Override
	public int getItemCount() {
		return items.size();
	}

	public boolean isEmpty() {
		return getItemCount() <= 0;
	}

	@Override
	public void onViewAttachedToWindow(BaseHolder holder) {
		super.onViewAttachedToWindow(holder);
		holder.onAttach();
		if (onScrollToLastItemListener != null && holder.getAdapterPosition() == getItemCount() - 1)
			onScrollToLastItemListener.onScrollToLastItem(holder);
	}

	@Override
	public void onViewDetachedFromWindow(BaseHolder holder) {
		super.onViewDetachedFromWindow(holder);
		holder.onDetach();
	}

	public void animateTo(List<Model> models) {
		applyAndAnimateRemovals(models);
		applyAndAnimateAdditions(models);
		applyAndAnimateMovedItems(models);
	}

	private void applyAndAnimateRemovals(List<Model> newModels) {
		for (int i = items.size() - 1; i >= 0; i--) {
			final Model model = items.get(i);
			if (!newModels.contains(model))
				removeItem(i);
		}
	}

	private void applyAndAnimateAdditions(List<Model> newModels) {
		for (int i = 0, count = newModels.size(); i < count; i++) {
			final Model model = newModels.get(i);
			if (!items.contains(model))
				addItem(i, model);
		}
	}

	private void applyAndAnimateMovedItems(List<Model> newModels) {
		for (int toPosition = newModels.size() - 1; toPosition >= 0; toPosition--) {
			final Model model = newModels.get(toPosition);
			final int fromPosition = items.indexOf(model);
			if (fromPosition >= 0 && fromPosition != toPosition) {
				moveItem(fromPosition, toPosition);
			}
		}
	}

	public interface OnScrollToLastItemListener {
		void onScrollToLastItem(RecyclerView.ViewHolder holder);
	}
}

