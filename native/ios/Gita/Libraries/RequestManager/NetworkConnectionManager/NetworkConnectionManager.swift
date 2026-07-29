//
//  NetworkConnectionManager.swift
//  RequestManager
//
//  Created by Stanislav Grinberg on 25/07/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

@objc
protocol NetworkConnectionManagerDelegate: class {
	@objc optional func networkConnectionStateDidChanged(_ hasConnection: Bool)
}

let kNetworkConnectionManagerConnectionStateChanged = Notification.Name(rawValue: "kNetworkConnectionManagerConnectionStateChanged")

class NetworkConnectionManager: NSObject {
	
	static let shared = NetworkConnectionManager()
	
	var reachability: Reachability?
	
	weak var delegate: NetworkConnectionManagerDelegate?

	override init() {
		super.init()
		NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: kReachabilityChangedNotification, object: nil)
		reachability = Reachability.reachabilityForInternetConnection()
		
		if let reachability = reachability {
			reachability.startNotifier()
		}
		
		updateReachabilityStatus()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: kReachabilityChangedNotification, object: nil)
	}
	
	@objc
	private func reachabilityChanged(_ notification: Notification) {
		//print("reachability status changed")
		updateReachabilityStatus()
	}
	
	private func updateReachabilityStatus() {
		guard let reachability = reachability else { return }
		
		var hasInternet = false
		switch reachability.currentReachabilityStatus() {
		case .notReachable: hasInternet = false
		case .reachableViaWiFi: hasInternet = true
		case .reachableViaWWAN: hasInternet = true
		}
		
		let notification = Notification(name: kNetworkConnectionManagerConnectionStateChanged, object: self, userInfo: nil)
		NotificationCenter.default.post(notification)
		
		delegate?.networkConnectionStateDidChanged?(hasInternet)
	}
	
	func isInternetAvailable() -> Bool {
		if let status: NetworkStatus = reachability?.currentReachabilityStatus() {
			return status == .reachableViaWiFi || status == .reachableViaWWAN
		}
		
		return false
	}
	
	// Instance methods are for the cases when there's no 'shared' instance at the time of calling static methods
	
	func addSubscriber(_ subscriber: Any, selector: Selector) {
		NotificationCenter.default.addObserver(subscriber, selector: selector, name: kNetworkConnectionManagerConnectionStateChanged, object: nil)
	}
	
	func removeSubscriber(_ subscriber: Any) {
		NotificationCenter.default.removeObserver(subscriber, name: kNetworkConnectionManagerConnectionStateChanged, object: nil)
	}
	
	static func addSubscriber(_ subscriber: Any, selector: Selector) {
		shared.addSubscriber(subscriber, selector: selector)
	}
	
	static func removeSubscriber(_ subscriber: Any) {
		shared.removeSubscriber(subscriber)
	}
	
}
