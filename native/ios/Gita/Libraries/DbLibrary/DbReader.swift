//
//  DbReader.swift
//  DbLibrary
//
//  Created by Roman Developer on 7/24/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit
import SQLite3

class DbReader {
	var statement: OpaquePointer?
	
	required init(statement: OpaquePointer?) {
		self.statement = statement
	}
	
	deinit {
		if self.statement != nil {
			self.close()
		}
	}
	
	func close() {
		if sqlite3_finalize(self.statement) == SQLITE_OK {
			self.statement = nil
//			print("Statement closed")
		} else {
			let error = String(cString: sqlite3_errmsg(statement)!)
			print("Error finalizing statement: \(error)")
		}
	}
	
	func read() -> Bool {
		return (sqlite3_step(self.statement) == SQLITE_ROW)
	}
	
	func int(_ column: Int) -> Int {
		return Int(sqlite3_column_int64(self.statement, Int32(column)))
	}
	
	func bool(_ column: Int) -> Bool {
		return (self.int(column) == 1)
	}
	
	func double(_ column: Int) -> Double {
		return sqlite3_column_double(self.statement, Int32(column))
	}
	
	func string(_ column: Int) -> String {
		if let value = sqlite3_column_text(self.statement, Int32(column)) {
			return String(cString: UnsafePointer(value))
		} else {
			return ""
		}
	}
	
	func date(_ column: Int) -> Date {
		return Date(timeIntervalSince1970: self.double(column))
	}
	
	func uuid(_ column: Int) -> UUID {
		return UUID(uuidString: self.string(column))!
	}
	
	func blob(_ column: Int) -> Data {
		if let pointer = sqlite3_column_blob(self.statement, Int32(column)) {
			let length = Int(sqlite3_column_bytes(self.statement, Int32(column)))
			return Data(bytes: pointer, count: length)
		} else {
			// The return value from sqlite3_column_blob() for a zero-length BLOB is a NULL pointer.
			// https://www.sqlite.org/c3ref/column_blob.html
			return Data()
		}
	}
}
