//
//  Dispatch.swift
//  LocationManager
//
//  Created by Stanislav Grinberg on 13/04/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

class Dispatch {
	
	private static var _onceTracker = [String]()
	
	/**
	Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
	only execute the code once even in the presence of multithreaded calls.
	
	- parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
	- parameter block: Block to execute once
	*/
	public class func once(token: String, closure: () -> ()) {
		objc_sync_enter(self); defer { objc_sync_exit(self) }
		
		if _onceTracker.contains(token) { return }
		
		_onceTracker.append(token)
		
		closure()
	}
	
	//http://stackoverflow.com/questions/38163604/about-synchronized-scope-in-swift
	public static func synchronized(_ lock: AnyObject, closure: () -> ()) -> () {
		objc_sync_enter(lock)
		defer {
			objc_sync_exit(lock)
		}
		closure()
	}
	
	/*
	//http://stackoverflow.com/questions/24045895/what-is-the-swift-equivalent-to-objective-cs-synchronized
	func synchronizedQueue(lock: AnyObject, @noescape closure: () -> ()) -> () {
	static let internalQueue = DispatchQueue(label: "async")
	static let semaphore = DispatchSemaphore(value: 1)
	
	internalQueue.async {
	semaphore.wait()
	
	// Critical section
	closure()
	
	self.semaphore.signal()
	}
	}
	*/
	
	//or use directly code
	/*
	do {
	objc_sync_enter(self)
	defer { objc_sync_exit(self) }
	
	// Do stuff
	}
	*/
	
}
