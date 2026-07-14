//
//  DownloadErrorMessage.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//


class DownloadErrorMessage: DownloadMessage {
	let bookId: Int
	let isSanskrit: Bool
	let chapterOrder: Int
	let shlokaOrder: Int
	let fileURL: String
	let filePath: String
	let error: RequestError

	required init(bookId: Int, isSanskrit: Bool, chapterOrder: Int, shlokaOrder: Int, fileURL: String, filePath: String, error: RequestError) {
		self.bookId = bookId
		self.isSanskrit = isSanskrit
		self.chapterOrder = chapterOrder
		self.shlokaOrder = shlokaOrder
		self.fileURL = fileURL
		self.filePath = filePath
		self.error = error
		super.init()
	}

	convenience override init() {
		self.init(bookId:Int(), isSanskrit: false, chapterOrder: -1, shlokaOrder: -1, fileURL: String(), filePath: String(), error: RequestError())
	}
	
	convenience init(bookId: Int, isSanskrit: Bool, error: RequestError) {
		self.init(bookId: bookId, isSanskrit: isSanskrit, chapterOrder: -1, shlokaOrder: -1, fileURL: String(), filePath: String(), error: error)
	}
	
	override class func messageFromNotification(_ notification: Notification) -> DownloadErrorMessage? {
		return super.messageFromNotification(notification) as? DownloadErrorMessage
	}
}

extension DownloadErrorMessage: CustomStringConvertible {
	var description: String {
		return [
			"BookId: \(bookId)",
			"isSanskrit: \(isSanskrit)",
			"ChapterOrder: \(chapterOrder)",
			"ShlokaOrder: \(shlokaOrder)",
			"FileURL: \(fileURL)",
			"FilePath: \(filePath)",
			"Error: \(error)"
			].joined(separator: ", ")
	}
}
