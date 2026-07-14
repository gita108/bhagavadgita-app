package com.ethnoapp.bgita.screens;

import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.model.Quote;
import com.ethnoapp.bgita.utils.GitaUtils;
import com.ironwaterstudio.utils.Utils;

public class QuoteActivity extends ToolbarActivity {
	private TextView tvQoute;
	private TextView tvAuthor;

	public QuoteActivity() {
		super(R.layout.activity_quote);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setTitle(R.string.quote);

		tvQoute = findViewById(R.id.tv_quote);
		tvAuthor = findViewById(R.id.tv_author);

		setData();
	}

	public void setData() {
		Quote quote = (Quote) getIntent().getSerializableExtra(UiConstants.KEY_QUOTE);
		tvQoute.setText(quote.getText());
		tvAuthor.setText(quote.getAuthor());
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.menu_share, menu);
		menu.findItem(R.id.action_share).setIcon(GitaUtils.getTintedDrawable(this, R.drawable.ic_share, R.color.white));
		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			case android.R.id.home:
				onBackPressed();
				return true;
			case R.id.action_share:
				Utils.share(this, tvQoute.getText() + "\n" + tvAuthor.getText(), getResources().getString(R.string.share));
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}
}
