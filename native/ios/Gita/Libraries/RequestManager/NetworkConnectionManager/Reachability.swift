//
//  Reachability.swift
//  RequestManager
//
//  Created by Stanislav Grinberg on 25/07/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation
import SystemConfiguration

enum NetworkStatus: Int {
	case notReachable = 0
	case reachableViaWiFi
	case reachableViaWWAN
}

let kReachabilityChangedNotification = Notification.Name("kNetworkReachabilityChangedNotification")

// MARK: - Supporting functions

let kShouldPrintReachabilityFlags = true

func PrintReachabilityFlags(flags: SCNetworkReachabilityFlags, comment: String) {
	if kShouldPrintReachabilityFlags {
		print("Reachability Flag Status: " +
			(flags.contains(.isWWAN) ? "W" : "-") +
			(flags.contains(.reachable) ? "R" : "-") +
			(flags.contains(.transientConnection) ? "t" : "-") +
			(flags.contains(.connectionRequired) ? "c" : "-") +
			(flags.contains(.connectionOnTraffic) ? "C" : "-") +
			(flags.contains(.interventionRequired) ? "i" : "-") +
			(flags.contains(.connectionOnDemand) ? "D" : "-") +
			(flags.contains(.isLocalAddress) ? "l" : "-") +
			(flags.contains(.isDirect) ? "d" : "-") +
			comment
		)
	}
}

func callback(target: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
	guard let info = info else { return }
	
	let noteObject = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
	
	NotificationCenter.default.post(name: kReachabilityChangedNotification, object: noteObject)
}

// MARK: - Reachability implementation

class Reachability: NSObject {
	
	var _alwaysReturnLocalWiFiStatus: Bool = false
	var _reachabilityRef: SCNetworkReachability?
	
	required public init(_ reachabilityRef: SCNetworkReachability) {
		_alwaysReturnLocalWiFiStatus = false
		_reachabilityRef = reachabilityRef
	}
	
	deinit {
		stopNotifier()
	}
	
	/// Use to check the reachability of a given host name.s
	static func reachabilityWithHostName(_ hostName: String) -> Self? {
		guard let ref = SCNetworkReachabilityCreateWithName(nil, hostName) else { return nil }
		
		return self.init(ref)
	}
	
	/// Use to check the reachability of a given IP address.
	static func reachabilityWithAddress(_ hostAddress: sockaddr_in) -> Self? {
		var address = sockaddr_in(sin_len: hostAddress.sin_len, sin_family: hostAddress.sin_family, sin_port: hostAddress.sin_port, sin_addr: hostAddress.sin_addr, sin_zero: hostAddress.sin_zero)

		guard let ref: SCNetworkReachability = withUnsafePointer(to: &address, {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
				SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
			}
		}) else { return nil }
		
		return self.init(ref)
	}
	
	/// Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
	static func reachabilityForInternetConnection() -> Self? {
		var zeroAddress = sockaddr_in()
		bzero(&zeroAddress, MemoryLayout<sockaddr_in>.size )
		zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
		zeroAddress.sin_family = sa_family_t(AF_INET)
		
		return reachabilityWithAddress(zeroAddress)
	}
	
	/// Checks whether a local WiFi connection is available.
	static func reachabilityForLocalWiFi() -> Self? {
		var localWifiAddress = sockaddr_in()
		bzero(&localWifiAddress, MemoryLayout<sockaddr_in>.size )
		localWifiAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
		localWifiAddress.sin_family = sa_family_t(AF_INET)
		
		// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0.
		localWifiAddress.sin_addr.s_addr =  CFSwapInt32HostToBig(IN_LINKLOCALNETNUM)
		
		if let reachability = reachabilityWithAddress(localWifiAddress) {
			reachability._alwaysReturnLocalWiFiStatus = true
			
			return reachability
		}
		
		return nil
	}
	
	/// Start listening for reachability notifications on the current run loop.
	@discardableResult
	func startNotifier() -> Bool {
		guard let reachabilityRef = _reachabilityRef else { return false }
		
		var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
		
		context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
		
		if SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
			if SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) {
				return true
			}
		}
		
		return false
	}

	func stopNotifier() {
		guard let reachabilityRef = _reachabilityRef else { return }
		
		SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
	}
	
	// MARK: - Network Flag Handling
	
	private func localWiFiStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> NetworkStatus {
		//printReachabilityFlags(flags, "localWiFiStatusForFlags")
		var returnValue: NetworkStatus = .notReachable
		
		if flags.contains(.reachable) && flags.contains(.isDirect) {
			returnValue = .reachableViaWiFi
		}
		
		return returnValue
	}
	
	private func networkStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> NetworkStatus {
		//printReachabilityFlags(flags, "networkStatusForFlags")
		if !flags.contains(.reachable) {
			// The target host is not reachable.
			return .notReachable
		}
		
		var returnValue: NetworkStatus = .notReachable
		
		if !flags.contains(.connectionRequired) {
			/*
			If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
			*/
			returnValue = .reachableViaWiFi;
		}
		
		if flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic) {
			/*
			... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
			*/
			
			if !flags.contains(.interventionRequired) {
				/*
				... and no [user] intervention is needed...
				*/
				
				returnValue = .reachableViaWiFi
			}
		}
		
		if !flags.intersection(.isWWAN).isEmpty {
			/*
				... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
			*/
			returnValue = .reachableViaWWAN
		}
		
		return returnValue
	}
	
	func currentReachabilityStatus() -> NetworkStatus {
		assert(_reachabilityRef != nil, "currentNetworkStatus called with NULL SCNetworkReachabilityRef")
		
		var returnValue: NetworkStatus = .notReachable
		
		var flags = SCNetworkReachabilityFlags()
		let gotFlags = withUnsafeMutablePointer(to: &flags) {
			SCNetworkReachabilityGetFlags(_reachabilityRef!, UnsafeMutablePointer($0))
		}
		
		if gotFlags {
			if _alwaysReturnLocalWiFiStatus {
				returnValue = localWiFiStatusForFlags(flags)
			} else {
				returnValue = networkStatusForFlags(flags)
			}
		}
		
		return returnValue
	}

	/// WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
	func connectionRequired() -> Bool {
		//guard let reachabilityRef = _reachabilityRef else { return false }
		assert(_reachabilityRef != nil, "connectionRequired called with NULL reachabilityRef")
		
		var flags = SCNetworkReachabilityFlags()
		
		let gotFlags = withUnsafeMutablePointer(to: &flags) {
			SCNetworkReachabilityGetFlags(_reachabilityRef!, UnsafeMutablePointer($0))
		}

		if gotFlags {
			return flags.contains(.connectionRequired)
		}
		
		return false
	}
	
}
