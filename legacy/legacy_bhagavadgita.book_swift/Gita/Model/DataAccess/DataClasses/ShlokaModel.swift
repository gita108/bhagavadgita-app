//
//  ShlokaModel.swift
//  Gita
//
//  Created by Class Generator by Olga Zhegulo on 2017.
//  Copyright (c) 2017 Iron Water Studio. All rights reserved.
//

struct TranslationModel {
	let lang: String
	let text: String
}

struct InterpretationModel {
	let code: String
	let title: String
	let text: String
}

class ShlokaModel {
	//Keys (for get from DB, for bookmarks)
	var chapterOrder: Int
	var shlokaOrder: Int
	//E.g. 1:32-34
	var name: String
	var title: String
	var originalText: String
	var transcription: String
	var dictionary: [Vocabulary]
	var translations: [TranslationModel]
	var interpretations: [InterpretationModel]
	var userComment: String
	//Audio
	var audio: String
	var audioSanskrit: String
	//Relative paths to downloaded files
	var audioFile: String
	var audioSanskritFile: String
	//Bookmark
	var isBookmarked: Bool

	init(chapterOrder: Int, shlokaOrder: Int, name: String, title: String, originalText: String, transcription: String, dictionary: [Vocabulary], translations: [TranslationModel], interpretations: [InterpretationModel], userComment: String, audio: String, audioFile: String, audioSanskrit: String, audioSanskritFile: String, isBookmarked: Bool) {
		self.chapterOrder = chapterOrder
		self.shlokaOrder = shlokaOrder
		self.name = name
		self.title = title
		self.originalText = originalText
		self.transcription = transcription
		self.dictionary = dictionary
		self.translations = translations
		self.interpretations = interpretations
		self.userComment = userComment
		self.audio = audio
		self.audioSanskrit = audioSanskrit
		self.audioFile = audioFile
		self.audioSanskritFile = audioSanskritFile
		self.isBookmarked = isBookmarked
	}

	convenience init() {
		self.init(chapterOrder: Int(), shlokaOrder: Int(), name: String(), title: String(), originalText: String(), transcription: String(), dictionary: [Vocabulary](), translations: [TranslationModel](), interpretations: [InterpretationModel](), userComment: String(), audio: String(), audioFile: String(), audioSanskrit: String(), audioSanskritFile: String(), isBookmarked: false)
	}

}

extension ShlokaModel: CustomStringConvertible {
	var description: String {
		return [
			"ChapterOrder: \(chapterOrder)",
			"ShlokaOrder: \(shlokaOrder)",
			"Name: \(name)",
			"Title: \(title)",
			"OriginalText: \(originalText)",
			"Transcription: \(transcription)",
			"Dictionary: \(dictionary)",
			"Translations: \(translations)",
			"Interpretations: \(interpretations)",
			"UserComment: \(userComment)",
			"Audio: \(audio)",
			"IsBookmarked: \(isBookmarked)"
		].joined(separator: ", ")
	}
}

extension ShlokaModel {
	static func get(chapterOrder: Int, shlokaOrder: Int, bookId: Int, languageIds: [Int]) -> ShlokaModel? {
		print("GET: default book \(bookId), chapter: \(chapterOrder), shloka: \(shlokaOrder), languageIds: \(languageIds)")
		
		let shlokaModel = ShlokaModel(chapterOrder: chapterOrder, shlokaOrder: shlokaOrder, name: String(), title: String(), originalText: String(), transcription: String(), dictionary: [Vocabulary](), translations: [TranslationModel](), interpretations: [InterpretationModel](), userComment: String(), audio: String(), audioFile: String(), audioSanskrit: String(), audioSanskritFile: String(), isBookmarked: false)
		//Id of shloka with given order from default book
		var defaultShlokaId = -1

		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		//Get shloka data from default book
		cmd.text = [
			"SELECT s.Name as Name, c.Name as Title, s.Text as OriginalText, s.Transcription, u.Text, s.audio, s.audioFile, s.audioSanskrit, s.audioSanskritFile, s.Id",
			"FROM Books b",
			"JOIN Chapters c ON b.Id = c.BookId",
			"JOIN Slokas s ON c.Id = s.ChapterId",
			"LEFT JOIN UserComments u ON c.\"Order\" = u.ChapterOrder AND s.\"Order\" = u.SlokaOrder",
			"WHERE b.Id = :BookId AND c.\"Order\" = :ChapterOrder AND s.\"Order\" = :SlokaOrder"]
			.joined(separator: "\n")
		cmd.parameters.append(DbParameter(name: ":BookId", value: bookId))
		cmd.parameters.append(DbParameter(name: ":ChapterOrder", value: chapterOrder))
		cmd.parameters.append(DbParameter(name: ":SlokaOrder", value: shlokaOrder))
		
		var reader = cmd.executeReader()
		while reader.read() {
			shlokaModel.name = reader.string(0)
			shlokaModel.title = reader.string(1)
			shlokaModel.originalText = reader.string(2)
			shlokaModel.transcription = reader.string(3)
			shlokaModel.userComment = reader.string(4)
			shlokaModel.audio = reader.string(5)
			shlokaModel.audioFile = reader.string(6)
			shlokaModel.audioSanskrit = reader.string(7)
			shlokaModel.audioSanskritFile = reader.string(8)
			
			defaultShlokaId = reader.int(9)
		}
		
		reader.close()
		
		if defaultShlokaId <= 0 {
			return nil
		}
		
//		cmd.parameters.removeAll()
		
		//Get vocabularies from default book
		let cmd1 = DbCommand(connection: conn)
		cmd1.text = "SELECT Text, Translation FROM Vocabularies WHERE SlokaId = :SlokaId"
		cmd1.parameters.append(DbParameter(name: ":SlokaId", value: defaultShlokaId))
		
		reader = cmd1.executeReader()
		while reader.read() {
			let text = reader.string(0)
			let translation = reader.string(1)
			shlokaModel.dictionary.append(Vocabulary(text: text, translation: translation))
		}
		
		reader.close()
		
//		cmd.parameters.removeAll()
		let cmd2 = DbCommand(connection: conn)
		//Get bookmarked flag
		cmd2.text = ["SELECT (CASE WHEN b.ChapterOrder IS NOT NULL THEN 1 ELSE 0 END) AS Bookmarked",
					"FROM Bookmarks b",
					"JOIN Chapters c ON b.ChapterOrder = c.\"Order\"",
					"JOIN Slokas s ON c.Id = s.ChapterId AND b.SlokaOrder = s.\"Order\"",
					"WHERE b.IsDeleted = 0 AND c.\"Order\" = :ChapterOrder AND s.\"Order\" = :SlokaOrder"]
			.joined(separator: "\n")
		cmd2.parameters.append(DbParameter(name: ":ChapterOrder", value: chapterOrder))
		cmd2.parameters.append(DbParameter(name: ":SlokaOrder", value: shlokaOrder))
		
		reader = cmd2.executeReader()
		while reader.read() {
			shlokaModel.isBookmarked = true
		}
		
		reader.close()
		
//		cmd.parameters.removeAll()
		let cmd3 = DbCommand(connection: conn)
		
		//Get data from all books
		for i in 0..<languageIds.count {
			cmd3.parameters.append(DbParameter(name: ":LanguageId\(i)", value: languageIds[i]))
		}
		
		var paramNames = [String]()
		for param in cmd3.parameters {
			paramNames.append(param.name)
		}
		let paramList = paramNames.joined(separator: ", ")
		
		cmd3.text = ["SELECT b.Name as DefaultBookTitle, b.Initials, l.Code as LangCode, s.Translation, s.Comment",
					"FROM Books b",
					"JOIN Languages l ON b.LanguageId = l.Id",
					"JOIN Chapters c ON b.Id = c.BookId",
					"JOIN Slokas s ON c.Id = s.ChapterId",
					"WHERE (b.Id = :BookId OR b.LanguageId IN (\(paramList))) AND c.\"Order\" = :ChapterOrder AND s.\"Order\" = :SlokaOrder"]
			.joined(separator: "\n")
		cmd3.parameters.append(DbParameter(name: ":BookId", value: bookId))
		cmd3.parameters.append(DbParameter(name: ":ChapterOrder", value: chapterOrder))
		cmd3.parameters.append(DbParameter(name: ":SlokaOrder", value: shlokaOrder))
		
		reader = cmd3.executeReader()
		while reader.read() {
			let bookTitle = reader.string(0)
			var initials = reader.string(1)
			if String.isNilOrWhiteSpace(initials) {
				initials = bookTitle.substring(to: bookTitle.index(bookTitle.startIndex, offsetBy: 2)).capitalized
			}
			let langCode = reader.string(2)
			let translation = reader.string(3)
			let comment = reader.string(4)
			
			shlokaModel.translations.append(TranslationModel(lang: langCode, text: translation))
			
			if !String.isNilOrWhiteSpace(comment) {
				shlokaModel.interpretations.append(InterpretationModel(code: initials, title: bookTitle, text: comment))
			}
		}
		
		reader.close()
		
		conn.close()
		
		return shlokaModel
	}
	
	static func search(query: String, bookId: Int) -> [ShlokaModel] {
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		let cmd = DbCommand(connection: conn)
		//Get shloka data from default book
		
		//NOTE: Exclude .Text from search because it is in Sankrit
		cmd.text = [
			"SELECT c.\"Order\", s.\"Order\", s.Name as Name, c.Name as Title",
			"FROM Books b",
			"JOIN Chapters c ON b.Id = c.BookId",
			"JOIN Slokas s ON c.Id = s.ChapterId",
			//Correct, but requires perfect custom like function
//			"WHERE b.Id = :BookId AND (c.Name LIKE '%:Query%' OR s.Translation LIKE '%:Query%' OR s.Comment LIKE '%:Query%')"
			//Variant composed for simplest custom LIKE implementation
			"WHERE b.Id = :BookId AND (c.Name LIKE '\(query)' OR s.Text LIKE '\(query)' OR s.Translation LIKE '\(query)' OR s.Transcription LIKE '\(query)' OR s.Comment LIKE '\(query)')"
			]
			.joined(separator: "\n")
		cmd.parameters.append(DbParameter(name: ":BookId", value: bookId))
//		cmd.parameters.append(DbParameter(name: ":Query", value: query))
	
		var result = [ShlokaModel]()
		let reader = cmd.executeReader()
		while reader.read() {
			let shlokaModel = ShlokaModel()
			shlokaModel.chapterOrder = reader.int(0)
			shlokaModel.shlokaOrder = reader.int(1)
			shlokaModel.name = reader.string(2)
			shlokaModel.title = reader.string(3)
			
			result.append(shlokaModel)
		}
		
		reader.close()
		conn.close()
		
		return result
	}
}

extension ShlokaModel {
	func hasDownloadedAudio(isSanskrit: Bool) -> Bool {
		return !String.isNilOrEmpty(isSanskrit ? self.audioSanskritFile : self.audioFile)
	}
	
	func audioPath(isSanskrit: Bool) -> String {
		return self.hasDownloadedAudio(isSanskrit: isSanskrit) ?
			DbHelper.applicationDocumentsDirectory() + (isSanskrit ? self.audioSanskritFile : self.audioFile) :
			String()
	}
}
