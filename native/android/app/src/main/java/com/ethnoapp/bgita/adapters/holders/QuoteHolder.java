package com.ethnoapp.bgita.adapters.holders;

import android.app.Activity;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.model.Quote;
import com.ethnoapp.bgita.screens.QuoteActivity;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.utils.UiHelper;
import com.ironwaterstudio.utils.Utils;

public class QuoteHolder extends BaseHolder<Quote> {
	private TextView tvText;
	private ImageView ivShare;
	private RelativeLayout rlQuote;

	private View.OnClickListener quoteClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			Intent intent = new Intent(getContext(), QuoteActivity.class).putExtra(UiConstants.KEY_QUOTE, getObject());
			UiHelper.showActivity((Activity) getContext(), intent);
		}
	};

	private View.OnClickListener shareClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			Utils.share(getContext(), getObject().getText() + "\n" + getObject().getAuthor(), getContext().getResources().getString(R.string.share));
		}
	};

	public QuoteHolder(ViewGroup parent) {
		super(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_quote, parent, false));
		tvText = itemView.findViewById(R.id.tv_text);
		rlQuote = itemView.findViewById(R.id.rl_quote);
		ivShare = itemView.findViewById(R.id.iv_share);

		rlQuote.setOnClickListener(quoteClickListener);
		ivShare.setOnClickListener(shareClickListener);
	}

	@Override
	public void update(Quote item) {
		super.update(item);
		tvText.setText(item.getText());
	}
}