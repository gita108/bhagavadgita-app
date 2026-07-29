//
//  DownloadInfo.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//


class DownloadInfo: NSObject, NSCoding {

	static let kBookStateKey = "BookState"
	static let kBookDownloadsKey = "BookDownloads"
	
	let bookId: Int
	let isSanskrit: Bool
	var isDownloading: Bool
	var isDownloaded: Bool
	var isResumed: Bool = false
	var totalDownloads: Int
	var completedDownloads: Int
	//For resuming download
	var downloadItems = [DownloadItem]()
	
	var progress: Float {
		return completedDownloads > 0 ? Float(completedDownloads) / Float(totalDownloads) : 0.0
	}
	
	init(bookId: Int, isSanskrit: Bool, isDownloading: Bool, isDownloaded: Bool, isResumed: Bool, totalDownloads: Int, completedDownloads: Int, downloadItems: [DownloadItem]) {
		self.bookId = bookId
		self.isSanskrit = isSanskrit
		self.isDownloading = isDownloading
		self.isDownloaded = isDownloaded
		self.isResumed = isResumed
		self.totalDownloads = totalDownloads
		self.completedDownloads = completedDownloads
		self.downloadItems = downloadItems
	}
	
	convenience override init() {
		self.init(bookId:Int(), isSanskrit: false, isDownloading:false, isDownloaded:false, isResumed:false, totalDownloads:Int(), completedDownloads:Int(), downloadItems: [DownloadItem]())
	}
	
	override var description: String {
		return [
			"BookId: \(bookId)",
			"IsSanskrit: \(isSanskrit)",
			"IsDownloading: \(isDownloading)",
			"IsDownloaded: \(isDownloaded)",
			"TotalDownloads: \(totalDownloads)",
			"CompletedDownloads: \(completedDownloads)",
			"IsResumed : \(isResumed)",
			"DownloadItems : \(String(describing: downloadItems))"
			].joined(separator: ", ")
	}
	
	// MARK: - NSCoding
	required convenience init?(coder aDecoder: NSCoder) {
		let bookId = aDecoder.decodeInteger(forKey: "bookId")
		let isSanskrit = aDecoder.decodeBool(forKey: "isSanskrit")
		let isDownloading = aDecoder.decodeBool(forKey: "isDownloading")
		let isDownloaded = aDecoder.decodeBool(forKey: "isDownloaded")
		let isResumed = aDecoder.decodeBool(forKey: "isResumed")
		let totalDownloads = aDecoder.decodeInteger(forKey: "totalDownloads")
		let completedDownloads = aDecoder.decodeInteger(forKey: "completedDownloads")
		let downloadItems = aDecoder.decodeObject(forKey: "downloadItems") as? [DownloadItem]
		self.init(bookId:bookId, isSanskrit: isSanskrit, isDownloading:isDownloading, isDownloaded:isDownloaded, isResumed: isResumed, totalDownloads:totalDownloads, completedDownloads:completedDownloads, downloadItems: downloadItems ?? [DownloadItem]())
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.bookId, forKey:"bookId")
		aCoder.encode(self.isSanskrit, forKey:"isSanskrit")
		aCoder.encode(self.isDownloading, forKey:"isDownloading")
		aCoder.encode(self.isDownloaded, forKey:"isDownloaded")
		aCoder.encode(self.isResumed, forKey:"isResumed")
		aCoder.encode(self.totalDownloads, forKey:"totalDownloads")
		aCoder.encode(self.completedDownloads, forKey:"completedDownloads")
		aCoder.encode(self.downloadItems, forKey: "downloadItems")
	}
}

/*
extension DownloadInfo {
	
	private static func key(_ bookId: Int, isSanskrit: Bool) -> String {
		return "\(DownloadInfo.kBookStateKey)-\(bookId)-\(isSanskrit)"
	}
	
	static func getByID(bookId: Int, isSanskrit: Bool) -> DownloadInfo? {
		if let data = UserDefaults.standard.object(forKey: DownloadInfo.key(bookId, isSanskrit: isSanskrit)),
			let downloadInfo = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) {
			return downloadInfo as? DownloadInfo
		}
		
		return nil
	}
	
	func save() {
		let userDefaults = UserDefaults.standard
	
		//Book state
		let data = NSKeyedArchiver.archivedData(withRootObject: self)
		userDefaults.set(data, forKey: DownloadInfo.key(bookId, isSanskrit: self.isSanskrit))
		userDefaults.synchronize()
		
		DownloadInfo.storeBookDownload(bookId: bookId, isSanskrit: isSanskrit)
	}
	
	func clear() {
		let userDefaults = UserDefaults.standard
		
		//Book state
		userDefaults.removeObject(forKey: DownloadInfo.key(bookId, isSanskrit: self.isSanskrit))
		userDefaults.synchronize()
		
		DownloadInfo.removeBookId(bookId: bookId, isSanskrit: isSanskrit)
	}
	
	static func clear(bookId: Int, isSanskrit: Bool) {
		if let downloadInfo = DownloadInfo.getByID(bookId: bookId, isSanskrit: isSanskrit) {
			downloadInfo.clear()
			DownloadInfo.removeBookId(bookId: bookId, isSanskrit: isSanskrit)
		}
	}

	static func clearAll() {
		let userDefaults = UserDefaults.standard
		
		//Book state
		let bookDownloads = self.bookDownloads
		if bookDownloads.count > 0 {
			for bookDownload in bookDownloads {
				userDefaults.removeObject(forKey: DownloadInfo.key(bookDownload.bookId, isSanskrit: bookDownload.isSanskrit))
			}
			userDefaults.removeObject(forKey: DownloadInfo.kBookDownloadsKey)
		
			userDefaults.synchronize()
		}
	}
	
	//Helper property to have ability to remove all books
	static var bookDownloads: [BookDownload] {
		get {
			let data = UserDefaults.standard.object(forKey: DownloadInfo.kBookDownloadsKey) as? Data
			if let data = data {
				return (NSKeyedUnarchiver.unarchiveObject(with: data) as? [BookDownload]) ?? [BookDownload]()
			}
			else {
				return [BookDownload]()
			}
		}
	}
	
	//MARK: Helper
	
	private static func storeBookDownload(bookId: Int, isSanskrit: Bool) {
		let userDefaults = UserDefaults.standard
		
		var bookDownloads: [BookDownload] = self.bookDownloads
		
		if nil == bookDownloads.index(where: { $0.bookId == bookId && $0.isSanskrit == isSanskrit }) {
			bookDownloads.append(BookDownload(bookId: bookId, isSanskrit: isSanskrit))
			
			let data = NSKeyedArchiver.archivedData(withRootObject: bookDownloads)
			userDefaults.set(data, forKey: DownloadInfo.kBookDownloadsKey)			
			userDefaults.synchronize()
		}
	}

	private static func removeBookId(bookId: Int, isSanskrit: Bool) {
		let userDefaults = UserDefaults.standard
		
		var bookDownloads: [BookDownload] = self.bookDownloads
		
		if let index = bookDownloads.index(where: { $0.bookId == bookId && $0.isSanskrit == isSanskrit }) {
			bookDownloads.remove(at: index)
			
			let data = NSKeyedArchiver.archivedData(withRootObject: bookDownloads)
			userDefaults.set(data, forKey: DownloadInfo.kBookDownloadsKey)
			userDefaults.synchronize()
		}
	}

}
*/

final fileprivate class DownloadInfoStorage {
	private static let locker: Locker = Locker()
	private(set) static var downloads: [DownloadInfo] = []
	
	static func getByID(bookId: Int, isSanskrit: Bool) -> DownloadInfo? {
		if let data = downloads.first(where: { $0.bookId == bookId && $0.isSanskrit == isSanskrit }) {
			return data
		}
		return nil
	}
	
	static func save(_ downloadInfo: DownloadInfo) {
		locker.lock() {
			if let index = downloads.index(where: { (item) -> Bool in
				return item.bookId == downloadInfo.bookId && item.isSanskrit == downloadInfo.isSanskrit
			}) {
				//Copy data if not same data objects
				if self.downloads[index] !== downloadInfo {
					self.downloads[index].isDownloaded = downloadInfo.isDownloaded
					self.downloads[index].isDownloading = downloadInfo.isDownloading
					self.downloads[index].downloadItems = downloadInfo.downloadItems
					self.downloads[index].totalDownloads = downloadInfo.totalDownloads
				}
			}
			else {
				downloads.append(downloadInfo)
			}
		}
	}
	
	static func clear(_ downloadInfo: DownloadInfo) {
		locker.lock() {
			if let index = downloads.index(where: { (item) -> Bool in
				return item.bookId == downloadInfo.bookId && item.isSanskrit == downloadInfo.isSanskrit
			}) {
				downloads.remove(at: index)
			}
		}
	}
	
	static func clear(bookId: Int, isSanskrit: Bool) {
		if let downloadInfo = DownloadInfoStorage.getByID(bookId: bookId, isSanskrit: isSanskrit) {
			clear(downloadInfo)
		}
	}
	
	static func clearAll() {
		locker.lock() {
			self.downloads = []
		}
	}
}

//Global storage that niot persist on next run (will be changed if use NSURLSession background task)
extension DownloadInfo {
	static var downloads: [DownloadInfo] {
		return DownloadInfoStorage.downloads
	}

	static func getByID(bookId: Int, isSanskrit: Bool) -> DownloadInfo? {
		return DownloadInfoStorage.getByID(bookId: bookId, isSanskrit: isSanskrit)
	}
	
	static func save(_ downloadInfo: DownloadInfo) {
		DownloadInfoStorage.save(downloadInfo)
	}
	
	static func clear(_ downloadInfo: DownloadInfo) {
		DownloadInfoStorage.clear(downloadInfo)
	}
	
	static func clear(bookId: Int, isSanskrit: Bool) {
		if let downloadInfo = DownloadInfoStorage.getByID(bookId: bookId, isSanskrit: isSanskrit) {
			DownloadInfoStorage.clear(downloadInfo)
		}
	}
	
	static func clearAll() {
		DownloadInfoStorage.clearAll()
	}
}

