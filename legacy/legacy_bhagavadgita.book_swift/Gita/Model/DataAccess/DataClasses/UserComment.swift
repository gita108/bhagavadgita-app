//
//  UserComment.swift
//  Gita
//
//  Created by Olga Zhegulo on 25/05/2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//
//  Business level class


struct UserComment {
	let chapterOrder: Int
	let shlokaOrder: Int
	let text: String

	init(chapterOrder: Int, shlokaOrder:Int, text: String) {
		self.chapterOrder = chapterOrder
		self.shlokaOrder = shlokaOrder
		self.text = text
	}
}

extension UserComment: CustomStringConvertible {
	var description: String {
		return [
			"ChapterOrder: \(chapterOrder)",
			"ShlokaOrder: \(shlokaOrder)",
			"Text: \(text)"
			].joined(separator: ", ")
	}
}

extension UserComment {
	static func updateUserComment(chapterOrder: Int, shlokaOrder: Int, text: String) {
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text =
		"INSERT OR REPLACE INTO UserComments (ChapterOrder, SlokaOrder, Text) VALUES (:ChapterOrder, :SlokaOrder, :Text)"
		cmd.parameters.append(DbParameter(name: ":ChapterOrder", value: chapterOrder))
		cmd.parameters.append(DbParameter(name: ":SlokaOrder", value: shlokaOrder))
		cmd.parameters.append(DbParameter(name: ":Text", value: text))
		cmd.executeNonQuery()
		
		conn.close()
	}
}
