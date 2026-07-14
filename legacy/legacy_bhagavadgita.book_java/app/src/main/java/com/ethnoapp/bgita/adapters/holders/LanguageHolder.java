package com.ethnoapp.bgita.adapters.holders;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.model.Language;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.utils.GaUtils;

public class LanguageHolder extends BaseHolder<Language> {
	private TextView tvName;
	private CheckBox cbLanguage;

	private View.OnClickListener itemClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			if (Settings.getInstance().getLanguageId() != getObject().getId()) {
				getObject().setChecked(!getObject().isChecked());
				cbLanguage.setChecked(getObject().isChecked());
				GaUtils.logEvent(UiConstants.GA_CATEGORY_LANGUAGE, "Change language");
			}
		}
	};

	public LanguageHolder(ViewGroup parent) {
		super(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_language, parent, false));
		tvName = itemView.findViewById(R.id.tv_name);
		cbLanguage = itemView.findViewById(R.id.cb_language);
		itemView.setOnClickListener(itemClickListener);
	}

	@Override
	public void update(Language item) {
		super.update(item);
		tvName.setText(item.getName());
		cbLanguage.setChecked(Settings.getInstance().getLanguageId() == item.getId() || item.isChecked());
		cbLanguage.setEnabled(Settings.getInstance().getLanguageId() != item.getId());
	}
}