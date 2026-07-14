//
//  Quote.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 2018.
//  Copyright (c) 2018 Iron Water Studio. All rights reserved.
//


struct Quote {
	let author: String
	let text: String

	init(author: String, text: String) {
		self.author = author
		self.text = text
	}

	init() {
		self.init(author:String(), text:String())
	}

}

extension Quote: CustomStringConvertible {
	var description: String {
		return [
			"Author: \(author)",
			"Text: \(text)"
			].joined(separator: ", ")
	}
}

extension Quote {
	static func getFromDictionary(_ json: [String: Any]?) throws -> Quote? {
		guard let json = json else { return nil }
		guard let author:String = json["author"] != nil ? json["author"] as? String : String() else {
			return nil
		}
		guard let text:String = json["text"] != nil ? json["text"] as? String : String() else {
			return nil
		}
		return Quote(author: author, text: text)
	}

	static func getFromDataArray(_ json: Any?) throws -> [Quote]? {
		guard let array = json as? [Any] else {
			return nil
		}
		return array.flatMap{try! Quote.getFromDictionary($0 as? [String : Any])}
	}
}