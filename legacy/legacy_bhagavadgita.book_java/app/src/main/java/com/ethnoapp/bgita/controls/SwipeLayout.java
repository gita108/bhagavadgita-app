package com.ethnoapp.bgita.controls;

import android.content.Context;
import android.content.res.TypedArray;
import android.support.v4.view.MotionEventCompat;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewParent;
import android.view.animation.Animation;
import android.view.animation.Transformation;
import android.widget.RelativeLayout;

import com.ethnoapp.bgita.R;


public class SwipeLayout extends RelativeLayout {
	private static final int SWIPE_ANIM_DURATION = 600;
	private static final int SWIPE_MIN_X = 5;
	private static final float AUTO_SWIPE_RATE = 0.5f;

	private static final int TOUCH_STATE_REST = 0;
	private static final int TOUCH_STATE_SCROLLING_X = 1;
	private static final int TOUCH_STATE_SCROLLING_Y = 2;

	private int swipePadding;
	private int touchState = TOUCH_STATE_REST;
	private float firstMotionX;
	private float lastMotionX;
	private float lastMotionY;
	private boolean expanded = false;

	private int swipeViewRes = -1;
	private View swipeView = null;
	private OnSwipeListener swipeListener = null;

	private boolean lockSwipe = false;

	public SwipeLayout(Context context, AttributeSet attrs) {
		super(context, attrs);

		TypedArray a = context.obtainStyledAttributes(attrs,
				R.styleable.SwipeLayout);
		swipeViewRes = a.getResourceId(R.styleable.SwipeLayout_swipeView, -1);
		a.recycle();
	}

	public boolean isLockSwipe() {
		return lockSwipe;
	}

	public void setLockSwipe(boolean lockSwipe) {
		this.lockSwipe = lockSwipe;
	}

	public void setSwipePadding(int swipePadding) {
		this.swipePadding = swipePadding;
	}

	public void setSwipeListener(OnSwipeListener swipeListener) {
		this.swipeListener = swipeListener;
	}

	@Override
	protected void onAttachedToWindow() {
		super.onAttachedToWindow();
		if (swipeView == null)
			swipeView = findViewById(swipeViewRes);
	}

	@Override
	public boolean onInterceptTouchEvent(MotionEvent event) {
		if (lockSwipe)
			return false;
		final int action = MotionEventCompat.getActionMasked(event);
		final float x = event.getRawX();
		final float y = event.getRawY();

		switch (action) {
			case MotionEvent.ACTION_MOVE:
				if (touchState == TOUCH_STATE_SCROLLING_X) {
					changeSwipeMargins(swipeView, Math.round(x - lastMotionX));
					lastMotionX = x;
					lastMotionY = y;
				} else {
					final int xDiff = (int) Math.abs(x - lastMotionX);
					final int yDiff = (int) Math.abs(y - lastMotionY);
					touchState = (xDiff > yDiff && xDiff > SWIPE_MIN_X && (x > lastMotionX == expanded)) ? TOUCH_STATE_SCROLLING_X
							: TOUCH_STATE_SCROLLING_Y;
					if (touchState == TOUCH_STATE_SCROLLING_X)
						requestDisallowInterceptTouchEvent(getParent(), true);
				}
				return false;
			case MotionEvent.ACTION_DOWN:
				touchState = TOUCH_STATE_REST;
				firstMotionX = lastMotionX = x;
				lastMotionY = y;
				return false;
			case MotionEvent.ACTION_CANCEL:
			case MotionEvent.ACTION_UP:
				if (touchState != TOUCH_STATE_SCROLLING_X)
					return false;

				boolean changeState = Math.abs(firstMotionX - x) >= swipePadding * AUTO_SWIPE_RATE;
				boolean expand = changeState ? !expanded : expanded;
				swipeView(expand, true);

				if (swipeListener != null)
					swipeListener.onSwipe(SwipeLayout.this, expanded);
				touchState = TOUCH_STATE_REST;
				requestDisallowInterceptTouchEvent(getParent(), false);
				return true;
		}
		return false;
	}

	public void swipeView(final boolean expand, boolean animate) {
		if (swipeView == null)
			return;

		swipeView.clearAnimation();
		expanded = expand;
		final MarginLayoutParams lp = (MarginLayoutParams) swipeView
				.getLayoutParams();
		final float start = lp.leftMargin;
		final float end = expand ? -swipePadding : 0;
		if (start == end)
			return;

		if (!animate) {
			setSwipeMargins(swipeView, lp, (int) end);
			return;
		}

		Animation anim = new Animation() {
			protected void applyTransformation(float interpolatedTime,
											   Transformation t) {
				int margin = Math.round(start * (1 - interpolatedTime) + end
						* interpolatedTime);
				setSwipeMargins(swipeView, lp, margin);
			}
		};
		anim.setDuration(SWIPE_ANIM_DURATION);
		swipeView.startAnimation(anim);
	}

	private void changeSwipeMargins(View v, int offset) {
		final MarginLayoutParams lp = (MarginLayoutParams) v.getLayoutParams();
		setSwipeMargins(v, lp, lp.leftMargin + offset);
	}

	private void setSwipeMargins(View v, MarginLayoutParams lp, int margin) {
		int minMargin = -swipePadding;
		if (margin > 0)
			margin = 0;
		else if (margin < minMargin)
			margin = minMargin;

		lp.leftMargin = margin;
		lp.rightMargin = -margin;
		v.setLayoutParams(lp);
	}

	// workaround for issue https://code.google.com/p/android/issues/detail?id=60464
	private static Integer disallowCount = 0;

	private static void requestDisallowInterceptTouchEvent(ViewParent parent, boolean disallow) {
		if (parent == null)
			return;
		synchronized (disallowCount) {
			if (disallow) {
				if (disallowCount == 0)
					parent.requestDisallowInterceptTouchEvent(disallow);
				disallowCount++;
			} else {
				disallowCount--;
				if (disallowCount == 0)
					parent.requestDisallowInterceptTouchEvent(disallow);
			}
		}
	}

	public interface OnSwipeListener {
		public void onSwipe(SwipeLayout view, boolean isExpanded);
	}
}
