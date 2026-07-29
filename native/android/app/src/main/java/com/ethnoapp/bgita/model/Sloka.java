package com.ethnoapp.bgita.model;

import com.ethnoapp.bgita.database.Db;
import com.ironwaterstudio.database.Column;
import com.ironwaterstudio.database.DbOrderBy;
import com.ironwaterstudio.database.DbWhere;
import com.ironwaterstudio.database.IQuery;
import com.ironwaterstudio.database.Key;
import com.ironwaterstudio.database.NotMapped;
import com.ironwaterstudio.database.Table;
import com.ironwaterstudio.utils.Utils;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Table("Slokas")
public class Sloka implements Serializable {
	@Key(false)
	private int id;
	private String name;
	private String text;
	private int chapterId;
	private String transcription;
	private String translation;
	private String comment;
	@Column("Position")
	private int order;
	private String audio;
	private String audioSanskrit;
	@NotMapped
	private ArrayList<Vocabulary> vocabularies;
	private boolean isBookmark;
	private String note;

	public Sloka() {
	}

	public int getId() {
		return id;
	}

	public int getChapterId() {
		return chapterId;
	}

	public void setChapterId(int chapterId) {
		this.chapterId = chapterId;
	}

	public String getName() {
		return name;
	}

	public String getText() {
		return text;
	}

	public String getTranscription() {
		return transcription;
	}

	public String getTranslation() {
		return translation;
	}

	public String getComment() {
		return comment;
	}

	public int getOrder() {
		return order;
	}

	public String getAudio() {
		return audio;
	}

	public String getAudioSanskrit() {
		return audioSanskrit;
	}

	public ArrayList<Vocabulary> getVocabularies() {
		return vocabularies;
	}

	public boolean isBookmark() {
		return isBookmark;
	}

	public void setBookmark(boolean bookmark) {
		isBookmark = bookmark;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public static void add(Sloka sloka, int chapterId) {
		sloka.setChapterId(chapterId);
		Db.get().slokas().add(sloka);
	}

	public static void remove(Sloka sloka) {
		Db.get().slokas().remove(sloka);
	}

	public static ArrayList<Sloka> getList(int chapterId) {
		return Db.get().slokas().where(new DbWhere("ChapterId", true).eq(chapterId)).orderBy("Position").toList();
	}

	public static Sloka getSloka(int slokaId) {
		return Db.get().slokas().where(new DbWhere("Id").eq(slokaId)).single();
	}

	public static int getCount(int chapterId) {
		IQuery<Sloka> slokas = Db.get().slokas().where(new DbWhere("ChapterId", true).eq(chapterId));
		Sloka sloka = slokas.orderBy(new DbOrderBy("Position", false)).single();
		if (sloka == null)
			return 0;

		String name = sloka.getName();
		Pattern p = Pattern.compile("^.*\\D");
		Matcher m = p.matcher(name);
		return Utils.parseInt(m.find() ? name.substring(m.end()) : name, slokas.count());
	}

	public static ArrayList<SlokaIds> getSortedIds() {
		return Db.get().slokas().select(SlokaIds.class, "Slokas.Id").join("Chapters", new DbWhere("Slokas.ChapterId", false).eq("Chapters.Id").and("Chapters.BookId", false).eq(Settings.getInstance().getBookId()))
				.orderBy(new DbOrderBy("Slokas.ChapterId").and("Slokas.Position")).toList();
	}

	public static Sloka getSelectedSloka() {
		return getSloka(Settings.getInstance().getSelectedId());
	}
}
