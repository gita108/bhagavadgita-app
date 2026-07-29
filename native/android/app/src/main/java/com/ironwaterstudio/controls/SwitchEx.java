package com.ironwaterstudio.controls;

import android.content.Context;
import android.content.res.TypedArray;
import android.support.v7.widget.SwitchCompat;
import android.util.AttributeSet;

import com.ethnoapp.bgita.R;
import com.ironwaterstudio.utils.TypefaceCache;

import static com.ironwaterstudio.utils.TypefaceCache.DEFAULT_FONT;

public class SwitchEx extends SwitchCompat {
	public SwitchEx(Context context) {
		super(context);
	}

	public SwitchEx(Context context, AttributeSet attrs) {
		super(context, attrs);
		setFont(context, attrs);
	}

	public SwitchEx(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		setFont(context, attrs);
	}

	private void setFont(Context context, AttributeSet attrs) {
		TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.TextViewEx);
		TypefaceCache.Font font = TypefaceCache.Font.get(a.getInt(R.styleable.TextViewEx_fontEx, DEFAULT_FONT.ordinal()));
		setFont(context, font);
		a.recycle();
	}

	public void setFont(Context context, TypefaceCache.Font font) {
		setTypeface(TypefaceCache.get(context, font));
	}
}
