//
//  Book.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 16/05/2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//


//
//  Book.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 16/05/2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//


class Book {
	let id: Int
	let languageId: Int
	var chaptersCount: Int
	let name: String
	let initials: String
	var isDownloaded: Bool = false
	var downloadInfo: DownloadInfo?
	
	init(id: Int, languageId: Int, name: String, initials: String, chaptersCount: Int, isDownloaded: Bool = false) {
		self.id = id
		self.languageId = languageId
		self.chaptersCount = chaptersCount
		self.name = name
		self.initials = initials
		self.isDownloaded = isDownloaded
	}
	
	convenience init() {
		self.init(id:Int(), languageId:Int(), name:String(), initials: String(), chaptersCount:Int(), isDownloaded: false)
	}	
}

extension Book: CustomStringConvertible {
	var description: String {
		return [
			"Id: \(id)",
			"LanguageId: \(languageId)",
			"ChaptersCount: \(chaptersCount)",
			"Name: \(name)",
			"Initials: \(initials)"
			].joined(separator: ", ")
	}
}

extension Book {
	static func getFromDictionary(_ json: [String: Any]?) throws -> Book? {
		guard let json = json else { return nil }
		guard let id:Int = json["id"] != nil ? json["id"] as? Int : Int() else {
			return nil
		}
		guard let languageId:Int = json["languageId"] != nil ? json["languageId"] as? Int : Int() else {
			return nil
		}
		guard let chaptersCount:Int = json["chaptersCount"] != nil ? json["chaptersCount"] as? Int : Int() else {
			return nil
		}
		guard let name:String = json["name"] != nil ? json["name"] as? String : String() else {
			return nil
		}
		guard let initials:String = json["initials"] != nil ? json["initials"] as? String : String() else {
			return nil
		}
		return Book(id: id, languageId: languageId, name: name, initials: initials, chaptersCount: chaptersCount)
	}
	
	static func getFromDataArray(_ json: Any?) throws -> [Book]? {
		guard let array = json as? [Any] else {
			return nil
		}
		return array.flatMap{try! Book.getFromDictionary($0 as? [String : Any])}
	}
}

extension Book {
	static func initialBook(_ books: [Book]) -> Book? {
		if books.count > 0 {
			let initialLanguageId = Language.initialLanguageId()
			if let initialBook = books.first(where: { $0.languageId == initialLanguageId }) {
				return initialBook
			} else {
				return books[0]
			}
		} else {
			return nil
		}
	}
	
	/*
	//Default book based on current language; not used now, because desfult book is now defined at application start
	static func defaultBookId() -> Int {
		let books = Book.loadAll()
		
		if books.count > 0 {
			let defaultLanguageId = Language.defaultLanguageId()
			if let defaultBookId = books.first(where: { $0.languageId == defaultLanguageId && $0.isDownloaded })?.id {
				return defaultBookId
			} else if let downloadedBookId = books.first(where: { $0.isDownloaded })?.id {
				return downloadedBookId
			} else {
				return -1
			}
		} else {
			return -1
		}
	}
*/
}
