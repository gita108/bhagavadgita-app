package com.ethnoapp.bgita.model;

import android.text.TextUtils;

import com.ethnoapp.bgita.database.Db;
import com.ironwaterstudio.database.DbWhere;
import com.ironwaterstudio.database.IQuery;

import java.util.ArrayList;

public class SlokaInfo {
	private int id;
	private int languageId;
	private String translation;
	private String comment;
	private String languageCode;
	private String bookInitials;
	private String bookName;
	private String chapterName;
	private String slokaName;
	private String note;
	private int chapterId;
	private int chapterOrder;
	private int slokaOrder;

	public int getId() {
		return id;
	}

	public String getTranslation() {
		return translation;
	}

	public String getComment() {
		return comment;
	}

	public int getLanguageId() {
		return languageId;
	}

	public String getLanguageCode() {
		return !TextUtils.isEmpty(languageCode) ? languageCode.replace(languageCode.charAt(0), Character.toUpperCase(languageCode.charAt(0))) : "";
	}

	public String getBookInitials() {
		return bookInitials;
	}

	public String getBookName() {
		return bookName;
	}

	public String getChapterName() {
		return chapterName;
	}

	public String getSlokaName() {
		return slokaName;
	}

	public String getNote() {
		return note;
	}

	public int getChapterId() {
		return chapterId;
	}

	public int getChapterOrder() {
		return chapterOrder;
	}

	public int getSlokaOrder() {
		return slokaOrder;
	}

	public static ArrayList<SlokaInfo> getList(int chapterId, int order) {
		return getSlokaInfosQuery(chapterId, order).toList();
	}

	public static SlokaInfo getSlokaInfo(int id) {
		return Db.get().slokas().join("Chapters", new DbWhere("Slokas.ChapterId", false).eq("Chapters.Id"))
				.select(SlokaInfo.class, "Slokas.Id as id", "Chapters.Name as chapterName", "Slokas.Name as slokaName", "Slokas.Note as note", "Chapters.Id as chapterId", "Chapters.Position as chapterOrder", "Slokas.Position as slokaOrder")
				.where(new DbWhere("Slokas.Id").eq(id)).single();
	}

	public static ArrayList<SlokaInfo> getBookmarksList() {
		return Db.get().slokas().join("Chapters", new DbWhere("Slokas.IsBookmark").eq(1).and("Slokas.ChapterId", false).eq("Chapters.Id"))
				.select(SlokaInfo.class, "Slokas.Id as id", "Chapters.Name as chapterName", "Slokas.Name as slokaName", "Slokas.Note as note", "Chapters.Id as chapterId", "Chapters.Position as chapterOrder", "Slokas.Position as slokaOrder")
				.toList();
	}

	public static ArrayList<SlokaInfo> getFindSlokaInfos(String findText) {
		return Db.get().slokas().join("Chapters", new DbWhere("Slokas.ChapterId", false).eq("Chapters.Id").and("Chapters.BookId").eq(Settings.getInstance().getBookId()))
				.select(SlokaInfo.class, "Slokas.Id as id", "Chapters.Name as chapterName", "Slokas.Name as slokaName", "Slokas.Note as note", "Chapters.Id as chapterId", "Chapters.Position as chapterOrder", "Slokas.Position as slokaOrder")
				.where(new DbWhere(String.format("(Slokas.Name LIKE '%%%s%%' OR Slokas.Text LIKE '%%%s%%' OR Slokas.Transcription LIKE '%%%s%%' OR Slokas.Translation LIKE '%%%s%%' OR Slokas.Comment LIKE '%%%s%%'  OR Chapters.Name LIKE '%%%s%%')", findText, findText, findText, findText, findText, findText)))
				.toList();
	}

	public static ArrayList<Translation> getTranslations(ArrayList<SlokaInfo> slokaInfos) {
		ArrayList<Translation> result = new ArrayList<>();
		for (SlokaInfo slokaInfo : slokaInfos) {
			result.add(new Translation(isMultipleBooks(slokaInfos, slokaInfo.getLanguageId())
					? slokaInfo.getLanguageCode() + " " + slokaInfo.getBookInitials()
					: slokaInfo.getLanguageCode(), slokaInfo.getTranslation()));
		}
		return result;
	}

	public static ArrayList<Commentary> getCommentaries(ArrayList<SlokaInfo> slokaInfos) {
		ArrayList<Commentary> result = new ArrayList<>();
		for (SlokaInfo slokaInfo : slokaInfos) {
			if (!TextUtils.isEmpty(slokaInfo.getComment()))
				result.add(new Commentary(slokaInfo.getBookInitials(), slokaInfo.getBookName(), slokaInfo.getComment()));
		}
		return result;
	}

	public static SlokaInfo find(ArrayList<SlokaInfo> slokaInfos, int id) {
		for (SlokaInfo slokaInfo : slokaInfos) {
			if (slokaInfo.getId() == id)
				return slokaInfo;
		}
		return null;
	}

	private static boolean isMultipleBooks(ArrayList<SlokaInfo> slokaInfos, int languageId) {
		int count = 0;
		for (SlokaInfo slokaInfo : slokaInfos) {
			count += slokaInfo.getLanguageId() == languageId ? 1 : 0;
			if (count > 1)
				return true;
		}
		return false;
	}

	private static IQuery<SlokaInfo> getSlokaInfosQuery(int chapterId, int order) {
		return Db.get().slokas().join("Chapters", new DbWhere("Slokas.ChapterId", false).eq("Chapters.Id"))
				.join("Books", new DbWhere("Chapters.BookId", false).eq("Books.Id"))
				.join("Languages", new DbWhere("Books.LanguageId", false).eq("Languages.Id"))
				.where(new DbWhere("Slokas.Position", false).eq(order)
						.and("Chapters.Position", false).eq(Db.get().chapters().join("Slokas", new DbWhere("Chapters.Id", false).eq(chapterId)).single().getOrder()))
				.select(SlokaInfo.class, "Slokas.Id as id", "Slokas.Translation as translation", "Slokas.Comment as comment", "Languages.Id as languageId", "Languages.Code as languageCode",
						"Books.Initials as bookInitials", "Books.Name as bookName", "Chapters.Name as chapterName", "Slokas.Name as slokaName", "Slokas.Note as note", "Chapters.Id as chapterId",
						"Chapters.Position as chapterOrder", "Slokas.Position as slokaOrder");
	}
}