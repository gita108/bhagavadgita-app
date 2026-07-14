package com.ethnoapp.bgita.adapters;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.model.Guide;
import com.ironwaterstudio.controls.ImageViewEx;
import com.viewpagerindicator.IconPagerAdapter;

import java.util.ArrayList;
import java.util.Arrays;


public class GuidePagerAdapter extends PagerAdapter implements IconPagerAdapter {
	private final Context context;
	private final ArrayList<Guide> items;
	private int indicatorId = R.drawable.indicator;

	public GuidePagerAdapter(Context context, ArrayList<Guide> items) {
		this.context = context;
		this.items = items;
	}

	public Context getContext() {
		return context;
	}

	public Guide getItem(int position) {
		return items.get(position);
	}

	@Override
	public int getIconResId(int index) {
		return indicatorId;
	}

	@Override
	public int getCount() {
		return items.size();
	}

	@Override
	public boolean isViewFromObject(View view, Object object) {
		return view.equals(object);
	}

	@Override
	public Object instantiateItem(ViewGroup container, int position) {
		LayoutInflater inflater = LayoutInflater.from(getContext());
		final View v;
		Guide item = getItem(position);
		if (position <= 1) {
			v = inflater.inflate(R.layout.item_guide, container, false);
			ImageViewEx ivImage = v.findViewById(R.id.iv_image);
			TextView tvTitle = v.findViewById(R.id.tv_title);
			TextView tvDescription = v.findViewById(R.id.tv_description);

			ivImage.setImage(item.getIconResId());
			tvTitle.setText(item.getTitleResId());
			tvDescription.setText(item.getDescrResId());
		} else {
			v = inflater.inflate(R.layout.item_guide_array, container, false);
			ImageViewEx ivImage = v.findViewById(R.id.iv_image);
			RecyclerView rvDescriptions = v.findViewById(R.id.rv_descriptions);
			rvDescriptions.setNestedScrollingEnabled(false);
			LinearLayoutManager layoutManager = new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false) {
				@Override
				public boolean canScrollVertically() {
					return false;
				}
			};
			layoutManager.setAutoMeasureEnabled(true);
			rvDescriptions.setLayoutManager(layoutManager);


			ivImage.setImage(item.getIconResId());
			rvDescriptions.setAdapter(new DescriptionAdapter(getContext(), new ArrayList<>(Arrays.asList(getContext().getResources().getStringArray(item.getDescrResId())))));
		}
		container.addView(v);
		return v;
	}

	@Override
	public void destroyItem(ViewGroup container, int position, Object object) {
		container.removeView((View) object);
	}
}
