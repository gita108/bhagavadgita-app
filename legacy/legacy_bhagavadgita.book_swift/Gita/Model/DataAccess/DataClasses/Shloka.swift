//
//  Shloka.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 16/05/2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//


class Shloka {
	//Does not come from server, but required
	var id:Int
	var chapterId:Int

	//Downloaded
	let name: String
	let text: String
	let transcription: String
	let translation: String
	var comment: String
	
	let order: Int
	let audio: String
	let audioSanskrit: String
	let vocabularies: [Vocabulary]
	//Foreign key
	var chapter: Chapter? = nil
	
	//Custom fields
	var isBookmark: Bool = false
	//Relative paths to downloaded files
	var audioFile = String()
	var audioSanskritFile = String()

	init(id: Int, chapterId:Int, name: String, text: String, transcription: String, translation: String, comment: String, order: Int, audio: String, audioFile: String, audioSanskrit: String, audioSanskritFile: String, vocabularies: [Vocabulary], isBookmark: Bool) {
		self.id = id
		self.chapterId = chapterId
		self.name = name
		self.text = text
		self.translation = translation
		self.transcription = transcription
		self.comment = comment
		self.order = order
		self.audio = audio
		self.audioFile = audioFile
		self.audioSanskrit = audioSanskrit
		self.audioSanskritFile = audioSanskritFile
		self.vocabularies = vocabularies
		self.isBookmark = isBookmark
	}

	convenience init() {
		self.init(id:0, chapterId:0, name:String(), text:String(), transcription:String(), translation:String(), comment:String(), order:Int(), audio: String(), audioFile: String(), audioSanskrit: String(), audioSanskritFile: String(), vocabularies:[Vocabulary](), isBookmark: false)
	}

	//For server method
	convenience init(name: String, text: String, transcription: String, translation: String, comment: String, order: Int, audio: String, audioSanskrit: String, vocabularies: [Vocabulary]) {
		self.init(id:0, chapterId:0, name:name, text:text, transcription:transcription, translation:translation, comment:comment, order:order, audio:audio, audioFile: String(), audioSanskrit: audioSanskrit, audioSanskritFile: String(), vocabularies:vocabularies, isBookmark: false)
	}
}

extension Shloka: CustomStringConvertible {
	var description: String {
		return [
			"Id: \(id)",
			"ChapterId: \(chapterId)",
			"Name: \(name)",
			"Text: \(text)",
			"Transcription: \(transcription)",
			"Translation: \(translation)",
			"Comment: \(comment)",
			"Order: \(order)",
			"Audio: \(audio)",
			"AudioFile: \(audioFile)",
			"AudioSanskrit: \(audioSanskrit)",
			"AudioSanskritFile: \(audioSanskritFile)",
			"Vocabularies: \(vocabularies)",
			"IsBookmark: \(isBookmark)",
			"Chapter: \(chapter != nil ? String(chapter!.order) : "nil"). \(chapter?.name ?? String())"
			].joined(separator: ", ")
	}
}

extension Shloka {
	static func getFromDictionary(_ json: [String: Any]?) throws -> Shloka? {
		guard let json = json else { return nil }
		guard let name:String = json["name"] != nil ? json["name"] as? String : String() else {
			return nil
		}
		guard let text:String = json["text"] != nil ? json["text"] as? String : String() else {
			return nil
		}
		guard let transcription:String = json["transcription"] != nil ? json["transcription"] as? String : String() else {
			return nil
		}
		guard let translation:String = json["translation"] != nil ? json["translation"] as? String : String() else {
			return nil
		}
		guard let comment:String = json["comment"] != nil ? json["comment"] as? String : String() else {
			return nil
		}
		guard let order:Int = json["order"] != nil ? json["order"] as? Int : Int() else {
			return nil
		}
		guard let audio:String = json["audio"] != nil ? json["audio"] as? String : String() else {
			return nil
		}
		guard let audioSanskrit:String = json["audioSanskrit"] != nil ? json["audioSanskrit"] as? String : String() else {
			return nil
		}
		guard let vocabularies:[Vocabulary] = json["vocabularies"] != nil ? try! Vocabulary.getFromDataArray(json["vocabularies"]) : [Vocabulary] () else {
			return nil
		}
		return Shloka(name: name, text: text, transcription: transcription, translation: translation, comment: comment, order: order, audio: audio, audioSanskrit: audioSanskrit, vocabularies: vocabularies)
	}
	
	static func getFromDataArray(_ json: Any?) throws -> [Shloka]? {
		guard let array = json as? [Any] else {
			return nil
		}
		return array.flatMap{try! Shloka.getFromDictionary($0 as? [String : Any])}
	}
}

//TODO: probably not needed
extension Shloka {
	func hasAudio(shloka isSanskrit: Bool) -> Bool {
		return !String.isNilOrEmpty(isSanskrit ? self.audioSanskrit : self.audio)
	}
}
