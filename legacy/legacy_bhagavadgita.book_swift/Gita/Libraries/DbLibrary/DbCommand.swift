//
//  DbCommand.swift
//  DbLibrary
//
//  Created by Roman Developer on 7/24/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit
import SQLite3

class DbCommand {
	
	let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
	let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
	
	let connection: DbConnection
	var text: String
	var parameters: [DbParameter]
	
	convenience init(connection: DbConnection) {
		self.init(connection: connection, text: "")
	}
	
	required init(connection: DbConnection, text: String) {
		self.connection = connection
		self.text = text
		self.parameters = []
	}
	
	fileprivate func bindParameters(_ statement: OpaquePointer?) {
		for param in self.parameters {
			let parameterIndex = sqlite3_bind_parameter_index(statement, param.name.cString(using: .utf8))
			
			switch param.value {
				//				case == nil:
			//					sqlite3_bind_null(statement, parameterIndex)
			case let pBool as Bool:
				sqlite3_bind_int(statement, parameterIndex, (pBool ? 1 : 0))
			case let pInt as Int:
				sqlite3_bind_int(statement, parameterIndex, Int32(pInt))
			case let pDouble as Double:
				sqlite3_bind_double(statement, parameterIndex, pDouble)
			case let pDate as Date:
				sqlite3_bind_double(statement, parameterIndex, pDate.timeIntervalSince1970)
			case let pString as String:
				sqlite3_bind_text(statement, parameterIndex, pString.cString(using: .utf8), -1, SQLITE_TRANSIENT) //It was pString.cString(using: .utf8) here
			case let pUUID as UUID:
				sqlite3_bind_text(statement, parameterIndex, pUUID.uuidString.cString(using: .utf8), -1, SQLITE_TRANSIENT)
			case let pData as NSData:
				//Probably should be SQLITE_STATIC, because in case of -1 behavior is undefined https://www.sqlite.org/c3ref/bind_blob.html -
				sqlite3_bind_blob(statement, parameterIndex, pData.bytes, Int32(pData.length), SQLITE_TRANSIENT)
			default:
				print("Unexpected parameter value, binding failed")
			}
		}
	}
	
	func executeReader() -> DbReader {
		//Prepare statement
		var statement: OpaquePointer?
		let res = sqlite3_prepare_v2(self.connection.database, self.text.cString(using: .utf8), -1, &statement, nil)
		if (res != SQLITE_OK)
		{
			let error = String(cString: sqlite3_errmsg(self.connection.database)!)
			print("Error preparing statement: \(error)")
		}
		
		//Bind parameters
		self.bindParameters(statement)
		
		return DbReader(statement: statement)
	}
	
	func executeInt() -> Int {
		var result = 0
		
		let reader = self.executeReader()
		if reader.read() {
			result = reader.int(0)
		}
		reader.close()
		
		return result
	}
	
	func executeBool() -> Bool {
		var result = false
		
		let reader = self.executeReader()
		if reader.read() {
			result = reader.bool(0)
		}
		reader.close()
		
		return result
	}
	
	//	func executeScalar<T>() -> T {
	//		let reader = self.executeReader()
	//		var scalar: Int = 0
	//
	////		String(reflecting: T.self)
	//
	//		switch T.self {
	//		case let xx as Int:
	//			print("Int")
	//		default:
	//			print("Not Int")
	//		}
	//
	//		if reader.read() {
	//			scalar = reader.int(0)
	//		}
	//
	//		reader.close()
	//
	//		return T(scalar)
	//	}
	
	//Idea with pointers from https://github.com/groue/GRDB.swift/Core/Statement.swift
	func executeNonQuery() {
		
		let sqlCodeUnits = self.text.utf8CString
		sqlCodeUnits.withUnsafeBufferPointer { codeUnits in
			let sqlStart = UnsafePointer<Int8>(codeUnits.baseAddress)!
			let sqlEnd = sqlStart + sqlCodeUnits.count
			var statementStart = sqlStart
			
			while statementStart < sqlEnd - 1 {
				var statementEnd: UnsafePointer<Int8>? = nil
				do {
					var statement: OpaquePointer? = nil
					// Compile
					//NOTE: statementEnd does not point to /0 sometimes, so we cannot compare byte  to "/0" for statement end
					var res = sqlite3_prepare_v2(self.connection.database, statementStart, -1, &statement, &statementEnd)

					if (res != SQLITE_OK)
					{
						let error = String(cString: sqlite3_errmsg(self.connection.database)!)
						print("Error preparing statement: \(error)")
					}
					
					//Bind parameters
					self.bindParameters(statement)
					
					//Execute
					res = sqlite3_step(statement)
					if (res == SQLITE_OK || res == SQLITE_ROW || res == SQLITE_DONE) {
//						print("Executing nonquery successful")
					} else {
						let error = String(cString: sqlite3_errmsg(self.connection.database)!)
						print("Error executing nonquery: \(error)")
					}
					
					//Finalize statement
					if sqlite3_finalize(statement) == SQLITE_OK {
//						print("Statement closed")
					} else {
						let error = String(cString: sqlite3_errmsg(self.connection.database)!)
						print("Error finalizing statement: \(error)")
					}

					// Next
					statementStart = statementEnd!
				}
			}
		}

/*
		repeat {
			//Prepare statement
			//Because works incorrectly (does not encounter 0 as terminator)
			var res = sqlite3_prepare_v2(self.connection.database, commandText.cString(using: .utf8), -1, &statement, &tail)
			if String(cString: tail!).count > 0 {
				print("tail = '\(String(cString: tail!))'")
			}
			if (res != SQLITE_OK)
			{
				let error = String(cString: sqlite3_errmsg(self.connection.database)!)
				print("Error preparing statement: \(error)")
				print(commandText)
			}
			
			//Bind parameters
			self.bindParameters(statement)
			
			//Execute
			res = sqlite3_step(statement)
			if (res == SQLITE_OK || res == SQLITE_ROW || res == SQLITE_DONE) {
//				print("Executing nonquery successful")
			} else {
				let error = String(cString: sqlite3_errmsg(self.connection.database)!)
				print("Error executing nonquery: \(error)")
				print(commandText)
			}
			
			//Finalize statement
			if sqlite3_finalize(statement) == SQLITE_OK {
//				print("Statement closed")
			} else {
				let error = String(cString: sqlite3_errmsg(self.connection.database)!)
				print("Error finalizing statement: \(error)")
			}
			
			//Next command
			//let tailPointer = OpaquePointer(tail)
			if tail?.pointee ?? 0 != 0 && String(utf8String:tail!) != nil {
				print("tail is not nil:\(tail != nil) tail?.pointee \(tail?.pointee ?? 0)")
				print("String(cString: tail!) \(String(cString: tail!))")
				print(String(utf8String:tail!))
			}
			commandText = String()
//			commandText = Character(UnicodeScalar(tail?.pointee)) != "\0" ? String(cString: tail!) : String()
		} while commandText.count > 0
*/
	}
	
	func lastInsertedId() -> Int {
		return Int(sqlite3_last_insert_rowid(self.connection.database))
	}
}
