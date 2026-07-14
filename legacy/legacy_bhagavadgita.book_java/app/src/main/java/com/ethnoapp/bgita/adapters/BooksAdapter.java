package com.ethnoapp.bgita.adapters;

import android.content.Context;
import android.view.ViewGroup;

import com.ethnoapp.bgita.adapters.holders.BookHolder;
import com.ethnoapp.bgita.model.Book;
import com.ethnoapp.bgita.model.BookManager;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.adapters.RecyclerArrayAdapter;

import java.util.ArrayList;

public class BooksAdapter extends RecyclerArrayAdapter<Book> {

	public BooksAdapter(Context context, ArrayList<Book> items) {
		super(context, items);
		for (Book book : items)
			book.setStatus(BookManager.getInstance().getStatus(book.getId(), book.getStatus()));
	}

	@Override
	public BaseHolder onCreateViewHolder(ViewGroup parent, int viewType) {
		return new BookHolder(parent);
	}

	public int indexAt(int bookId) {
		for (int i = 0; i < getItems().size(); i++) {
			if (getItem(i).getId() == bookId)
				return i;
		}
		return -1;
	}
}
