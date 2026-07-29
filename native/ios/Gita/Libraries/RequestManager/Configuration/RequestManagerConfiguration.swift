//
//  RequestManagerConfiguration.swift
//  RequestManager
//
//  Created by Stanislav Grinberg on 28/04/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

private extension String {
	
	static let timeoutInterval = "requestTimeoutInterval"
	static let retriesCount = "requestRetriesCount"
	static let autoConnect = "autoConnect"
	static let repeatAlerts = "repeatAlerts"
	static let offlineModeSupport = "offlineModeSupport"
	static let autoStart = "autoStart"
	static let isSequential = "isSequential"
	static let queue = "queue"
	
}

final class RequestManagerConfiguration {
	
	private static let defaultSettings: [String: Any] = {
		return [
			.timeoutInterval: TimeInterval(240),
			.retriesCount: 3,
			.autoConnect: true,
			.repeatAlerts: true,
			.offlineModeSupport: false,
			.autoStart: true,
			.isSequential: false,
			.queue: DispatchQueue.main
		]
	}()
	
	/// Timeout interval in seconds (should be more or equals than 240, otherwise will be ignored)
	/// @warning Default value is @b 240.
	var timeoutInterval: TimeInterval {
		get {
			return settings[.timeoutInterval] as! TimeInterval
		}
		set {
			settings[.timeoutInterval] = newValue
		}
	}
	
 	/// Count of times that should request manager restarted while waiting solving server response error.
 	/// @warning Default value is @b 3.
	var retriesCount: Int {
		get {
			return settings[.retriesCount] as! Int
		}
		set {
			settings[.retriesCount] = newValue
		}
	}
	
 	/// This flag indicates that when network connection lost and when when it become alive, then request will be re-performed(RE-CONNECTed).
 	/// @warning This method is not the same as autoStart param for network connection. Default value is @b true.
	var autoConnect: Bool  {
		get {
			return settings[.autoConnect] as! Bool
		}
		set {
			settings[.autoConnect] = newValue
		}
	}
	
 	/// This flag indicates that alerts (e.g. network error alerts) should be showed repeatly or single time.
 	/// @warning This property should be used to manage repeating error alerts. Default value is @b true.
	var repeatAlerts: Bool {
		get {
			return settings[.repeatAlerts] as! Bool
		}
		set {
			settings[.repeatAlerts] = newValue
		}
	}

	/// This flag indicates that errorBlock should be call when isConnectionError occured to provide ability to show offline mode data.
 	/// But when connection will be restored then successBlock will be call.
 	/// @warning When this flag specified then can be both errorBlock and successBlock called sequently. Default value is @b NO.
	var offlineModeSupport: Bool {
	    get {
			return settings[.offlineModeSupport] as! Bool
		}
		set {
			settings[.offlineModeSupport] = newValue
		}
	}
	
 	/// This flag indicates that performing connection should start immediately
	var autoStart: Bool {
		get {
			return settings[.autoStart] as! Bool
		}
		set {
			settings[.autoStart] = newValue
		}
	}
	
 	/// This flag indicates that we use sequential data access, i.e. each next portion of NSData will not contains previous buffered array of NSData and success block will not be used to received final data or used to complete manual buffering; by default this value is NO and it means that in result success block we will received final buffered NSData
 	/// When is true  then we don't store received data in buffer and use direct transfer data to external storage (e.g. file or DB)
	var isSequential: Bool {
		get {
			return settings[.isSequential] as! Bool
		}
		set {
			settings[.isSequential] = newValue
		}
	}
	
	/// If that queue is specified success and error bloks will performed on it.
	/// - Note: To achieve this goal we should setup RequestManager.sharedConfiguration.queue and specify here DispatchQueue.global(), otherwise - will be used main queue (DispatchQueue.main). But all requests processing logic ALWAYS will be performed in RequestManager 'internal queue'!
	/// - Warning: When you not needed use depended queries and long time post processing (after processRecieveData) then you should not configure queue parameter.
	var queue: DispatchQueue? {
		get {
			return settings[.queue] as? DispatchQueue
		}
		set {
			settings[.queue] = newValue
		}
	}
	
	private var settings: [String: Any]
	
	// MARK: - Init methods
	
	init(settings: [String: Any]) {
		self.settings = RequestManagerConfiguration.defaultSettings.merging(settings, uniquingKeysWith: { (_, new) in new })
	}
	
	convenience init() {
		self.init(settings: [:])
	}
	
	convenience init(configuration: RequestManagerConfiguration) {
		self.init(settings: configuration.settings)
	}
	
	// MARK: - Experemental
	
	@discardableResult
	func timeoutInterval(_ val: TimeInterval) -> Self {
		settings[.timeoutInterval] = val
		return self
	}
	
	@discardableResult
	func retriesCount(_ val: Int) -> Self {
		settings[.retriesCount] = val
		return self
	}
	
	@discardableResult
	func autoConnect(_ val: Bool) -> Self {
		settings[.autoConnect] = val
		return self
	}
	
	@discardableResult
	func repeatAlerts(_ val: Bool) -> Self {
		settings[.repeatAlerts] = val
		return self
	}
	
	@discardableResult
	func offlineModeSupport(_ val: Bool) -> Self {
		settings[.offlineModeSupport] = val
		return self
	}
	
	@discardableResult
	func autoStart(_ val: Bool) -> Self {
		settings[.autoStart] = val
		return self
	}
	
	@discardableResult
	func isSequential(_ val: Bool) -> Self {
		settings[.isSequential] = val
		return self
	}
	
	@discardableResult
	func queue(_ val: DispatchQueue?) -> Self {
		settings[.queue] = val
		return self
	}
	
	@discardableResult
	func copy() -> RequestManagerConfiguration {
		return RequestManagerConfiguration(configuration: self)
	}
	
}
