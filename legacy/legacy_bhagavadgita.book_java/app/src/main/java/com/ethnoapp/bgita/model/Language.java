package com.ethnoapp.bgita.model;

import android.text.TextUtils;

import com.ethnoapp.bgita.database.Db;
import com.ironwaterstudio.database.Key;
import com.ironwaterstudio.database.NotMapped;
import com.ironwaterstudio.database.Table;

import java.util.ArrayList;
import java.util.Locale;

@Table("Languages")
public class Language {
	@Key(false)
	private int id;
	private String name;
	private String code;
	@NotMapped
	private transient boolean checked = false;

	public Language() {
	}

	public int getId() {
		return id;
	}

	public String getName() {
		return name;
	}

	public String getCode() {
		return code;
	}

	public String getFormattedCode() {
		return !TextUtils.isEmpty(code) ? code.replace(code.charAt(0), Character.toUpperCase(code.charAt(0))) : "";
	}

	public boolean isChecked() {
		return checked;
	}

	public void setChecked(boolean checked) {
		this.checked = checked;
	}

	public static void add(Language language) {
		Db.get().languages().add(language);
	}

	public static ArrayList<Language> getList() {
		return Db.get().languages().toList();
	}

	public static Language getDefaultLanguage(ArrayList<Language> languages) {
		if (languages == null || languages.isEmpty())
			return null;
		String currentCode = Locale.getDefault().getLanguage();
		Language language = find(languages, currentCode);
		if (language == null)
			language = find(languages, "en");
		return language != null ? language : languages.get(0);
	}

	public static boolean contains(ArrayList<Language> languages, int languageId) {
		for (Language item : languages)
			if (item.getId() == languageId)
				return true;
		return false;
	}

	public static void sync(ArrayList<Language> languages) {
		ArrayList<Language> languagesFromDb = getList();
		for (Language item : languages) {
			Language language = find(languagesFromDb, item.getId());
			if (language != null) {
				Db.get().languages().update(item);
				languagesFromDb.remove(language);
			} else {
				Db.get().languages().add(item);
			}
		}
		for (Language item : languagesFromDb) {
			Db.get().languages().remove(item);
		}
		Db.get().saveChanges();
	}

	public static ArrayList<Integer> getLanguageIds(ArrayList<Language> languages) {
		ArrayList<Integer> result = new ArrayList<>();
		for (int i = 0; i < languages.size(); i++)
			result.add(languages.get(i).getId());
		return result;
	}

	public static String getLanguagesText(ArrayList<Language> languages) {
		StringBuilder sb = new StringBuilder("");
		for (int i = 0; i < languages.size(); i++) {
			sb.append(languages.get(i).getName());
			sb.append(i != languages.size() - 1 ? ", " : "");
		}
		return sb.toString();
	}

	private static Language find(ArrayList<Language> languages, String code) {
		for (Language item : languages)
			if (TextUtils.equals(code, item.getCode())) {
				return item;
			}
		return null;
	}

	private static Language find(ArrayList<Language> languages, int languageId) {
		for (Language item : languages)
			if (item.getId() == languageId) {
				return item;
			}
		return null;
	}
}
