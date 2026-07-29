//
//  Book+DB.swift
//  Gita
//
//  Created by Olga Zhegulo  on 18/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

extension Book {
	static func loadAll() -> [Book] {
		var items = [Book]()
		
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = ["SELECT b.Id, b.LanguageId, b.Name, b.Initials, (SELECT COUNT(*) from Chapters c WHERE b.Id = c.BookId) as ChaptersCount",
						   "FROM Books b"]
			.joined(separator: "\n")
		
		let reader = cmd.executeReader()
		while reader.read() {
			let id = reader.int(0)
			let languageId = reader.int(1)
			let name = reader.string(2)
			let initials = reader.string(3)
			let chaptersCount = reader.int(4)
			
			let object = Book(id: id, languageId: languageId, name: name, initials: initials, chaptersCount: chaptersCount, isDownloaded: chaptersCount > 0)
			items.append(object)
		}
		
		reader.close()
		
		conn.close()
		
		return items
	}
	
	static func loadWithLanguages(_ languageIds: [Int], defaultBookId: Int) -> [Book] {
		var items = [Book]()
		
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		for i in 0..<languageIds.count {
			cmd.parameters.append(DbParameter(name: ":LanguageId\(i)", value: languageIds[i]))
		}
		
		var paramNames = [String]()
		for param in cmd.parameters {
			paramNames.append(param.name)
		}
		let paramList = paramNames.joined(separator: ", ")
		
		cmd.text = ["SELECT b.Id, b.LanguageId, b.Name, b.Initials, (SELECT COUNT(*) from Chapters c WHERE b.Id = c.BookId) as ChaptersCount",
						   "FROM Books b",
						   "WHERE LanguageId IN (\(paramList)) OR b.Id = :BookId",
			"ORDER BY b.Id"]
			.joined(separator: "\n")
		
		cmd.parameters.append(DbParameter(name: ":BookId", value: defaultBookId))
		
		let reader = cmd.executeReader()
		while reader.read() {
			let id = reader.int(0)
			let languageId = reader.int(1)
			let name = reader.string(2)
			let initials = reader.string(3)
			let chaptersCount = reader.int(4)
			
			let object = Book(id: id, languageId: languageId, name: name, initials: initials, chaptersCount: chaptersCount, isDownloaded: chaptersCount > 0)
			items.append(object)
		}
		
		reader.close()
		
		conn.close()
		
		return items
	}
	
	static func getByID(_ id: Int) -> Book? {
		var item: Book?
		
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = ["SELECT b.Id, b.LanguageId, b.Name, b.Initials, (SELECT COUNT(*) from Chapters c WHERE b.Id = c.BookId) as ChaptersCount",
					"FROM Books b",
					"WHERE b.Id = :BookId"]
			.joined(separator: "\n")
		cmd.parameters.append(DbParameter(name: ":BookId", value: id))

		let reader = cmd.executeReader()
		while reader.read() {
			let id = reader.int(0)
			let languageId = reader.int(1)
			let name = reader.string(2)
			let initials = reader.string(3)
			let chaptersCount = reader.int(4)
			
			item = Book(id: id, languageId: languageId, name: name, initials: initials, chaptersCount: chaptersCount, isDownloaded: chaptersCount > 0)
		}
		reader.close()
		
		conn.close()
		
		return item
	}

	static func deleteAllFromDB() -> Bool {
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		
		let cmd = DbCommand(connection: conn)
		cmd.text = "DELETE FROM Books"
		cmd.executeNonQuery()
		
		conn.close()
		
		return true
	}

	static func deleteDownloadedBookFromDB(_ id: Int) {
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		
		let cmd = DbCommand(connection: conn)
		cmd.text = "DELETE FROM Books WHERE Id = :Id"
		cmd.parameters.append(DbParameter(name: ":Id", value: id))
		cmd.executeNonQuery()
		
		conn.close()
	}
	
	static func insertAll(_ books: [Book]) {
		if books.count == 0 {
			return
		}
		
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		
		for book in books {
			_ = book.insertOrReplace(connection: conn)
		}
		conn.close()
	}
	
	func insertOrReplace(connection conn: DbConnection) -> Int {
		let cmd = DbCommand(connection: conn)
		cmd.text = "INSERT OR REPLACE INTO Books (Id, LanguageId, Name, Initials) VALUES(:Id, :LanguageId, :Name, :Initials)"
		cmd.parameters.append(DbParameter(name: ":Id", value: self.id))
		cmd.parameters.append(DbParameter(name: ":LanguageId", value: self.languageId))
		cmd.parameters.append(DbParameter(name: ":Name", value: self.name))
		cmd.parameters.append(DbParameter(name: ":Initials", value: self.initials))
		cmd.executeNonQuery()
		
		return cmd.lastInsertedId()
	}

	func insertOrReplace() -> Int {
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let lastInsertedId = self.insertOrReplace(connection: conn)
		conn.close()
		
		return lastInsertedId
	}
	
	//MARK: - Business logic
	static func hasAudio(_ bookId: Int, isSanskrit: Bool) -> Bool {
		//Check DB
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		
		cmd.text = [
			"SELECT DISTINCT",
			"(CASE WHEN LENGTH(s.Audio) > 0 THEN 1 ELSE 0 END) as HasAudio,",
			"(CASE WHEN LENGTH(s.AudioSanskrit) > 0 THEN 1 ELSE 0 END) as HasAudioSanskrit",
			"FROM Books b",
			"JOIN Chapters c ON b.Id = c.BookId",
			"JOIN Slokas s ON c.Id = s.ChapterId",
			"WHERE b.Id = :BookId"]
			.joined(separator: "\n")
		cmd.parameters.append(DbParameter(name: ":BookId", value: bookId))
		
		let reader = cmd.executeReader()
		var hasAudio = false
		while reader.read() {
			if !isSanskrit {
				if reader.bool(0) {
					hasAudio = true
					break
				}
			} else if reader.bool(1) {
				hasAudio = true
				break
			}
		}
		
		reader.close()
		
		return hasAudio
	}
	
	static func audioPaths(_ bookId: Int, isSanskrit: Bool) -> [(Int, [String])] {
		//Check DB
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = [
			"SELECT c.\"Order\", s.\(isSanskrit ? "AudioSanskrit" : "Audio")",
			"FROM Books b",
			"JOIN Chapters c ON b.Id = c.BookId",
			"JOIN Slokas s ON c.Id = s.ChapterId",
			"WHERE b.Id = :BookId",
			"ORDER BY c.\"Order\", s.\"Order\""]
			.joined(separator: "\n")
		cmd.parameters.append(DbParameter(name: ":BookId", value: bookId))
		
		var chaptersFileNames = [(Int, [String])]()
		var fileNames = [String]()
		
		var currentChapter = -1
		
		let reader = cmd.executeReader()
		while reader.read() {
			let chapter = reader.int(0)
			let fileName = reader.string(1)
			
			if !String.isNilOrWhiteSpace(fileName) {
				if currentChapter <= 0 || chapter != currentChapter {
					//After chapter finished, append filenames to totals
					if currentChapter > 0 {
						chaptersFileNames.append((chapter: currentChapter, fileNames: fileNames))
						fileNames = [String]()
					}
					currentChapter = chapter
				}
				
				fileNames.append(fileName)
			}
		}
		
		//After last chapter finished and data not empty, append filenames to totals
		if currentChapter > 0 {
			chaptersFileNames.append((chapter: currentChapter, fileNames: fileNames))
		}

		reader.close()
		
		return chaptersFileNames
	}
}
