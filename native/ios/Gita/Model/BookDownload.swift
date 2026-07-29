//
//  BookDownload.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 30/05/2018.
//  Copyright (c) 2018 Iron Water Studio. All rights reserved.
//


class BookDownload: NSObject, NSCoding {
	let bookId: Int
	let isSanskrit: Bool

	init(bookId: Int, isSanskrit: Bool) {
		self.bookId = bookId
		self.isSanskrit = isSanskrit
	}

	convenience override init() {
		self.init(bookId:Int(), isSanskrit:Bool())
	}

	override var description: String {
		return [
			"BookId: \(bookId)",
			"isSanskrit: \(isSanskrit)"
			].joined(separator: ", ")
	}

	// MARK: - NSCoding
	required convenience init?(coder aDecoder: NSCoder) {
		let bookId = aDecoder.decodeInteger(forKey: "bookId")
		let isSanskrit = aDecoder.decodeBool(forKey: "isSanskrit")
		self.init(bookId:bookId, isSanskrit:isSanskrit)
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.bookId, forKey:"bookId")
		aCoder.encode(self.isSanskrit, forKey:"isSanskrit")
	}
}
