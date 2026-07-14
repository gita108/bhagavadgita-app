//
//  Bookmark.swift
//  Gita
//
//  Created by Olga Zhegulo on 22/05/2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//
//  Business level class


struct Bookmark {
	let chapterOrder: Int
	let shlokaOrder: Int
	let isDeleted: Bool

	init(chapterOrder: Int, shlokaOrder:Int) {
		self.chapterOrder = chapterOrder
		self.shlokaOrder = shlokaOrder
		self.isDeleted = false
	}
}

extension Bookmark: CustomStringConvertible {
	var description: String {
		return [
			"ChapterOrder: \(chapterOrder)",
			"ShlokaOrder: \(shlokaOrder)",
			"IsDeleted: \(isDeleted)"
			].joined(separator: ", ")
	}
}

extension Bookmark {
	static func updateBookmarked(chapterOrder: Int, shlokaOrder: Int, bookmarked: Bool) {
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = bookmarked ?
			"INSERT OR REPLACE INTO Bookmarks (ChapterOrder, SlokaOrder, IsDeleted) VALUES (:ChapterOrder, :SlokaOrder, :IsDeleted)" :
			"UPDATE Bookmarks SET IsDeleted = :IsDeleted WHERE ChapterOrder = :ChapterOrder AND SlokaOrder = :SlokaOrder"
		cmd.parameters.append(DbParameter(name: ":ChapterOrder", value: chapterOrder))
		cmd.parameters.append(DbParameter(name: ":SlokaOrder", value: shlokaOrder))
		cmd.parameters.append(DbParameter(name: ":IsDeleted", value: !bookmarked))
		cmd.executeNonQuery()
		conn.close()
	}
}
