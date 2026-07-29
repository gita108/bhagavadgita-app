//
//  DownloadItem.swift
//  Gita
//
//  Created by Olga Zhegulo  on 31/05/2018.
//  Copyright © 2018 Iron Water Studio. All rights reserved.
//

import UIKit

class DownloadItem : NSObject, NSCoding {
	//Complex identifier
	var chapterOrder: Int
	var shlokaOrder: Int
	var isSanskrit: Bool
	
	//Download data
	var fileUrl: String
	var filePath: String
	var isDownloading: Bool
	var isDownloaded: Bool
	
	init(chapterOrder: Int, shlokaOrder: Int, isSanskrit: Bool, fileUrl: String, filePath: String, isDownloading: Bool, isDownloaded: Bool) {
		self.chapterOrder = chapterOrder
		self.shlokaOrder = shlokaOrder
		self.isSanskrit = isSanskrit
		self.fileUrl = fileUrl
		self.filePath = filePath
		self.isDownloading = isDownloading
		self.isDownloaded = isDownloaded
	}
	
	convenience init(chapterOrder: Int, shlokaOrder: Int, isSanskrit: Bool, fileUrl: String, filePath: String) {
		self.init(chapterOrder: chapterOrder, shlokaOrder: shlokaOrder, isSanskrit: isSanskrit, fileUrl: fileUrl, filePath: filePath, isDownloading: false, isDownloaded: false)
	}
	
	override var description: String {
		return [
			"ChapterOrder: \(chapterOrder)",
			"ShlokaOrder: \(shlokaOrder)",
			"IsSanskrit: \(isSanskrit)",
			"FileUrl: \(fileUrl)",
			"FilePath: \(filePath)",
			"IsDownloading: \(isDownloading)",
			"IsDownloaded: \(isDownloaded)"
			].joined(separator: ", ")
	}
	
	// MARK: - NSCoding
	required convenience init?(coder aDecoder: NSCoder) {
		let chapterOrder = aDecoder.decodeInteger(forKey: "chapterOrder")
		let shlokaOrder = aDecoder.decodeInteger(forKey: "shlokaOrder")
		let isSanskrit = aDecoder.decodeBool(forKey: "isSanskrit")
		let fileUrl = (aDecoder.decodeObject(forKey: "fileUrl") as? String) ?? String()
		let filePath = (aDecoder.decodeObject(forKey: "filePath") as? String) ?? String()
		let isDownloading = aDecoder.decodeBool(forKey: "isDownloading")
		let isDownloaded = aDecoder.decodeBool(forKey: "isDownloaded")
		self.init(chapterOrder: chapterOrder, shlokaOrder: shlokaOrder, isSanskrit: isSanskrit, fileUrl:fileUrl, filePath: filePath, isDownloading:isDownloading, isDownloaded:isDownloaded)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.chapterOrder, forKey:"chapterOrder")
		aCoder.encode(self.shlokaOrder, forKey:"shlokaOrder")
		aCoder.encode(self.isSanskrit, forKey:"isSanskrit")
		aCoder.encode(self.fileUrl, forKey:"fileUrl")
		aCoder.encode(self.filePath, forKey:"filePath")
		aCoder.encode(self.isDownloading, forKey:"isDownloading")
		aCoder.encode(self.isDownloaded, forKey:"isDownloaded")
	}
}

