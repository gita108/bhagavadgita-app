package com.ethnoapp.bgita.adapters;

import android.content.Context;
import android.view.ViewGroup;

import com.ethnoapp.bgita.adapters.holders.LanguageHolder;
import com.ethnoapp.bgita.model.Language;
import com.ethnoapp.bgita.model.Languages;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.adapters.RecyclerArrayAdapter;

import java.util.ArrayList;

public class LanguageAdapter extends RecyclerArrayAdapter<Language> {

	public LanguageAdapter(Context context, Languages items) {
		super(context, items);
		setCheckedItems();
	}

	@Override
	public BaseHolder onCreateViewHolder(ViewGroup parent, int viewType) {
		return new LanguageHolder(parent);
	}

	private void setCheckedItems() {
		ArrayList<Language> languages = Language.getList();
		for (Language item : getItems()) {
			if (Language.contains(languages, item.getId()))
				item.setChecked(true);
		}
	}

	public ArrayList<Language> getCheckedItems() {
		ArrayList<Language> result = new ArrayList<>();
		for (Language item : getItems())
			if (item.isChecked())
				result.add(item);
		return result;
	}
}
