//
//  UIView+ActivityIndicator2.swift
//  Tomato
//
//  Created by Konstantin Oznobikhin on 13/05/16.
//  Copyright © 2016 IronWaterStudio. All rights reserved.
//

import UIKit

private var kActivityLock = 0
private var kActivityIndicatorView = 0
private var kActivityIndicatorViewCount = 0

public extension UIView {
	private var activityLock: NSObject {
		get {
			let obj = objc_getAssociatedObject(self, &kActivityLock) as? NSObject
			if let obj = obj {
				return obj
			}
			
			let lock = NSObject()
			objc_setAssociatedObject(self, &kActivityLock, lock, .OBJC_ASSOCIATION_RETAIN)
			
			return lock
		}
	}
	
	private var activityView: UIView? {
		get {
			return objc_getAssociatedObject(self, &kActivityIndicatorView) as? UIView
		}
		set {
			objc_setAssociatedObject(self, &kActivityIndicatorView, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	private var activityViewCount: Int {
		get {
			let value = objc_getAssociatedObject(self, &kActivityIndicatorViewCount) as? Int
			if let value = value {
				return value
			}
			
			return 0
		}
		set {
			objc_setAssociatedObject(self, &kActivityIndicatorViewCount, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}

    public func showActivityIndicator(color: UIColor) {
		self.showActivityIndicator(true, style: .gray, color: color, grayBackground: false, alpha: 0.0)
	}
	
	public func hideActivityIndicator() {
		objc_sync_enter(self.activityLock)
		defer {
			objc_sync_exit(self.activityLock)
		}
		
		var count = self.activityViewCount;
		if count > 0 {
			count -= 1
		}
		
		self.activityViewCount = count

		if count == 0 {
			self.activityView?.removeFromSuperview()
			self.activityView = nil
		}
	}
	
	public func showActivityIndicator(
		_ showActivity: Bool,
		style activityStyle: UIActivityIndicatorViewStyle,
		color: UIColor?,
		grayBackground: Bool,
		alpha backgroundAlpha: CGFloat) {
		
		objc_sync_enter(self.activityLock)
		defer {
			objc_sync_exit(self.activityLock)
		}
		
		let count = self.activityViewCount
		self.activityViewCount = count + 1
		if count > 0 {
			return
		}
		
		// ActivityView
		let size = self.frame.size
		let activityView = UIView(frame: self.bounds)
		activityView.autoresizingMask = UIViewAutoresizing().union(.flexibleWidth).union(.flexibleHeight)
		
		activityView.alpha = 1.0
		activityView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: backgroundAlpha)
		
		self.addSubview(activityView)
		if showActivity {
			// GrayView: small gray square besides activity
			if grayBackground {
				let sizeGrayView: CGFloat = 62.0
				
				let grayView = UIView(frame: CGRect(
					x: (size.width - sizeGrayView) / 2.0,
					y: (size.height - sizeGrayView) / 2.0,
					width: sizeGrayView,
					height: sizeGrayView))
				grayView.alpha = 0.35
				grayView.backgroundColor = UIColor.black
				grayView.layer.cornerRadius = 15.0
				grayView.layer.masksToBounds = true
				
				grayView.autoresizingMask = UIViewAutoresizing()
					.union(.flexibleTopMargin)
					.union(.flexibleBottomMargin)
					.union(.flexibleLeftMargin)
					.union(.flexibleRightMargin)
				
				activityView.addSubview(grayView)
			}
			
			// ActivityIndicatorView
			let activity = UIActivityIndicatorView(activityIndicatorStyle: activityStyle)
			activity.frame = CGRect(
				x: (size.width - activity.frame.size.width) / 2.0,
				y: (size.height - activity.frame.size.height) / 2.0,
				width: activity.frame.size.width,
				height: activity.frame.size.height)
			activity.autoresizingMask = UIViewAutoresizing()
				.union(.flexibleTopMargin)
				.union(.flexibleBottomMargin)
				.union(.flexibleLeftMargin)
				.union(.flexibleRightMargin)
			if let color = color {
				activity.color = color
			}
			
			activity.startAnimating()
			activityView.addSubview(activity)
		}
		
		// current ActivityView
		self.activityView = activityView;
	}

}
