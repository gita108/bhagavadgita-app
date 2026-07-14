package com.ethnoapp.bgita.model;

import com.ethnoapp.bgita.R;

public enum Guide {
	PAGE_1(R.drawable.icn_guide_1, R.string.guid_title_1, R.string.guid_text_1),
	PAGE_2(R.drawable.icn_guide_2, R.string.guid_title_2, R.string.guid_text_2),
	PAGE_3(R.drawable.icn_guide_3, 0, R.array.guide_text_3);

	private int iconResId;
	private int titleResId;
	private int descrResId;

	Guide(int iconResId, int titleResId, int descrResId) {
		this.iconResId = iconResId;
		this.titleResId = titleResId;
		this.descrResId = descrResId;
	}

	public int getIconResId() {
		return iconResId;
	}

	public int getTitleResId() {
		return titleResId;
	}

	public int getDescrResId() {
		return descrResId;
	}
}
