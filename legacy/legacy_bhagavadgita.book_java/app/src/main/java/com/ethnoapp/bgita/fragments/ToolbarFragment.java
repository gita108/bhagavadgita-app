package com.ethnoapp.bgita.fragments;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.screens.ToolbarActivity;

public abstract class ToolbarFragment extends Fragment {
	public static final int DEFAULT_TEXT_COLO_RID = R.color.white;

	private final int layoutResId;
	private Toolbar toolbar = null;
	private int textColorId = DEFAULT_TEXT_COLO_RID;

	private Toolbar.OnMenuItemClickListener menuItemClickListener = new Toolbar.OnMenuItemClickListener() {
		@Override
		public boolean onMenuItemClick(MenuItem item) {
			return onOptionsItemSelected(item);
		}
	};

	@SuppressLint("RtlHardcoded")
	private View.OnClickListener navigationClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			if (getActivity() != null && !getActivity().isFinishing())
				onNavigationClick();
		}
	};

	public Toolbar getToolbar() {
		return toolbar;
	}

	public ToolbarFragment(int layoutResId) {
		this.layoutResId = layoutResId;
	}

	public void setTextColorId(int textColorId) {
		this.textColorId = textColorId;
	}

	@Nullable
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle inState) {
		View v = inflater.inflate(layoutResId, container, false);
		toolbar = v.findViewById(R.id.toolbar);
		return v;
	}

	@Override
	public void onActivityCreated(Bundle inState) {
		super.onActivityCreated(inState);
		if (getToolbar() == null)
			return;
		onCreateOptionsMenu(getToolbar().getMenu(), getActivity().getMenuInflater());
		getToolbar().setOnMenuItemClickListener(menuItemClickListener);
		getToolbar().setNavigationOnClickListener(navigationClickListener);
	}

	protected void onNavigationClick() {
		getActivity().onBackPressed();
	}

	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {

	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		return false;
	}

	public CharSequence getTitle() {
		return getToolbar() != null ? getToolbar().getTitle() : "";
	}

	public void setTitle(int titleId) {
		setTitle(getString(titleId));
	}

	public void setTitle(CharSequence title) {
		if (getActivity() == null)
			return;
		title = ToolbarActivity.buildTitle(getActivity(), title, 20, textColorId);
		if (getToolbar() != null)
			getToolbar().setTitle(title);
	}
}
