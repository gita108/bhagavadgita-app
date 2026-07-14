package com.ethnoapp.bgita.adapters.holders;


import android.animation.PropertyValuesHolder;
import android.animation.ValueAnimator;
import android.content.Intent;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.adapters.IExpanded;
import com.ethnoapp.bgita.adapters.SlokasAdapter;
import com.ethnoapp.bgita.model.Chapter;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.model.Sloka;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ironwaterstudio.adapters.BaseHolder;

import java.util.ArrayList;

public class ChapterHolder extends BaseHolder<Chapter> {
	private static final String HOLDER_HEIGHT = "Height";
	private static final String HOLDER_ROTATION = "Rotation";
	public static final long EXPAND_DURATION = 200;

	public enum Payloads {COLLAPSE, UP_TO_DATE_SELECTION, CHANGE_BOOKMARK, EXPAND}

	private final TextView tvChapter;
	private final TextView tvNameChapter;
	private final TextView tvSlokas;
	private final ImageView ivArrow;
	private final RecyclerView rvSlokas;
	private final GridLayoutManager gridLayoutManager;
	private final View rlChapterInfo;
	private final SlokasAdapter adapter;
	private int parentWidth;

	private ValueAnimator animator = ValueAnimator.ofPropertyValuesHolder(PropertyValuesHolder.ofInt(HOLDER_HEIGHT, 0, 1), PropertyValuesHolder.ofFloat(HOLDER_ROTATION, 0, 1));
	private ValueAnimator.AnimatorUpdateListener updateListener = new ValueAnimator.AnimatorUpdateListener() {
		private int oldValue = -1;

		@Override
		public void onAnimationUpdate(ValueAnimator valueAnimator) {
			float value = (float) valueAnimator.getAnimatedValue(HOLDER_ROTATION);
			ivArrow.setRotation(value);

			int valueHeight = (int) valueAnimator.getAnimatedValue(HOLDER_HEIGHT);
			if (oldValue == valueHeight)
				return;

			oldValue = valueHeight;
			ViewGroup.LayoutParams params = itemView.getLayoutParams();
			params.height = valueHeight;
			itemView.requestLayout();
		}
	};

	private final IExpanded iExpanded;
	private View.OnClickListener itemClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View view) {
			int finalHeight;
			if (iExpanded.getExpandedId() == getObject().getId()) {
				finalHeight = rlChapterInfo.getHeight();
				iExpanded.setExpandedId(-1);
			} else {
				adapter.setCurrentId(Settings.getInstance().getSelectedId());
				if (!animator.isRunning()) {
					adapter.animateTo(getObject().getSlokasFromDb());
				}
				updateSlokas();
				finalHeight = rvSlokas.getMeasuredHeight() + rlChapterInfo.getHeight();
				iExpanded.setExpandedId(getObject().getId());
				getContext().sendBroadcast(new Intent(UiConstants.ACTION_EXPAND).putExtra(UiConstants.KEY_POS, getAdapterPosition()));
			}
			animator.setValues(PropertyValuesHolder.ofInt(HOLDER_HEIGHT, itemView.getHeight(), finalHeight),
					PropertyValuesHolder.ofFloat(HOLDER_ROTATION, ivArrow.getRotation(), iExpanded.getExpandedId() == getObject().getId() ? -180 : 0));
			animator.start();
		}
	};

	public ChapterHolder(ViewGroup parent, IExpanded iExpanded, RecyclerView.RecycledViewPool viewPool) {
		super(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_chapter, parent, false));
		this.iExpanded = iExpanded;
		parentWidth = parent.getWidth();
		tvChapter = itemView.findViewById(R.id.tv_chapter);
		tvNameChapter = itemView.findViewById(R.id.tv_name_chapter);
		tvSlokas = itemView.findViewById(R.id.tv_slokas);
		ivArrow = itemView.findViewById(R.id.iv_arrow);
		rvSlokas = itemView.findViewById(R.id.rv_translations);
		rlChapterInfo = itemView.findViewById(R.id.rl_chapter_info);

		gridLayoutManager = (GridLayoutManager) rvSlokas.getLayoutManager();
		gridLayoutManager.setSpanCount(7);
		gridLayoutManager.setAutoMeasureEnabled(true);
		rlChapterInfo.setOnClickListener(itemClickListener);
		animator.addUpdateListener(updateListener);
		animator.setDuration(EXPAND_DURATION);

		adapter = new SlokasAdapter(getContext(), new ArrayList<Sloka>());
		rvSlokas.setAdapter(adapter);
		rvSlokas.setRecycledViewPool(viewPool);
	}

	@Override
	public void update(Chapter item) {
		super.update(item);
		tvChapter.setText(getContext().getString(R.string.chapter, item.getOrder()));
		tvNameChapter.setText(item.getName());
		tvSlokas.setText(getContext().getResources().getQuantityString(R.plurals.slokas, item.getSlokasCount(), item.getSlokasCount()));
		rlChapterInfo.measure(View.MeasureSpec.makeMeasureSpec(parentWidth, View.MeasureSpec.EXACTLY), View.MeasureSpec.UNSPECIFIED);
		adapter.notifyDataSetChanged();
		int finalheight = rlChapterInfo.getMeasuredHeight();
		if (iExpanded.getExpandedId() == item.getId()) {
			adapter.animateTo(item.getSlokasFromDb());
			updateSlokas();
			finalheight += rvSlokas.getMeasuredHeight();
			ivArrow.setRotation(-180);
		} else
			ivArrow.setRotation(0);
		ViewGroup.LayoutParams params = itemView.getLayoutParams();
		params.height = finalheight;
		itemView.requestLayout();
	}

	private void updateSlokas() {
		rvSlokas.measure(View.MeasureSpec.makeMeasureSpec(parentWidth, View.MeasureSpec.EXACTLY), View.MeasureSpec.UNSPECIFIED);
		ViewGroup.LayoutParams params = rvSlokas.getLayoutParams();
		params.height = rvSlokas.getMeasuredHeight();
		rvSlokas.requestLayout();
	}

	public void collapse() {
		animator.setValues(PropertyValuesHolder.ofInt(HOLDER_HEIGHT, itemView.getHeight(), rlChapterInfo.getHeight()),
				PropertyValuesHolder.ofFloat(HOLDER_ROTATION, ivArrow.getRotation(), 0));
		animator.start();
	}

	public void expand() {
		rvSlokas.post(new Runnable() {
			@Override
			public void run() {
				itemClickListener.onClick(rlChapterInfo);
			}
		});
	}

	public void upToDateSelection() {
		adapter.upToDateSelection();
	}

	public void changeBookmark() {
		adapter.changeBookmark(Settings.getInstance().getSelectedId());
	}
}
