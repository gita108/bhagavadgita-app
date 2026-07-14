package com.ethnoapp.bgita.adapters.holders;

import android.content.Intent;
import android.support.v7.widget.AppCompatImageButton;
import android.support.v7.widget.AppCompatImageView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.controls.SwipeLayout;
import com.ethnoapp.bgita.database.Db;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.model.Sloka;
import com.ethnoapp.bgita.model.SlokaInfo;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.utils.GaUtils;

public class BookmarkHolder extends BaseHolder<SlokaInfo> {
	private SwipeLayout swipeLayout;
	private AppCompatImageButton btnDelete;
	private RelativeLayout rlBookmark;
	private TextView tvName;
	private TextView tvNote;
	private AppCompatImageView ivNote;
	private boolean fromBookmark;

	private View.OnClickListener deleteClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			getContext().sendBroadcast(new Intent(UiConstants.ACTION_DELETE_BOOKMARK).putExtra(UiConstants.KEY_POS, getAdapterPosition()));
			Sloka sloka = Sloka.getSloka(getObject().getId());
			sloka.setBookmark(false);
			Db.get().slokas().update(sloka);
			Db.get().saveChanges();
			GaUtils.logEvent(UiConstants.GA_CATEGORY_UI, "Remove Bookmark");
		}
	};

	private View.OnClickListener bookmarkClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			Settings.getInstance().setSelectedId(getObject().getId());
			Settings.getInstance().save();
			getContext().sendBroadcast(new Intent(UiConstants.ACTION_SHOW_SLOKA).putExtra(UiConstants.KEY_SEND_SLOKA, Sloka.getSloka(getObject().getId())).putExtra(UiConstants.KEY_IS_BOOKMARK, fromBookmark));
			GaUtils.logEvent(UiConstants.GA_CATEGORY_SHOW_SLOKA, fromBookmark ? "Click at BookmarksScreen" : "Click at global search");
		}
	};

	public BookmarkHolder(ViewGroup parent, boolean fromBookmark) {
		super(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_bookmark, parent, false));
		this.fromBookmark = fromBookmark;
		swipeLayout = itemView.findViewById(R.id.swipe_layout);
		btnDelete = itemView.findViewById(R.id.btn_delete);
		rlBookmark = itemView.findViewById(R.id.rl_bookmark);
		tvName = itemView.findViewById(R.id.tv_name);
		tvNote = itemView.findViewById(R.id.tv_note);
		ivNote = itemView.findViewById(R.id.iv_note);

		btnDelete.setOnClickListener(deleteClickListener);
		rlBookmark.setOnClickListener(bookmarkClickListener);
		swipeLayout.setSwipePadding(getContext().getResources().getDimensionPixelSize(R.dimen.book_swipe_padding));
	}

	@Override
	public void update(SlokaInfo item) {
		super.update(item);
		swipeLayout.swipeView(false, false);
		swipeLayout.setLockSwipe(!fromBookmark);
		tvName.setText(String.format("%s %s", item.getSlokaName(), item.getChapterName()));
		ivNote.setVisibility(!TextUtils.isEmpty(item.getNote()) ? View.VISIBLE : View.GONE);
		tvNote.setVisibility(!TextUtils.isEmpty(item.getNote()) ? View.VISIBLE : View.GONE);
		tvNote.setText(!TextUtils.isEmpty(item.getNote()) ? item.getNote() : "");
	}
}