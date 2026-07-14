//
//  Vocabulary.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 16/05/2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//


class Vocabulary {
	//Does not come from server, but required
	var shlokaId: Int
	
	//Downloaded
	let text: String
	let translation: String

	init(shlokaId: Int, text: String, translation: String) {
		self.shlokaId = shlokaId
		self.text = text
		self.translation = translation
	}

	convenience init() {
		self.init(shlokaId:0, text:String(), translation:String())
	}

	convenience init(text: String, translation: String) {
		self.init(shlokaId:0, text:text, translation:translation)
	}
}

extension Vocabulary: CustomStringConvertible {
	var description: String {
		return [
			"Text: \(text)",
			"Translation: \(translation)"
			].joined(separator: ", ")
	}
}

extension Vocabulary {
	static func getFromDictionary(_ json: [String: Any]?) throws -> Vocabulary? {
		guard let json = json else { return nil }
		guard let text:String = json["text"] != nil ? json["text"] as? String : String() else {
			return nil
		}
		guard let translation:String = json["translation"] != nil ? json["translation"] as? String : String() else {
			return nil
		}
		return Vocabulary(text: text, translation: translation)
	}
	
	static func getFromDataArray(_ json: Any?) throws -> [Vocabulary]? {
		guard let array = json as? [Any] else {
			return nil
		}
		return array.flatMap{try! Vocabulary.getFromDictionary($0 as? [String : Any])}
	}
}

extension Vocabulary: Equatable {
    static func ==(lhs: Vocabulary, rhs: Vocabulary) -> Bool {
        return lhs.shlokaId == rhs.shlokaId && lhs.text == rhs.text && lhs.translation == rhs.translation
    }
}

