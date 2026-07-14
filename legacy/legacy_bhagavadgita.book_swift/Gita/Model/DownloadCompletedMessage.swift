//
//  DownloadCompletedMessage.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//


class DownloadCompletedMessage: DownloadMessage {
	let bookId: Int
	let isSanskrit: Bool
	let chaptersCount: Int
	let completedDownloads: Int

	required init(bookId: Int, isSanskrit: Bool, chaptersCount: Int, completedDownloads: Int) {
		self.bookId = bookId
		self.isSanskrit = isSanskrit
		self.chaptersCount = chaptersCount
		self.completedDownloads = completedDownloads
		super.init()
	}

	convenience override init() {
		self.init(bookId:Int(), isSanskrit: false, chaptersCount:0, completedDownloads: 0)
	}
	
	override class func messageFromNotification(_ notification: Notification) -> DownloadCompletedMessage? {
		return super.messageFromNotification(notification) as? DownloadCompletedMessage
	}
}

extension DownloadCompletedMessage: CustomStringConvertible {
	var description: String {
		return [
			"BookId: \(bookId)",
			"isSanskrit: \(isSanskrit)",
			"ChaptersCount: \(chaptersCount)",
			"CompletedDownloads: \(completedDownloads)"
			].joined(separator: ", ")
	}
}
