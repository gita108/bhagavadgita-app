//
//  Chapter.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 16/05/2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//


class Chapter {
	//Does not come from server, but required
	var id: Int
	var bookId: Int
	
	//Downloaded
	let name: String
	let order: Int
	let shlokas: [Shloka]
	
	init(id: Int, bookId: Int, name: String, order: Int, shlokas: [Shloka]) {
		self.id = id
		self.bookId = bookId
		self.name = name
		self.order = order
		self.shlokas = shlokas
	}

	convenience init(name: String, order: Int, shlokas: [Shloka]) {
		self.init(id:0, bookId:0, name:name, order:order, shlokas:shlokas)
	}

	convenience init() {
		self.init(id:0, bookId:0, name:String(), order:Int(), shlokas:[Shloka]())
	}

}

extension Chapter: CustomStringConvertible {
	var description: String {
		return [
			"Id: \(id)",
			"BookId: \(bookId)",
			"Name: \(name)",
			"Order: \(order)",
			"Shlokas: \(shlokas)"
			].joined(separator: ", ")
	}
}

extension Chapter {
	static func getFromDictionary(_ json: [String: Any]?) throws -> Chapter? {
		guard let json = json else { return nil }
		guard let name:String = json["name"] != nil ? json["name"] as? String : String() else {
			return nil
		}
		guard let order:Int = json["order"] != nil ? json["order"] as? Int : Int() else {
			return nil
		}
		guard let shlokas:[Shloka] = json["slokas"] != nil ? try! Shloka.getFromDataArray(json["slokas"]) : [Shloka]() else {
			return nil
		}
		return Chapter(name: name, order: order, shlokas: shlokas)
	}
	
	static func getFromDataArray(_ json: Any?) throws -> [Chapter]? {
		guard let array = json as? [Any] else {
			return nil
		}
		return array.flatMap{try! Chapter.getFromDictionary($0 as? [String : Any])}
	}
}
