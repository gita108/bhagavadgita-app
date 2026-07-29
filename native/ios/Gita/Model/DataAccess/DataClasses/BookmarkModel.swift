//
//  BookmarkModel.swift
//  Gita
//
//  Created by Olga Zhegulo on 22/05/2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//
//  Business level class


struct BookmarkModel {
	//Keys (for get from DB, for bookmarks)
	let chapterOrder: Int
	let shlokaOrder: Int
	//E.g. 1:32-34
	var name: String
	let chapterName: String
	var comment: String

	init(chapterOrder: Int, shlokaOrder: Int, name: String, chapterName: String, comment: String) {
		self.chapterOrder = chapterOrder
		self.shlokaOrder = shlokaOrder
		self.name = name
		self.chapterName = chapterName
		self.comment = comment
	}
}

extension BookmarkModel: CustomStringConvertible {
	var description: String {
		return [
			"ShlokaOrder: \(shlokaOrder)",
			"ChapterOrder: \(chapterOrder)",
			"Name: \(name)",
			"ChapterName: \(chapterName)",
			"Comment: \(comment)",
			].joined(separator: ", ")
	}
}

extension BookmarkModel {
	static func loadAll() -> [BookmarkModel] {
		var items = [BookmarkModel]()
		
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = ["SELECT bm.ChapterOrder, bm.SlokaOrder, s.Name as Name, c.Name as ChapterName, u.Text",
					"FROM Bookmarks bm",
					"JOIN Chapters c ON c.BookId = :BookId AND bm.ChapterOrder = c.\"Order\"",
					"JOIN Slokas s ON c.Id = s.ChapterId AND bm.SlokaOrder = s.\"Order\"",
					"LEFT JOIN UserComments u ON bm.SlokaOrder = u.SlokaOrder AND bm.ChapterOrder = u.ChapterOrder",
					"WHERE bm.IsDeleted = 0",
					"ORDER BY bm.ChapterOrder, bm.SlokaOrder"]
			.joined(separator: "\n")
		cmd.parameters.append(DbParameter(name: ":BookId", value: Settings.shared.defaultBookId))
		
		let reader = cmd.executeReader()
		while reader.read() {
			let chapterOrder = reader.int(0)
			let shlokaOrder = reader.int(1)
			var shlokaName = reader.string(2)
			if String.isNilOrWhiteSpace(shlokaName) {
				shlokaName = "\(chapterOrder).\(shlokaOrder)"
			}
			let chapterName = reader.string(3)
			let comment = reader.string(4)
			
			let object = BookmarkModel(chapterOrder: chapterOrder, shlokaOrder: shlokaOrder, name: shlokaName, chapterName: chapterName, comment: comment)
			items.append(object)
		}
		
		reader.close()

		conn.close()
		
		return items
	}
}
