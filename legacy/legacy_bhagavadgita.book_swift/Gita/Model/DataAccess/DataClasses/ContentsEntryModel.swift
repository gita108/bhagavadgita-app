//
//  ContentsEntryModel..swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 23/05/2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//
//  Business level

class ShlokaEntryModel {
	var name: String
	var order: Int
	var isBookmarked: Bool
	
	init(name: String, order: Int, isBookmarked: Bool) {
		self.name = name
		self.order = order
		self.isBookmarked = isBookmarked
	}
	
	convenience init() {
		self.init(name:String(), order:Int(), isBookmarked:Bool())
	}
}

extension ShlokaEntryModel: CustomStringConvertible {
	var description: String {
		return [
			"Name: \(name)",
			"Order: \(order)",
			"IsBookmarked: \(isBookmarked)"
			].joined(separator: ", ")
	}
}

class ContentsEntryModel {
	var chapterOrder: Int
	var name: String
	var shlokas: [ShlokaEntryModel]

	init(chapterOrder: Int, name: String, shlokas: [ShlokaEntryModel]) {
		self.chapterOrder = chapterOrder
		self.name = name
		self.shlokas = shlokas
	}

	convenience init(chapterOrder: Int) {
		self.init(chapterOrder:chapterOrder, name:String(), shlokas:[ShlokaEntryModel]())
	}

	convenience init() {
		self.init(chapterOrder:Int(), name:String(), shlokas:[ShlokaEntryModel]())
	}
}

extension ContentsEntryModel: CustomStringConvertible {
	var description: String {
		return [
			"ChapterOrder: \(chapterOrder)",
			"Name: \(name)",
			"Shlokas: \(shlokas)"
			].joined(separator: ", ")
	}
}

extension ContentsEntryModel {
	static func getContents() -> [ContentsEntryModel] {
		var items = [ContentsEntryModel]()
		
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = [
			"SELECT DISTINCT c.\"Order\", c.Name, s.Name as ShlokaName, s.\"Order\", CASE WHEN (b.IsDeleted IS NULL OR b.IsDeleted = 1) THEN -1 ELSE b.SlokaOrder END as Bookmark",
			"FROM Chapters c",
			"JOIN Slokas s ON c.Id = s.ChapterId",
			"LEFT JOIN Bookmarks b ON c.\"Order\" = b.ChapterOrder AND s.\"Order\" = b.SlokaOrder",
			"WHERE c.BookId = :BookId",
			"ORDER BY c.\"Order\", s.\"Order\""]
			.joined(separator: "\n")
		cmd.parameters.append(DbParameter(name: ":BookId", value: Settings.shared.defaultBookId))
		
		let reader = cmd.executeReader()
		var currentEntry : ContentsEntryModel?
		
		while reader.read() {
			let chapterOrder = reader.int(0)
			let name = reader.string(1)
			let shlokaName = reader.string(2)
			let shlokaOrder = reader.int(3)
			let bookmark = reader.int(4)
			let shlokaTitle = !String.isNilOrWhiteSpace(shlokaName) ? shlokaName : "\(chapterOrder)\(shlokaOrder)"
			
			if currentEntry == nil || currentEntry!.chapterOrder != chapterOrder {
				currentEntry = ContentsEntryModel(chapterOrder: chapterOrder)
				
				currentEntry!.name = name
				
				//Set shlokas with current number
				currentEntry!.shlokas = [ShlokaEntryModel(name: shlokaTitle, order: shlokaOrder, isBookmarked: bookmark > 0)]
				
				items.append(currentEntry!)
			} else {
				//Append shloka to current chapter
				currentEntry!.shlokas.append(ShlokaEntryModel(name: shlokaTitle, order: shlokaOrder, isBookmarked: bookmark > 0))
			}			
		}
		
		reader.close()
		conn.close()
		
		return items
	}
}
