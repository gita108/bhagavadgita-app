package com.ethnoapp.bgita.adapters.holders;

import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.model.Commentary;
import com.ironwaterstudio.adapters.BaseHolder;

public class CommentaryHolder extends BaseHolder<Commentary> {
	private TextView tvInitials;
	private TextView tvName;
	private TextView tvCommentary;

	public CommentaryHolder(ViewGroup parent) {
		super(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_commentary, parent, false));
		tvInitials = itemView.findViewById(R.id.tv_initials);
		tvName = itemView.findViewById(R.id.tv_name);
		tvCommentary = itemView.findViewById(R.id.tv_commentary);
	}

	@Override
	public void update(Commentary item) {
		super.update(item);
		tvInitials.setText(item.getInitials());
		tvName.setText(item.getName());
		tvCommentary.setText(item.getCommentary());
	}
}
