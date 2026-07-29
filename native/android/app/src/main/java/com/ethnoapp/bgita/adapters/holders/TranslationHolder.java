package com.ethnoapp.bgita.adapters.holders;

import android.content.Context;
import android.support.v4.content.ContextCompat;
import android.text.SpannableStringBuilder;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.model.Translation;
import com.ironwaterstudio.adapters.BaseHolder;
import com.ironwaterstudio.controls.TypefaceSpanEx;
import com.ironwaterstudio.utils.TypefaceCache;

public class TranslationHolder extends BaseHolder<Translation> {
	private static final int CODE_LENGTH = 2;

	private TextView tvDivider;
	private TextView tvTranslation;

	public TranslationHolder(ViewGroup parent) {
		super(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_translation, parent, false));
		tvDivider = itemView.findViewById(R.id.tv_divider);
		tvTranslation = itemView.findViewById(R.id.tv_translation);
	}

	@Override
	public void update(Translation item) {
		super.update(item);
		tvDivider.setBackground(ContextCompat.getDrawable(getContext(), item.getLanguageCode().length() > CODE_LENGTH ? R.drawable.divider_language_name : R.drawable.divider_language));
		tvDivider.setText(buildLanguageCode(getContext(), item.getLanguageCode()));
		tvTranslation.setText(item.getText());
	}

	private CharSequence buildLanguageCode(Context context, String languageCode) {
		if (languageCode.length() <= CODE_LENGTH)
			return languageCode;
		SpannableStringBuilder sb = new SpannableStringBuilder();
		String[] str = languageCode.split(" ");
		sb.append(str[0]);
		sb.append(" ");
		TypefaceSpanEx.appendText(context, sb, TypefaceCache.Font.BOLD_ITALIC, 12, R.color.red_1, str[1]);
		return sb;
	}
}
