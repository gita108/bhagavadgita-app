package com.ethnoapp.bgita.adapters.holders;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.controls.SwipeLayout;
import com.ethnoapp.bgita.model.Book;
import com.ethnoapp.bgita.model.BookManager;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.controls.TextViewEx;
import com.ironwaterstudio.utils.GaUtils;
import com.ironwaterstudio.utils.TypefaceCache;

public class BookHolder extends BaseHolder<Book> {
	private TextViewEx tvName;
	private ImageView ivDone;
	private Button btnDownload;
	private ImageButton btnDelete;
	private SwipeLayout swipeLayout;
	private TextViewEx tvProgress;

	private View.OnClickListener downloadClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			BookManager.getInstance().load(getObject());
			updateStatus(getObject());
			GaUtils.logEvent(UiConstants.GA_CATEGORY_DOWNLOAD, "Download book");
		}
	};

	private View.OnClickListener deleteClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			BookManager.getInstance().delete(getObject());
			swipeLayout.swipeView(false, false);
			update(getObject());
			GaUtils.logEvent(UiConstants.GA_CATEGORY_UI, "Remove book");
		}
	};

	public BookHolder(ViewGroup parent) {
		super(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_book, parent, false));
		tvName = itemView.findViewById(R.id.tv_name);
		ivDone = itemView.findViewById(R.id.iv_done);
		btnDownload = itemView.findViewById(R.id.btn_download);
		btnDelete = itemView.findViewById(R.id.btn_delete);
		swipeLayout = itemView.findViewById(R.id.swipe_layout);
		tvProgress = itemView.findViewById(R.id.tv_progress);

		btnDownload.setOnClickListener(downloadClickListener);
		btnDelete.setOnClickListener(deleteClickListener);
		swipeLayout.setSwipePadding(getContext().getResources().getDimensionPixelSize(R.dimen.book_swipe_padding));
	}

	@Override
	public void update(Book item) {
		super.update(item);
		tvName.setText(item.getName());
		tvName.setFont(getContext(), item.getId() == Settings.getInstance().getBookId() ? TypefaceCache.Font.BOLD : TypefaceCache.Font.REGULAR);
		ivDone.setVisibility(item.getStatus() == Book.STATUS_SUCCESS ? View.VISIBLE : View.GONE);
		swipeLayout.setLockSwipe(item.getStatus() != Book.STATUS_SUCCESS || item.getId() == Settings.getInstance().getBookId());
		tvName.setEnabled(item.getId() != Settings.getInstance().getBookId());
		updateStatus(item);
	}

	private void updateStatus(Book item) {
		btnDownload.setVisibility(item.getStatus() == Book.STATUS_NO ? View.VISIBLE : View.GONE);
		btnDownload.setEnabled(item.getStatus() == Book.STATUS_NO || item.getStatus() == Book.STATUS_ERROR);
		btnDownload.setText(item.getStatusText(getContext()));
		tvProgress.setVisibility(item.getStatus() == Book.STATUS_PROGRESS_LOAD || item.getStatus() == Book.STATUS_PROGRESS_DELETE ? View.VISIBLE : View.GONE);
		tvProgress.setText(item.getStatus() == Book.STATUS_PROGRESS_LOAD ? R.string.loading : R.string.deleting);
	}
}