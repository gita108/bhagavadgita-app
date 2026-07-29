package com.ethnoapp.bgita.controls;

import android.content.Context;
import android.support.v7.widget.LinearSmoothScroller;
import android.util.DisplayMetrics;

public class SnapToStartScroller extends LinearSmoothScroller {
	public SnapToStartScroller(Context context) {
		super(context);
	}

	@Override
	protected int getVerticalSnapPreference() {
		return LinearSmoothScroller.SNAP_TO_START;
	}

	@Override
	protected float calculateSpeedPerPixel(DisplayMetrics displayMetrics) {
		return super.calculateSpeedPerPixel(displayMetrics) * 4f;
	}
}
