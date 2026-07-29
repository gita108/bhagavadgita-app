//
//  DownloadMessage.swift
//  Gita
//
//  Created by Olga Zhegulo  on 14/06/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

class DownloadMessage {
	static let kMessageDataKey = "data"
	
	open class var identifier: String {
		//NOTE: String(describing: type(of: self)) return parent type identifier, but code below gives child class identifier
		return (NSStringFromClass(self) as NSString).components(separatedBy: ".").last!
	}
	
	open class func messageFromNotification(_ notification: Notification) -> DownloadMessage? {
		let result = notification.userInfo?[kMessageDataKey] as? DownloadMessage
		return result
	}
	
	func notificationForObject(_ object: Any?) -> Notification {
		let result = Notification(name: Notification.Name(rawValue: type(of: self).identifier), object: object, userInfo: [DownloadMessage.kMessageDataKey : self])
		return result
	}
}
