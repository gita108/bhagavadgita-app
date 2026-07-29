//
//  Language.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 16/05/2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//


class Language {
	let id: Int
	let name: String
	let code: String
	//Custom field; device language is selected by default
	var isSelected: Bool
	
	init(id: Int, name: String, code: String, isSelected: Bool) {
		self.id = id
		self.name = name
		self.code = code
		self.isSelected = isSelected
	}

	convenience init() {
		self.init(id:Int(), name:String(), code:String())
	}

	convenience init(id: Int, name: String, code: String) {
		self.init(id:id, name:name, code:code, isSelected: false)
	}
}

extension Language: CustomStringConvertible {
	var description: String {
		return [
			"Id: \(id)",
			"Name: \(name)",
			"Code: \(code)"
			].joined(separator: ", ")
	}
}

extension Language {
	static func getFromDictionary(_ json: [String: Any]?) throws -> Language? {
		guard let json = json else { return nil }
		guard let id:Int = json["id"] != nil ? json["id"] as? Int : Int() else {
			return nil
		}
		guard let name:String = json["name"] != nil ? json["name"] as? String : String() else {
			return nil
		}
		guard let code:String = json["code"] != nil ? json["code"] as? String : String() else {
			return nil
		}
		return Language(id: id, name: name, code: code)
	}

	static func getFromDataArray(_ json: Any?) throws -> [Language]? {
		guard let array = json as? [Any] else {
			return nil
		}
		return array.flatMap{try! Language.getFromDictionary($0 as? [String : Any])}
	}
}

extension Language {
	static func initialLanguageId() -> Int? {
		let languages = Language.loadAll()
		
		if languages.count > 0 {
			let currentLanguage: String = LocalizationManager.currentLanguage()
			
			if let langIndex = languages.index(where: { $0.code.lowercased() == currentLanguage } ) {
				return languages[langIndex].id
			} else {
				return nil
			}
		} else {
			return nil
		}
	}	
}
