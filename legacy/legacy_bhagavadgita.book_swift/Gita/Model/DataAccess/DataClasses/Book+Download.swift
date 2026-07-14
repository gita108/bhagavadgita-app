//
//  Book+Download.swift
//  Gita
//
//  Created by Olga Zhegulo  on 30/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

extension Book {
	//MARK: - Helper methods (paths)
	
	static func shlokaAudioRelativePath(bookId: Int, chapterId: Int, shlokaAudio: String, isSanskrit: Bool, replicateRemoteDirectory: Bool = false) -> String {
		let directory = "/Books/\(bookId)/\(isSanskrit ? "Sanskrit/" : "Translation/")Chapter\(chapterId)/"
		//To avoid extra directory level. Audio path is e.g. /Files/somefile.mp3
		let fileName = replicateRemoteDirectory ? shlokaAudio : (shlokaAudio as NSString).lastPathComponent
		return (directory as NSString).appendingPathComponent(fileName)
	}

	//NOTE:1. if replicate remote structure, use shlokaAudioRelativePath (... replicateRemoteDirectory: true)
	//NOTE:2. Ignores remote path when retrieve downloaded files DB: Files/audio.mp3 -> Documents/.../audio.mp3
	static func shlokaAudioFilePath(bookId: Int, chapterOrder: Int, shlokaAudio: String, isSanskrit: Bool) -> String {
		return DbHelper.applicationDocumentsDirectory() + self.shlokaAudioRelativePath(bookId: bookId, chapterId: chapterOrder, shlokaAudio: shlokaAudio, isSanskrit: isSanskrit)
	}

	static func bookFilesPath(_ bookId: Int) -> String {
		return (DbHelper.applicationDocumentsDirectory() as NSString).appendingPathComponent("Books/\(bookId)/")
	}
	
	static func bookFilesPath(_ bookId: Int, isSanskrit: Bool) -> String {
		return (DbHelper.applicationDocumentsDirectory() as NSString).appendingPathComponent("Books/\(bookId)/\(isSanskrit ? "Sanskrit/" : "Translation/")")
	}
	
	static func booksDirectoryPath() -> String {
		return (DbHelper.applicationDocumentsDirectory() as NSString).appendingPathComponent("Books/")
	}
	
	//MARK: - Audio
	//There are shlokas with audio file name specified and all files are stored locally
	static func audioDownloaded(_ bookId: Int, isSanskrit: Bool) -> Bool {
		return hasAudio(bookId, isSanskrit: isSanskrit) && audioFilesPresent(bookId, isSanskrit: isSanskrit)
	}
	
	//All audio files exists at proper paths
	static func audioFilesPresent(_ bookId: Int, isSanskrit: Bool) -> Bool {
		let chaptersFileNames = Book.audioPaths(Settings.shared.defaultBookId, isSanskrit: isSanskrit)
		for chapterData in chaptersFileNames {
			for fileName in chapterData.1 {
				let filePath = shlokaAudioFilePath(bookId: bookId, chapterOrder: chapterData.0, shlokaAudio: fileName, isSanskrit: isSanskrit)
				if !FileManager.default.fileExists(atPath: filePath) {
					return false
				}
			}
		}
		
		return true
	}

	//MARK: - Delete
	
	static func deleteAll() {
		if Book.deleteAllFromDB() {
			//Remove downloaded audio
			do {
				try FileManager.default.removeItem(atPath: Book.booksDirectoryPath())
			} catch {}
		}
	}

	//NOTE: just for consistency. Books with audio are never deleted, because only initial (permanent) book has audio
	static func deleteDownloadedBook(_ id: Int, removeAudio: Bool) {
		Book.deleteDownloadedBookFromDB(id)
		if removeAudio {
			Book.deleteAudio(bookId: id)
		}
	}
	
	static func deleteAudio(bookId id: Int) {
		do {
			try FileManager.default.removeItem(atPath: Book.bookFilesPath(id))
			for isSanskrit in [false, true] {
				DownloadInfo.clear(bookId: id, isSanskrit: isSanskrit)
			}
		} catch {}
	}
	
	static func deleteAudio(bookId id: Int, isSanskrit: Bool) {
		do {
			try FileManager.default.removeItem(atPath: Book.bookFilesPath(id, isSanskrit: isSanskrit))
			DownloadInfo.clear(bookId: id, isSanskrit: isSanskrit)
		} catch {}
	}

	//MARK: - Helper method
	private static func createDirectory(path: String) {
		var isDirectory: ObjCBool = false
		let fileExists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
		if !fileExists || !isDirectory.boolValue {
			do {
				try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
				DbHelper.markNoBackup(atPath: path)
			} catch {
				print(error)
			}
		}
	}
	
	//MARK: - Migrate audio from version 0
	static func migrateTranslationAudio(bookId: Int, isSanskrit: Bool) {
		let oldDirectory = DbHelper.applicationDocumentsDirectory() + "/Books/\(bookId)"
		let directory = DbHelper.applicationDocumentsDirectory() + "/Books/\(bookId)/\(isSanskrit ? "Sanskrit" : "Translation")/"

		if !FileManager.default.fileExists(atPath: directory) && FileManager.default.fileExists(atPath: oldDirectory) {
			do {
				//NOTE: not working
				//try FileManager.default.moveItem(atPath: oldDirectory, toPath: directory)
				let subdirectories = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath:oldDirectory), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants)
				try FileManager.default.createDirectory(at: URL(fileURLWithPath:directory), withIntermediateDirectories: false, attributes: nil)
				for oldSubdir in subdirectories {
//					print(directory + oldSubdir.lastPathComponent)
					if !oldSubdir.lastPathComponent.starts(with: ".") {
//						try FileManager.default.copyItem(at: oldSubdir, to: URL(fileURLWithPath:(directory + oldSubdir.lastPathComponent)))
						try FileManager.default.moveItem(at: oldSubdir, to: URL(fileURLWithPath:(directory + oldSubdir.lastPathComponent)))
					}
				}
			} catch let error {
				print(error)
			}
		}
	}
}
