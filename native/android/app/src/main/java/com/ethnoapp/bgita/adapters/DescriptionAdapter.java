package com.ethnoapp.bgita.adapters;

import android.content.Context;
import android.view.ViewGroup;

import com.ethnoapp.bgita.adapters.holders.DescriptionHolder;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.adapters.RecyclerArrayAdapter;

import java.util.ArrayList;

public class DescriptionAdapter extends RecyclerArrayAdapter<String> {
	public DescriptionAdapter(Context context, ArrayList<String> items) {
		super(context, items);
	}

	@Override
	public BaseHolder onCreateViewHolder(ViewGroup parent, int viewType) {
		return new DescriptionHolder(parent);
	}
}
