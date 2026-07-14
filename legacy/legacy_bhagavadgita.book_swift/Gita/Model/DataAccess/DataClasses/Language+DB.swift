//
//  Language+DB.swift
//  Gita
//
//  Created by Olga Zhegulo  on 18/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

extension Language {
	
	static func loadAll() -> [Language] {
		var items = [Language]()
		
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = "SELECT Id, Name, Code, IsSelected FROM Languages"
		let reader = cmd.executeReader()
		while reader.read() {
			let id = reader.int(0)
			let name = reader.string(1)
			let code = reader.string(2)
			let isSelected = reader.bool(3)
			
			let object = Language(id: id, name: name, code: code, isSelected: isSelected)
			items.append(object)
		}
		
		reader.close()
		
		conn.close()
		
		return items
	}
	
	static func deleteAll() {
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = "DELETE FROM Languages"
		cmd.executeNonQuery()
		
		conn.close()
	}
	
	static func insertAll(_ languages: [Language]) {
		if languages.count == 0 {
			return
		}
		
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		//NOTE: use transaction to speed up mass insert operation; added it to mass insert called on top level
		let cmd = DbCommand(connection: conn)
		cmd.text = "BEGIN TRANSACTION"
		cmd.executeNonQuery()
		
		for lang in languages {
			_ = lang.insert(connection: conn)
		}
		
		let cmd1 = DbCommand(connection: conn)
		cmd1.text = "COMMIT TRANSACTION"
		cmd1.executeNonQuery()
		
		conn.close()
	}
	
	func insert(connection conn: DbConnection) -> Int {
		let cmd = DbCommand(connection: conn)
		
		cmd.text = "INSERT INTO Languages (Id, Name, Code, IsSelected) VALUES(:Id, :Name, :Code, :IsSelected)"
		cmd.parameters.append(DbParameter(name: ":Id", value: self.id))
		cmd.parameters.append(DbParameter(name: ":Name", value: self.name))
		cmd.parameters.append(DbParameter(name: ":Code", value: self.code))
		cmd.parameters.append(DbParameter(name: ":IsSelected", value: self.isSelected))
		cmd.executeNonQuery()
		
		return cmd.lastInsertedId()
	}
	
	func updateSelected() {
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = "UPDATE Languages SET IsSelected = :IsSelected WHERE Id = :Id"
		cmd.parameters.append(DbParameter(name: ":Id", value: self.id))
		cmd.parameters.append(DbParameter(name: ":IsSelected", value: self.isSelected))
		cmd.executeNonQuery()
		conn.close()
	}
	
	static func updateSelected(id: Int, selected: Bool) {
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = "UPDATE Languages SET IsSelected = :IsSelected WHERE Id = :Id"
		cmd.parameters.append(DbParameter(name: ":Id", value: id))
		cmd.parameters.append(DbParameter(name: ":IsSelected", value: selected))
		cmd.executeNonQuery()
		
		conn.close()
	}

	static func loadSelected() -> [Language] {
		var items = [Language]()
		
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		cmd.text = "SELECT Id, Name, Code, IsSelected FROM Languages WHERE IsSelected = 1"
		let reader = cmd.executeReader()
		while reader.read() {
			let id = reader.int(0)
			let name = reader.string(1)
			let code = reader.string(2)
			let isSelected = reader.bool(3)
			
			let object = Language(id: id, name: name, code: code, isSelected: isSelected)
			items.append(object)
		}
		
		reader.close()
		
		conn.close()
		
		return items
	}
}
