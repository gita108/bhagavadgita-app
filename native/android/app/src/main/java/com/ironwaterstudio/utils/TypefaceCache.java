package com.ironwaterstudio.utils;

import android.content.Context;
import android.graphics.Typeface;

import java.util.HashMap;

public final class TypefaceCache {
	public static final Font DEFAULT_FONT = Font.REGULAR;

	public enum Font {
		DEFAULT(null),
		REGULAR("fonts/PT_Sans-Web-Regular.ttf"),
		BOLD("fonts/PT_Sans-Web-Bold.ttf"),
		BOLD_ITALIC("fonts/PT_Sans-Web-BoldItalic.ttf"),
		ITALIC("fonts/PT_Sans-Web-Italic.ttf");

		final String asset;

		Font(String asset) {
			this.asset = asset;
		}

		public String getAsset() {
			return asset;
		}

		public static Font get(int i) {
			if (i < 0 || i >= values().length)
				return DEFAULT;
			return values()[i];
		}
	}

	private static final HashMap<Font, Typeface> cache = new HashMap<>();

	public static Typeface get(Context context, Font font) {
		if (cache.containsKey(font))
			return cache.get(font);

		try {
			String asset = font.getAsset();
			Typeface tf = (asset == null) ? Typeface.DEFAULT : Typeface.createFromAsset(context.getAssets(), asset);
			cache.put(font, tf);
			return tf;
		} catch (Exception e) {
			return null;
		}
	}
}
