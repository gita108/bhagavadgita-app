//
//  GAHelper.swift
//  IronWaterStudio
//
//  Created by Olga Zhegulo on 07 Aug 2017.
//  Copyright 2017 IronWaterStudio. All rights reserved.
//
//  Dependencies:
//	GoogleAnalyticsServicesiOS_3.17

class GAHelper {
	
	static var dispatchInterval: TimeInterval {
		set {
			GAI.sharedInstance().dispatchInterval = newValue
		}
		
		get {
			return GAI.sharedInstance().dispatchInterval
		}
	}
	
	static var trackUncaughtExceptions: Bool {
		set {
			GAI.sharedInstance().trackUncaughtExceptions = newValue
		}
		
		get {
			return GAI.sharedInstance().trackUncaughtExceptions
		}
	}
	
	static func startTrackingWithId(_ trackingId: String) {
		
		GAI.sharedInstance().tracker(withTrackingId: trackingId)
	}
	
	static func logScreen(_ screenName: String) {
		let tracker = GAI.sharedInstance().defaultTracker
		tracker?.set(kGAIScreenName, value: screenName)
		tracker?.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject:AnyObject])
	}
	
	static func logEventWithCategory(_ category: String, action: String, details: String? = nil) {
		let tracker = GAI.sharedInstance().defaultTracker
		tracker?.send(GAIDictionaryBuilder.createEvent(
			withCategory: category,	// Event category (required)
			action: action,			// Event action (required)
			label: details,			// Event label
			value: NSNumber()		// Event value
			).build() as [NSObject:AnyObject])
	}
}
