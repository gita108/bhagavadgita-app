package com.ethnoapp.bgita.adapters.holders;

import android.content.Intent;
import android.support.v4.content.ContextCompat;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.adapters.ISelected;
import com.ethnoapp.bgita.model.Sloka;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.utils.GaUtils;

public class SlokaHolder extends BaseHolder<Sloka> {
	private TextView tvSloka;
	private ImageView ivBookmark;

	public enum Payloads {UPDATE_BACKGROUND, UPDATE_BOOKMARK, CHANGE_BOOKMARK}

	private ISelected iSelected;
	private View.OnClickListener slokaClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			iSelected.setSelectedId(getObject().getId());
			getContext().sendBroadcast(new Intent(UiConstants.ACTION_SHOW_SLOKA).putExtra(UiConstants.KEY_SEND_SLOKA, getObject()).putExtra(UiConstants.KEY_IS_BOOKMARK, false));
			GaUtils.logEvent(UiConstants.GA_CATEGORY_SHOW_SLOKA, "Click on sloka");
		}
	};

	public SlokaHolder(ViewGroup parent) {
		super(R.layout.item_sloka, parent);
		tvSloka = itemView.findViewById(R.id.tv_sloka);
		ivBookmark = itemView.findViewById(R.id.iv_bookmark);
		tvSloka.setOnClickListener(slokaClickListener);
	}

	public void setISelected(ISelected iSelected) {
		this.iSelected = iSelected;
	}

	@Override
	public void update(Sloka item) {
		super.update(item);
		String[] names = item.getName().split("\\.");
		tvSloka.setText(names.length > 1 ? names[1] : item.getName());
		updateBackground();
		updateBookmark();
	}

	public void updateBackground() {
		tvSloka.setBackground(ContextCompat.getDrawable(getContext(), iSelected.getSelectedId() == getObject().getId() ? R.drawable.circlre_shlock_number : R.drawable.circle_selector));
	}

	public void updateBookmark() {
		ivBookmark.setVisibility(getObject().isBookmark() ? View.VISIBLE : View.GONE);
	}
}