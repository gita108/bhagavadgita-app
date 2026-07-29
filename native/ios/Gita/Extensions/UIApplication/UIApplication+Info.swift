//
//  UIApplication+Info.swift
//  Gita
//
//  Created by Olga Zhegulo  on 06/06/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

extension UIApplication {
	var localizedName: String {
		if let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
			return appName
		} else if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
			return appName
		} else if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
			return appName
		}
		return String()
	}
}
