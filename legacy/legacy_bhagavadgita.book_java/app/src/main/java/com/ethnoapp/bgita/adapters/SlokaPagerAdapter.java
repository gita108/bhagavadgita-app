package com.ethnoapp.bgita.adapters;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.ethnoapp.bgita.fragments.SlokaFragment;
import com.ethnoapp.bgita.model.Sloka;
import com.ethnoapp.bgita.model.SlokaIds;

import java.util.ArrayList;

public class SlokaPagerAdapter extends FragmentStatePagerAdapter {
	private ArrayList<SlokaIds> slokas = Sloka.getSortedIds();

	public SlokaPagerAdapter(FragmentManager fm) {
		super(fm);
	}

	@Override
	public Fragment getItem(int position) {
		Sloka prepareSloka = Sloka.getSloka(slokas.get(position).getId());
		return SlokaFragment.newInstance(prepareSloka, slokas.get(0).getId() == prepareSloka.getId(), slokas.get(slokas.size() - 1).getId() == prepareSloka.getId(), position);
	}

	@Override
	public int getCount() {
		return slokas.size();
	}
}