//
//  Chapter+DB.swift
//  Gita
//
//  Created by Olga Zhegulo  on 15/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

extension Chapter {
	//MARK: CRUD operations
	static func loadAll() -> [Chapter] {
		var items = [Chapter]()
		
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = "SELECT Id, BookId, Name, \"Order\" FROM Chapters"
		let reader = cmd.executeReader()
		while reader.read() {
			let id = reader.int(0)
			let bookId = reader.int(1)
			let name = reader.string(2)
			let order = reader.int(3)
			
			let object = Chapter(id: id, bookId: bookId, name: name, order: order, shlokas: [])
			items.append(object)
		}
		
		reader.close()
		
		conn.close()
		return items
	}
	
	static func insertOrReplaceAll(_ chapters: [Chapter]) {
		if chapters.count == 0 {
			return
		}
		
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		
		for chapter in chapters {
			//TODO: probably optimize insert by joining lists of nested objects by type for all parents
			_ = chapter.insertOrReplace(connection: conn)
		}
		conn.close()
	}
	
	func insertOrReplace(connection conn: DbConnection) -> Int {
		//NOTE: use transaction to speed up mass insert operation; added it to mass insert called on top level
		let cmd = DbCommand(connection: conn, text: "BEGIN TRANSACTION")
		cmd.executeNonQuery()
		
		let chapterId = insertOrReplaceBase(connection: conn)
		if chapterId > 0
		{
			for shloka in self.shlokas {
				shloka.chapterId = chapterId
			}
			Shloka.insertOrReplaceAll(connection: conn, shlokas: self.shlokas)
		}
		
		let cmd1 = DbCommand(connection: conn)
		cmd1.text = "COMMIT TRANSACTION"
		cmd1.executeNonQuery()
		
		return chapterId > 0 ? chapterId : -1
	}
	
	func insertOrReplaceBase(connection conn: DbConnection) -> Int {
		let cmd = DbCommand(connection: conn)
		//NOTE: chapter Id will be assigned automatically
		cmd.text = "SELECT Id FROM Chapters WHERE BookId = :BookId AND \"Order\" = :Order"
		cmd.parameters.append(DbParameter(name: ":BookId", value: self.bookId))
		cmd.parameters.append(DbParameter(name: ":Order", value: self.order))
		
		var isNew = true
		let reader = cmd.executeReader()
		while reader.read() {
			isNew = false
		}
		
		reader.close()
		
		let cmd1 = DbCommand(connection: conn)
		cmd1.text = isNew ?
			"INSERT INTO Chapters (BookId, Name, \"Order\") VALUES(:BookId, :Name, :Order)" :
		"UPDATE Chapters SET Name = :Name WHERE BookId = :BookId AND \"Order\" = :Order"
		
		cmd1.parameters.append(DbParameter(name: ":BookId", value: self.bookId))
		cmd1.parameters.append(DbParameter(name: ":Order", value: self.order))
		cmd1.parameters.append(DbParameter(name: ":Name", value: self.name))
		cmd1.executeNonQuery()
		
		return cmd1.lastInsertedId()
	}
}
