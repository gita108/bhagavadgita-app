package com.ethnoapp.bgita.utils;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.annotation.ColorRes;
import android.support.annotation.DrawableRes;
import android.support.v4.content.ContextCompat;
import android.support.v4.graphics.drawable.DrawableCompat;

import com.ethnoapp.bgita.R;

import java.io.File;

public class GitaUtils {
	private static final String AUDIO = "audio";

	private static File getFilesDir(Context context) {
		File dir = context.getExternalFilesDir(null);
		if (dir == null)
			dir = context.getFilesDir();
		return dir;
	}

	public static File getAudioDir(Context context) {
		return new File(getFilesDir(context), AUDIO);
	}

	public static File getAudioFile(Context context, String audio) {
		return new File(getAudioDir(context), audio);
	}

	public static Drawable getTintedDrawable(Context context, @DrawableRes int drawableResId, @ColorRes int colorResId) {
		return getTintedDrawable(ContextCompat.getDrawable(context, drawableResId), ContextCompat.getColor(context, colorResId));
	}

	public static Drawable getTintedDrawable(Drawable drawable, int color) {
		Drawable wrappedDrawable = DrawableCompat.wrap(drawable).mutate();
		DrawableCompat.setTint(wrappedDrawable, color);
		return wrappedDrawable;
	}

	public static int getRightContainer(Context context) {
		return context.getResources().getBoolean(R.bool.is_tablet) ? R.id.container_right : R.id.container;
	}
}