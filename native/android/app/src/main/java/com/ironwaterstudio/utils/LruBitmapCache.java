package com.ironwaterstudio.utils;

import android.annotation.TargetApi;
import android.graphics.Bitmap;
import android.os.Build;
import android.support.v4.util.LruCache;

public class LruBitmapCache<K> extends LruCache<K, Bitmap> {
	public static final float DEFAULT_FACTOR = 0.25f;

	public LruBitmapCache() {
		this(DEFAULT_FACTOR);
	}

	public LruBitmapCache(float factor) {
		this((long) (Runtime.getRuntime().maxMemory() * factor));
	}

	public LruBitmapCache(long maxSize) {
		super((int) (maxSize / 1024));
	}

	@Override
	protected int sizeOf(K key, Bitmap value) {
		return getBitmapSize(value) / 1024;
	}

	@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
	public static int getBitmapSize(Bitmap value) {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR1)
			return value.getByteCount();
		return value.getRowBytes() * value.getHeight();
	}
}
