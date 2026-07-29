package com.ironwaterstudio.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

public class BaseHolder<Model> extends RecyclerView.ViewHolder {
	private Model object = null;

	public Context getContext() {
		return itemView.getContext();
	}

	public Model getObject() {
		return object;
	}

	public BaseHolder(int resId, ViewGroup parent) {
		this(LayoutInflater.from(parent.getContext()).inflate(resId, parent, false));
	}

	public BaseHolder(View itemView) {
		super(itemView);
	}

	public void update(Model item) {
		object = item;
	}

	public void onAttach() {
	}

	public void onDetach() {
	}
}
