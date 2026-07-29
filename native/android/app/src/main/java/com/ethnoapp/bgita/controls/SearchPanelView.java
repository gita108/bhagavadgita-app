package com.ethnoapp.bgita.controls;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.SearchManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.view.animation.FastOutSlowInInterpolator;
import android.support.v7.widget.CardView;
import android.support.v7.widget.SearchView;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewAnimationUtils;
import android.widget.FrameLayout;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ironwaterstudio.utils.UiHelper;

import static android.content.Context.SEARCH_SERVICE;

public class SearchPanelView extends FrameLayout {
	private View scrim;
	private SearchView searchView;
	private CardView searchPanel;
	private Toolbar searchToolbar;
	private boolean isOpen;
	private Animator animator;
	private TypedValue typedValue = new TypedValue();

	private View.OnClickListener toolbarClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			close();
			getContext().sendBroadcast(new Intent(UiConstants.ACTION_SEARCH).putExtra(UiConstants.KEY_SEND_SEARCH_TEXT, ""));
		}
	};

	private SearchView.OnQueryTextListener enterTextListener = new SearchView.OnQueryTextListener() {
		@Override
		public boolean onQueryTextSubmit(String query) {
			getContext().sendBroadcast(new Intent(UiConstants.ACTION_SEARCH).putExtra(UiConstants.KEY_SEND_SEARCH_TEXT, query));
			return false;
		}

		@Override
		public boolean onQueryTextChange(String newText) {
			if (TextUtils.isEmpty(newText))
				getContext().sendBroadcast(new Intent(UiConstants.ACTION_SEARCH).putExtra(UiConstants.KEY_SEND_SEARCH_TEXT, ""));
			return false;
		}
	};

	public SearchPanelView(@NonNull Context context) {
		super(context);
		init();
	}

	public SearchPanelView(@NonNull Context context, @Nullable AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public SearchPanelView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		init();
	}

	@TargetApi(Build.VERSION_CODES.LOLLIPOP)
	public SearchPanelView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
		super(context, attrs, defStyleAttr, defStyleRes);
		init();
	}

	public String getSearchText() {
		return searchView.getQuery().toString();
	}

	public void setSearchText(String text) {
		searchView.setQuery(text, false);
	}

	@SuppressLint("RestrictedApi")
	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		int actionBarHeight = 0;
		if (getContext().getTheme().resolveAttribute(android.R.attr.actionBarSize, typedValue, true))
			actionBarHeight = TypedValue.complexToDimensionPixelSize(typedValue.data, getResources().getDisplayMetrics());
		super.onMeasure(widthMeasureSpec, MeasureSpec.makeMeasureSpec(actionBarHeight, MeasureSpec.EXACTLY));
	}

	public boolean isOpen() {
		return isOpen;
	}

	public void open() {
		if (animator != null && animator.isRunning())
			return;
		scrim.setClickable(true);
		scrim.animate()
				.alpha(1f)
				.setDuration(100L)
				.setInterpolator(new FastOutSlowInInterpolator())
				.start();
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			animator = ViewAnimationUtils.createCircularReveal(searchPanel, getResources().getDisplayMetrics().widthPixels,
					UiHelper.dpToPx(getContext(), 20), 0f, getResources().getDisplayMetrics().widthPixels);
			animator.addListener(new AnimatorListenerAdapter() {
				@Override
				public void onAnimationStart(Animator animation) {
					searchPanel.setVisibility(VISIBLE);
				}

				@Override
				public void onAnimationEnd(Animator animation) {
					isOpen = true;
				}
			});
			animator.setDuration(400L);
			animator.setInterpolator(new FastOutSlowInInterpolator());
			animator.start();
		} else {
			searchPanel.setVisibility(VISIBLE);
			isOpen = true;
		}
		searchView.onActionViewExpanded();
	}

	public void close() {
		if (animator != null && animator.isRunning())
			return;
		isOpen = false;
		scrim.setClickable(false);
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			animator = ViewAnimationUtils.createCircularReveal(searchPanel, getResources().getDisplayMetrics().widthPixels,
					UiHelper.dpToPx(getContext(), 20), getResources().getDisplayMetrics().widthPixels, 0f);
			animator.setDuration(400L);
			animator.addListener(new AnimatorListenerAdapter() {
				@Override
				public void onAnimationEnd(Animator animation) {
					searchPanel.setVisibility(GONE);
				}
			});
			animator.start();
		} else
			searchPanel.setVisibility(GONE);
		scrim.animate()
				.alpha(0f)
				.setDuration(1000L)
				.setInterpolator(new FastOutSlowInInterpolator())
				.start();
		searchView.onActionViewCollapsed();
	}

	public void handleIntent(Intent intent) {
		if (Intent.ACTION_SEARCH.equals(intent.getAction())) {
			String query = intent.getStringExtra(SearchManager.QUERY);
			searchView.setQuery(query, false);
		}
	}

	private void init() {
		inflate(getContext(), R.layout.item_search_panel, this);
		scrim = findViewById(R.id.scrim);
		searchPanel = findViewById(R.id.search_panel);
		searchToolbar = findViewById(R.id.search_toolbar);
		searchView = findViewById(R.id.search_view);

		SearchView searchView = findViewById(R.id.search_view);
		SearchManager searchManager = (SearchManager) getContext().getSystemService(SEARCH_SERVICE);
		searchView.setSearchableInfo(searchManager.getSearchableInfo(((Activity) getContext()).getComponentName()));

		searchToolbar.setNavigationOnClickListener(toolbarClickListener);
		searchView.setOnQueryTextListener(enterTextListener);
	}
}
