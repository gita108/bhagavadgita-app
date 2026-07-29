package com.ethnoapp.bgita.model;

import android.content.Context;
import android.text.SpannableStringBuilder;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.database.Db;
import com.ironwaterstudio.controls.TypefaceSpanEx;
import com.ironwaterstudio.database.DbWhere;
import com.ironwaterstudio.database.Key;
import com.ironwaterstudio.database.Table;
import com.ironwaterstudio.utils.TypefaceCache;

import java.util.ArrayList;

@Table("Vocabularies")
public class Vocabulary {
	@Key
	private int id;
	private String text;
	private int slokaId;
	private String translation;

	public Vocabulary() {
	}

	public int getId() {
		return id;
	}

	public int getSlokaId() {
		return slokaId;
	}

	public void setSlokaId(int slokaId) {
		this.slokaId = slokaId;
	}

	public String getText() {
		return text;
	}

	public String getTranslation() {
		return translation;
	}

	public static void add(Vocabulary vocabulary, int slokaId) {
		vocabulary.setSlokaId(slokaId);
		Db.get().vocabularies().add(vocabulary);
	}

	public static void remove(Vocabulary vocabulary) {
		Db.get().vocabularies().remove(vocabulary);
	}

	public static ArrayList<Vocabulary> getList(int slokaId) {
		return Db.get().vocabularies().where(new DbWhere("SlokaId", true).eq(slokaId)).toList();
	}

	public static ArrayList<Vocabulary> getList() {
		return Db.get().vocabularies().toList();
	}

	public static CharSequence buildDictionary(Context context, ArrayList<Vocabulary> words) {
		SpannableStringBuilder sb = new SpannableStringBuilder();
		for (int i = 0; i < words.size(); i++) {
			TypefaceSpanEx.appendText(context, sb, TypefaceCache.Font.BOLD_ITALIC, 18, R.color.gray_1, words.get(i).getText());
			sb.append(" - ");
			sb.append(words.get(i).getTranslation());
			sb.append(i != words.size() - 1 ? "; " : ".");
		}
		return sb;
	}
}