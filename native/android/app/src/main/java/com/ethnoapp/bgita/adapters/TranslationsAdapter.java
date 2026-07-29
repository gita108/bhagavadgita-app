package com.ethnoapp.bgita.adapters;

import android.content.Context;
import android.view.ViewGroup;

import com.ethnoapp.bgita.adapters.holders.TranslationHolder;
import com.ethnoapp.bgita.model.Translation;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.adapters.RecyclerArrayAdapter;

import java.util.ArrayList;

public class TranslationsAdapter extends RecyclerArrayAdapter<Translation> {
	public TranslationsAdapter(Context context, ArrayList<Translation> items) {
		super(context, items);
	}

	@Override
	public BaseHolder onCreateViewHolder(ViewGroup parent, int viewType) {
		return new TranslationHolder(parent);
	}
}

