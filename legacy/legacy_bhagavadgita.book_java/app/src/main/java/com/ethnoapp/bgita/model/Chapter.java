package com.ethnoapp.bgita.model;

import com.ethnoapp.bgita.database.Db;
import com.ironwaterstudio.database.Column;
import com.ironwaterstudio.database.DbWhere;
import com.ironwaterstudio.database.Key;
import com.ironwaterstudio.database.NotMapped;
import com.ironwaterstudio.database.Table;

import java.util.ArrayList;

@Table("Chapters")
public class Chapter {
	@Key(false)
	private int id;
	private int bookId;
	private String name;
	@Column("Position")
	private int order;
	@NotMapped
	private ArrayList<Sloka> slokas;
	@NotMapped
	private ArrayList<Sloka> slokasFromDb;
	@NotMapped
	private int slokasCount;

	public Chapter() {
	}

	public int getId() {
		return id;
	}

	public int getBookId() {
		return bookId;
	}

	public void setBookId(int bookId) {
		this.bookId = bookId;
	}

	public String getName() {
		return name;
	}

	public int getOrder() {
		return order;
	}

	public ArrayList<Sloka> getSlokas() {
		return slokas;
	}


	public ArrayList<Sloka> getSlokasFromDb() {
		if (slokasFromDb == null)
			slokasFromDb = Sloka.getList(getId());
		return slokasFromDb;
	}

	public void setSlokas(ArrayList<Sloka> slokas) {
		this.slokas = slokas;
	}

	public int getSlokasCount() {
		return slokasCount;
	}

	public void setSlokasCount(int slokasCount) {
		this.slokasCount = slokasCount;
	}

	public static void add(Chapter chapter, int bookId) {
		chapter.setBookId(bookId);
		Db.get().chapters().add(chapter);
	}

	public static void remove(Chapter chapter) {
		Db.get().chapters().remove(chapter);
	}

	public static ArrayList<Chapter> getList(int bookId) {
		ArrayList<Chapter> result = Db.get().chapters().where(new DbWhere("BookId", true).eq(bookId)).orderBy("Position").toList();
		for (Chapter chapter : result)
			chapter.setSlokasCount(Sloka.getCount(chapter.getId()));
		return result;
	}

	public void updateBookmark(Sloka sloka) {
		if (slokasFromDb == null)
			return;

		for (Sloka sl : slokasFromDb)
			if (sl.getId() == sloka.getId()) {
				sl.setBookmark(sloka.isBookmark());
				return;
			}
	}
}
