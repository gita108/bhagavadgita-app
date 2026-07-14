package com.ethnoapp.bgita.screens;

import android.os.Bundle;
import android.support.v7.widget.RecyclerView;
import android.view.MenuItem;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.adapters.LanguageAdapter;
import com.ethnoapp.bgita.decorations.DividerDecoration;
import com.ethnoapp.bgita.model.Language;
import com.ethnoapp.bgita.model.Languages;
import com.ethnoapp.bgita.server.DataService;
import com.ironwaterstudio.server.data.ApiResult;
import com.ironwaterstudio.server.listeners.CallListener;

public class LanguagesActivity extends ToolbarActivity {
	private RecyclerView rvLanguages;
	private Languages languages;
	private LanguageAdapter adapter;

	private CallListener getLanguagesListener = new CallListener(true) {
		@Override
		protected void onSuccess(ApiResult result) {
			super.onSuccess(result);
			languages = result.getData(Languages.class);
			adapter = new LanguageAdapter(getActivity(), languages);
			rvLanguages.setAdapter(adapter);
		}
	};

	public LanguagesActivity() {
		super(R.layout.activity_languages);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setTitle(R.string.language);
		getLanguagesListener.register(this);
		rvLanguages = findViewById(R.id.rv_languages);
		rvLanguages.addItemDecoration(new DividerDecoration(this, R.color.gray_4, R.dimen.divider_height, 0, DividerDecoration.MIDDLE | DividerDecoration.BOTTOM));
		DataService.getLanguages(false, getLanguagesListener);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			case android.R.id.home:
				onBackPressed();
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public void onBackPressed() {
		if (adapter != null) {
			Language.sync(adapter.getCheckedItems());
			setResult(RESULT_OK);
		}
		super.onBackPressed();
	}
}