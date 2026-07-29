package com.ethnoapp.bgita.screens;

import android.content.Context;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Spannable;
import android.text.SpannableString;
import android.view.MenuItem;

import com.ethnoapp.bgita.R;
import com.ironwaterstudio.controls.TypefaceSpanEx;
import com.ironwaterstudio.utils.TypefaceCache;

public class ToolbarActivity extends AppCompatActivity {
	public static int titleFontSize = 20;

	private final int layoutResId;
	private Toolbar toolbar = null;
	private int textColorId = R.color.white;

	public Toolbar getToolbar() {
		return toolbar;
	}

	public ToolbarActivity(int layoutResId) {
		this.layoutResId = layoutResId;
	}

	public static void setTitleFontSize(int titleFontSize) {
		ToolbarActivity.titleFontSize = titleFontSize;
	}

	public void setTextColorId(int textColorId) {
		this.textColorId = textColorId;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(layoutResId);
		toolbar = findViewById(R.id.toolbar);
		if (toolbar != null)
			setSupportActionBar(toolbar);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			case android.R.id.home:
				onBackPressed();
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}

	public CharSequence getCustomTitle() {
		return getSupportActionBar().getTitle();
	}

	@Override
	public void setTitle(int titleId) {
		setTitle(getString(titleId));
	}

	@Override
	public void setTitle(CharSequence title) {
		title = buildTitle(this, title, titleFontSize, textColorId);
		getSupportActionBar().setTitle(title);
	}

	public static CharSequence buildTitle(Context context, CharSequence title, int titleFontSize, int colorId) {
		if (title == null)
			return null;

		SpannableString span = new SpannableString(title.toString());
		TypefaceSpanEx tfSpan = new TypefaceSpanEx(context, TypefaceCache.Font.REGULAR, titleFontSize, colorId);
		span.setSpan(tfSpan, 0, title.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
		return span;
	}
}
