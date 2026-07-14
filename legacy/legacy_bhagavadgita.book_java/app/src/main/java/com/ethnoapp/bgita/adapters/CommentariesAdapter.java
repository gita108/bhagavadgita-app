package com.ethnoapp.bgita.adapters;

import android.content.Context;
import android.view.ViewGroup;

import com.ethnoapp.bgita.adapters.holders.CommentaryHolder;
import com.ethnoapp.bgita.model.Commentary;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.adapters.RecyclerArrayAdapter;

import java.util.ArrayList;

public class CommentariesAdapter extends RecyclerArrayAdapter<Commentary> {
	public CommentariesAdapter(Context context, ArrayList<Commentary> items) {
		super(context, items);
	}

	@Override
	public BaseHolder onCreateViewHolder(ViewGroup parent, int viewType) {
		return new CommentaryHolder(parent);
	}
}

