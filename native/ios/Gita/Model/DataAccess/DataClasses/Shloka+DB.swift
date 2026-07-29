//
//  Shloka+DB.swift
//  Gita
//
//  Created by Olga Zhegulo  on 18/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

extension Shloka {
	
	static func insertOrReplaceAll(connection conn: DbConnection, shlokas: [Shloka]) {
		if shlokas.count == 0 {
			return
		}
		
		for shloka in shlokas {
			_ = shloka.insertOrReplace(connection: conn)
		}
	}

	func insertOrReplace(connection conn: DbConnection) -> Int {
		let shlokaId = insertOrReplaceBase(connection: conn)
		if shlokaId > 0
		{
			for v in self.vocabularies {
				v.shlokaId = shlokaId
			}
			
			Vocabulary.insertAll(connection: conn, vocabularies: self.vocabularies)
			return shlokaId
		}
		return -1
	}
	
	func insertOrReplaceBase(connection conn: DbConnection) -> Int {
		let cmd = DbCommand(connection: conn)
		//NOTE: shloka Id will be assigned automatically
		cmd.text = "SELECT Id FROM Slokas WHERE ChapterId = :ChapterId AND \"Order\" = :Order"
		cmd.parameters.append(DbParameter(name: ":ChapterId", value: self.chapterId))
		cmd.parameters.append(DbParameter(name: ":Order", value: self.order))
		
		var isNew = true
		let reader = cmd.executeReader()
		while reader.read() {
			isNew = false
		}
		
		reader.close()
		
		let cmd1 = DbCommand(connection: conn)
		cmd1.text = isNew ?
			"INSERT INTO Slokas (ChapterId, Name, Text, Transcription, Translation, Comment, \"Order\", Audio, AudioFile, AudioSanskrit, AudioSanskritFile) VALUES(:ChapterId, :Name, :Text, :Transcription, :Translation, :Comment, :Order, :Audio, :AudioFile, :AudioSanskrit, :AudioSanskritFile)" :
		"UPDATE Slokas SET Name = :Name, Text = :Text, Transcription = :Transcription, Translation = :Translation, Comment = :Comment, Audio = :Audio, AudioFile = :AudioFile, AudioSanskrit = :AudioSanskrit, AudioSanskritFile = :AudioSanskritFile WHERE ChapterId = :ChapterId AND \"Order\" = :Order"
		
		cmd1.parameters.append(DbParameter(name: ":ChapterId", value: self.chapterId))
		cmd1.parameters.append(DbParameter(name: ":Order", value: self.order))
		cmd1.parameters.append(DbParameter(name: ":Name", value: self.name))
		cmd1.parameters.append(DbParameter(name: ":Text", value: self.text))
		cmd1.parameters.append(DbParameter(name: ":Transcription", value: self.transcription))
		cmd1.parameters.append(DbParameter(name: ":Translation", value: self.translation))
		cmd1.parameters.append(DbParameter(name: ":Comment", value: self.comment))
		cmd1.parameters.append(DbParameter(name: ":Audio", value: self.audio))
		cmd1.parameters.append(DbParameter(name: ":AudioFile", value: self.audioFile))
		cmd1.parameters.append(DbParameter(name: ":AudioSanskrit", value: self.audioSanskrit))
		cmd1.parameters.append(DbParameter(name: ":AudioSanskritFile", value: self.audioSanskritFile))

		cmd1.executeNonQuery()
		
		//Nothing inserted, just updated
		return isNew ? cmd1.lastInsertedId() : 0
	}

	static func updateAudioFile(bookId: Int, chapterOrder: Int, shlokaOrder: Int, audioFile: String) {
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		
		let cmd = DbCommand(connection: conn)
		cmd.text = "UPDATE Slokas SET AudioFile = :AudioFile WHERE ChapterId = (SELECT Id FROM Chapters c WHERE c.BookId = :BookId AND c.\"Order\" = :ChapterOrder ORDER BY ROWID ASC LIMIT 1) AND \"Order\" = :SlokaOrder"
		cmd.parameters.append(DbParameter(name: ":BookId", value: bookId))
		cmd.parameters.append(DbParameter(name: ":ChapterOrder", value: chapterOrder))
		cmd.parameters.append(DbParameter(name: ":SlokaOrder", value: shlokaOrder))
		cmd.parameters.append(DbParameter(name: ":AudioFile", value: audioFile))
		cmd.executeNonQuery()
		
		conn.close()
	}
	
	static func updateAudioSanskritFile(bookId: Int, chapterOrder: Int, shlokaOrder: Int, audioSanskritFile: String) {
		let conn = DbConnection(dbPath: DbHelper.dbPath())
		conn.open()
		
		let cmd = DbCommand(connection: conn)
		cmd.text = "UPDATE Slokas SET AudioSanskritFile = :AudioSanskritFile WHERE ChapterId = (SELECT Id FROM Chapters c WHERE c.BookId = :BookId AND c.\"Order\" = :ChapterOrder ORDER BY ROWID ASC LIMIT 1) AND \"Order\" = :SlokaOrder"
		cmd.parameters.append(DbParameter(name: ":BookId", value: bookId))
		cmd.parameters.append(DbParameter(name: ":ChapterOrder", value: chapterOrder))
		cmd.parameters.append(DbParameter(name: ":SlokaOrder", value: shlokaOrder))
		cmd.parameters.append(DbParameter(name: ":AudioSanskritFile", value: audioSanskritFile))
		cmd.executeNonQuery()
		
		conn.close()
	}
}
