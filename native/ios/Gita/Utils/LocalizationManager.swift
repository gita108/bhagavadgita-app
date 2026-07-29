//
//  LocalizationManager.swift
//  Gita
//
//  Created by Olga Zhegulo  on 30/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

final class LocalizationManager {
	private static let defaultLanguageCode = "en"
	
	static func currentLanguage() -> String {
		
//		//TODO: is app localization priority or selected language
//		var currLang: String? = Bundle.main.preferredLocalizations.first
//		
//		if String.isNilOrEmpty(currLang) {
//			currLang = Locale.current.languageCode
//		}
				
		//TODO: is app localization priority or selected language
		var currLang: String? = Locale.current.languageCode
		
		if String.isNilOrEmpty(currLang) {
			currLang = Bundle.main.preferredLocalizations.first
		}
		return currLang ?? defaultLanguageCode
	}
}
