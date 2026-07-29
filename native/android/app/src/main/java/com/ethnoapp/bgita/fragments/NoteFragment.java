package com.ethnoapp.bgita.fragments;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.database.Db;
import com.ethnoapp.bgita.model.Sloka;
import com.ethnoapp.bgita.screens.ToolbarActivity;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ethnoapp.bgita.utils.GitaUtils;
import com.ironwaterstudio.utils.GaUtils;
import com.ironwaterstudio.utils.UiHelper;

public class NoteFragment extends Fragment {
	private EditText etNote;
	private Sloka sloka;

	@Nullable
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle inState) {
		View v = inflater.inflate(R.layout.fragment_note, container, false);
		etNote = v.findViewById(R.id.et_note);

		return v;
	}

	@Override
	public void onActivityCreated(Bundle inState) {
		super.onActivityCreated(inState);
		((ToolbarActivity) getActivity()).getToolbar().setNavigationIcon(R.drawable.ic_back);
		getActivity().setTitle(R.string.note);
		setHasOptionsMenu(true);
		sloka = Sloka.getSelectedSloka();
		setData();
	}

	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
		menu.findItem(R.id.action_save).setVisible(true);
		menu.findItem(R.id.action_search).setVisible(false);
		menu.findItem(R.id.action_bookmarks).setVisible(false);
	}

	@Override
	public void onStop() {
		super.onStop();
		UiHelper.hideKeyboard(getActivity());
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			case R.id.action_save:
				sloka = Sloka.getSelectedSloka();
				String note = etNote.getText().toString();
				sloka.setNote(note.length() > 0 ? note : null);
				Db.get().slokas().update(sloka);
				Db.get().saveChanges();
				getContext().sendBroadcast(new Intent(UiConstants.ACTION_CHANGE_NOTE));
				getActivity().onBackPressed();
				GaUtils.logEvent(UiConstants.GA_CATEGORY_UI, "Click save note");
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}

	private void setData() {
		etNote.setText(sloka.getNote() != null ? sloka.getNote() : "");
		etNote.requestFocus();
	}

	public static void show(Context context, FragmentManager fm) {
		NoteFragment noteFragment = new NoteFragment();
		Bundle args = new Bundle();
		noteFragment.setArguments(args);
		fm.beginTransaction()
				.replace(GitaUtils.getRightContainer(context), noteFragment)
				.addToBackStack(null)
				.commitAllowingStateLoss();
	}
}