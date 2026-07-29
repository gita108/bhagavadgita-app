package com.ironwaterstudio.controls;

import android.content.Context;
import android.content.res.TypedArray;
import android.support.v7.widget.AppCompatButton;
import android.util.AttributeSet;

import com.ethnoapp.bgita.R;
import com.ironwaterstudio.utils.TypefaceCache;
import com.ironwaterstudio.utils.TypefaceCache.Font;

import static com.ironwaterstudio.utils.TypefaceCache.DEFAULT_FONT;

public class ButtonEx extends AppCompatButton {
	public ButtonEx(Context context) {
		super(context);
	}

	public ButtonEx(Context context, AttributeSet attrs) {
		super(context, attrs);
		setFont(context, attrs);
	}

	public ButtonEx(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		setFont(context, attrs);
	}

	private void setFont(Context context, AttributeSet attrs) {
		TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.TextViewEx);
		Font font = Font.get(a.getInt(R.styleable.TextViewEx_fontEx, DEFAULT_FONT.ordinal()));
		setFont(context, font);
		a.recycle();
	}

	public void setFont(Context context, Font font) {
		setTypeface(TypefaceCache.get(context, font));
	}
}
