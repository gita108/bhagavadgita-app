//
//  DownloadProgressMessage.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//


class DownloadProgressMessage: DownloadMessage {
	let bookId: Int
	let isSanskrit: Bool
	let totalDownloads: Int
	let completedDownloads: Int
	
	var progress: Float {
		return completedDownloads > 0 ? Float(completedDownloads) / Float(totalDownloads) : 0.0
	}
	
	required init(bookId: Int, isSanskrit: Bool, totalDownloads: Int, completedDownloads: Int) {
		self.bookId = bookId
		self.isSanskrit = isSanskrit
		self.totalDownloads = totalDownloads
		self.completedDownloads = completedDownloads
		super.init()
	}

	convenience override init() {
		self.init(bookId:Int(), isSanskrit: false, totalDownloads: 0, completedDownloads: 0)
	}
	
	override class func messageFromNotification(_ notification: Notification) -> DownloadProgressMessage? {
		return super.messageFromNotification(notification) as? DownloadProgressMessage
	}
}

extension DownloadProgressMessage: CustomStringConvertible {
	var description: String {
		return [
			"BookId: \(bookId)",
			"isSanskrit: \(isSanskrit)",
			"TotalDownloads: \(totalDownloads)",
			"CompletedDownloads: \(completedDownloads)"
			].joined(separator: ", ")
	}
}
