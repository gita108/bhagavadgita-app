//
//  DBHelper.swift
//  DbLibrary
//
//  Created by Roman Developer on 7/20/17.
//  Updated by Olga Zhegulo on 24/05/2018.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

class DbHelper {
	
	static let kDatabaseName = "bhagavad-gita.sqlite"
	
	static func applicationDocumentsDirectory() -> String {
		return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
	}
	
	static func applicationCachesDirectory() -> String {
		return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
	}
	
	static func dbPath() -> String {
		return self.applicationDocumentsDirectory() + "/" + kDatabaseName
	}
	
	static func resourceDbPath() -> String {
		return Bundle.main.path(forResource: kDatabaseName, ofType: nil)!
	}
	
	static func initDb() {
		if !FileManager.default.fileExists(atPath: self.dbPath()) {
			do {
				try FileManager.default.copyItem(atPath: self.resourceDbPath(), toPath: self.dbPath())
				
				self.markNoBackup(atPath: self.dbPath())
				print("Initialized DB with name: \(kDatabaseName)")
			}
			catch let error {
				print("Copy error: \(error)")
			}
		} else {
			print("DB already there: \(self.dbPath())")
		}
	}
	
	@discardableResult
	static func setDoNotBackupAttribute(for filePath: String) -> Bool {
		var fileUrl = URL(fileURLWithPath: filePath)
		do {
			if FileManager.default.fileExists(atPath: fileUrl.path) {
				var resourceValues = URLResourceValues()
				resourceValues.isExcludedFromBackup = true
				try fileUrl.setResourceValues(resourceValues)
			}
			print("File \(fileUrl.lastPathComponent) was excluded from backup")
			return true
		} catch let error {
			print("Error excluding \(fileUrl.lastPathComponent) from backup: \(error)")
			return false
		}
	}
	
	static func markNoBackup(atPath filePath: String) {
		if var url = URL(string: filePath) {
			do {
				var resourceValues = URLResourceValues()
				resourceValues.isExcludedFromBackup = true
				try url.setResourceValues(resourceValues)
			} catch {
				print(error.localizedDescription)
			}
		}
	}
	
	static func dbVersion(atPath: String) -> Int {
		var version = 0
		let conn = DbConnection(dbPath: atPath)
		let comm = DbCommand(connection: conn, text: "PRAGMA user_version")
		
		conn.open()
		version = comm.executeInt()
		conn.close()
		
		return version
	}
	
	static func updateIfNeeded() -> Bool {
		let oldVersion = DbHelper.dbVersion(atPath: DbHelper.dbPath())
		let newVersion = DbHelper.dbVersion(atPath: DbHelper.resourceDbPath())
		
		if oldVersion < newVersion {
			print("Old version: \(oldVersion), new version: \(newVersion), attempting update")
			if FileManager.default.fileExists(atPath: DbHelper.dbPath()) {
				try! FileManager.default.removeItem(atPath: DbHelper.dbPath())
			}
			try! FileManager.default.copyItem(atPath: DbHelper.resourceDbPath(), toPath: DbHelper.dbPath())
			
			DbHelper.markNoBackup(atPath: DbHelper.dbPath())
			
			return true
		}
		else {
			print("Old version: \(oldVersion), new version: \(newVersion), update not needed")
			return false
		}
	}
}

