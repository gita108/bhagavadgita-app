package com.ironwaterstudio.controls;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.support.v4.content.ContextCompat;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.SpannableStringBuilder;
import android.text.TextPaint;
import android.text.style.TypefaceSpan;

import com.ironwaterstudio.utils.TypefaceCache;
import com.ironwaterstudio.utils.TypefaceCache.Font;
import com.ironwaterstudio.utils.UiHelper;

@SuppressLint("ParcelCreator")
public class TypefaceSpanEx extends TypefaceSpan {
	private final Typeface typeface;
	private final float size;
	private final int color;

	public TypefaceSpanEx(TypefaceSpanEx span) {
		super("");
		typeface = span.typeface;
		size = span.size;
		color = span.color;
	}

	public TypefaceSpanEx(Context context, Font font, int sizeSp, int colorId) {
		this(context, font, UiHelper.spToPx(context, sizeSp), colorId);
	}

	public TypefaceSpanEx(Context context, Font font, float sizePx, int colorId) {
		this(context, ContextCompat.getColor(context, colorId), font, sizePx);
	}

	public TypefaceSpanEx(Context context, int color, Font font, int sizeSp) {
		this(context, color, font, UiHelper.spToPx(context, sizeSp));
	}

	public TypefaceSpanEx(Context context, int color, Font font, float sizePx) {
		super("");
		this.typeface = TypefaceCache.get(context, font);
		this.size = sizePx;
		this.color = color;
	}

	public Typeface getTypeface() {
		return typeface;
	}

	public float getSize() {
		return size;
	}

	public int getColor() {
		return color;
	}

	@Override
	public void updateDrawState(TextPaint ds) {
		applyStyle(ds, typeface, size, color);
	}

	@Override
	public void updateMeasureState(TextPaint paint) {
		applyStyle(paint, typeface, size, color);
	}

	public TypefaceSpanEx copy() {
		return new TypefaceSpanEx(this);
	}

	private static void applyStyle(Paint paint, Typeface tf, float size, int color) {
		paint.setTypeface(tf);
		paint.setTextSize(size);
		paint.setColor(color);
	}

	public static void appendText(Context context, SpannableStringBuilder builder, Font font, int sizeSp, int colorId, String text) {
		appendText(context, builder, font, UiHelper.spToPx(context, sizeSp), colorId, text);
	}

	public static void appendText(Context context, SpannableStringBuilder builder, Font font, float sizePx, int colorId, String text) {
		SpannableString spannable = new SpannableString(text);
		spannable.setSpan(new TypefaceSpanEx(context, font, sizePx, colorId), 0, spannable.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
		builder.append(spannable);
	}
}
