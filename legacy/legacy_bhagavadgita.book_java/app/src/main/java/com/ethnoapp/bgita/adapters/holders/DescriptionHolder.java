package com.ethnoapp.bgita.adapters.holders;

import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ironwaterstudio.adapters.BaseHolder;

public class DescriptionHolder extends BaseHolder<String> {
	private TextView tvDescription;

	public DescriptionHolder(ViewGroup parent) {
		super(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_description, parent, false));
		tvDescription = itemView.findViewById(R.id.tv_description);
	}

	@Override
	public void update(String item) {
		super.update(item);
		tvDescription.setText(item);
	}
}
