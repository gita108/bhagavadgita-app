//
//  DownloadManager.swift
//  Gita
//
//  Created by Olga Zhegulo  on 29/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

final class DownloadManager {
	
	typealias RequestErrorBlock = (RequestError) -> Void

	static let shared = DownloadManager()
	
	
	//MARK: - Download initial book
	
	//Helper values to display progress with timer
	private var timer: Timer? = nil
	private var progressValue: Float = 0
	private var progressBlock: ((Float) -> ())?
	
	func downloadInitialData(success: @escaping () -> Void,
	                                progress: @escaping (Float) -> (),
	                                error: @escaping RequestErrorBlock) {
		
		//Remove incomplete data: case when user did not wait to download a book or stopped application on alert for audio
		Language.deleteAll()
		
		let languages = Language.loadAll()
		if languages.count == 0 {
			GitaRequestManager.getLanguages(success: { (languages : [Language]) in
				Language.insertAll(languages)
				
				let currentLanguage = LocalizationManager.currentLanguage()
				if let defaultLanguage = languages.first(where: { $0.code.lowercased() == currentLanguage }) {
					defaultLanguage.isSelected = true
					defaultLanguage.updateSelected()
				}

				let isSanskrit = false
				GitaRequestManager.getBooks(success: { (books) in
					if let defaultBook = Book.initialBook(books) {
						//Store default book at first call
						Settings.shared.defaultBookId = defaultBook.id
						
						DownloadManager.shared.downloadBook(book: defaultBook,
															isSanskrit: isSanskrit,
															success: { (chapters: [Chapter], hasAudio: Bool) in
																if hasAudio {
																	DispatchQueue.main.async {
																		AlertManager.present(message: Local("Download.ConfirmAudio"), buttons: [Local("Download.No"), Local("Download.Yes")], dismissBlock: { (buttonIndex) in
																			
																			if buttonIndex == 1 {
																				//Start downloading audio async
																				DownloadManager.shared.downloadAudio(book: defaultBook, chapters: chapters, isSanskrit: isSanskrit, success: {
																					//NOTE: screens will be notified when download complete
																					
																					//Set setting to allow using audio
																					if isSanskrit {
																						Settings.shared.useSanskritAudio = true
																					} else {
																						Settings.shared.useTranslationAudio = true
																					}
																				}, progress: { (progress) in
																					//Do nothing; progress will be displayed at Settings screen
																				}, error: { (err: RequestError) in
																					print(err)
																					
																					//Do not allow to use audio if did not downloaded it
																					if isSanskrit {
																						Settings.shared.useSanskritAudio = false
																					} else {
																						Settings.shared.useTranslationAudio = false
																					}
																				})
																				
																				//open app
																				success()
																			} else {
																				//Do not allow to use audio if did not downloaded it
																				if isSanskrit {
																					Settings.shared.useSanskritAudio = false
																				} else {
																					Settings.shared.useTranslationAudio = false
																				}
																				success()
																			}
																		})
																	}
																} else {
																	//Do not allow to use audio if default book has no audio
																	if isSanskrit {
																		Settings.shared.useSanskritAudio = false
																	} else {
																		Settings.shared.useTranslationAudio = false
																	}
																	
																	DispatchQueue.main.async {
																		success()
																	}
																}
						}, progress: {(progressValue) in
							progress(progressValue)
						},
						   error: { (err: RequestError) in
							print(err)
							
							//Remove incomplete data
							Language.deleteAll()
							
							error(err)
						})
					}
				}, error: { (err: RequestError) in
					print(err)
					
					//Remove incomplete data
					Language.deleteAll()
					
					error(err)
				})
				
			}, error: { (err: RequestError) in
				print(err)
				
//				GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownloadError, action: "Failed Data/Languages request", details: err.description)

				error(err)
			})
		} else {
			success()
		}
	}
	
	//MARK: - Download book
	func downloadBook(book: Book,
					  isSanskrit: Bool,
					  //NOTE: optional is @escaping
		success:  (([Chapter], Bool) -> ())?,
		progress: ((Float) -> ())?,
		error: RequestErrorBlock?) {
		
		let bookId = book.id
		self.progressBlock = progress
		
		print("Downloading book \(bookId)")
		
		//Reset previous download, if was not completed
		DownloadInfo.clear(bookId: bookId, isSanskrit: isSanskrit)
		
		GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownload, action: "Begin downloading book \(book.id) : \(Date().fullDateString())")
		
		//Set some progress before chapters are downloaded (for user comfort)
		self.progressValue = 0.1
		DispatchQueue.main.async {
			progress?(self.progressValue)
		}

		//Grow progress until book inserted
		self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.timer_tick), userInfo: nil, repeats: true)

		GitaRequestManager.getChapters(bookId: bookId, success: { (chapters: [Chapter]) in
			GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownload, action: "Downloaded book \(book.id) : \(Date().fullDateString())")
			
			print("got from server")
			
			var audioCount = 0
			
			for chapter in chapters {
				for shloka in chapter.shlokas {
					if !String.isNilOrWhiteSpace(isSanskrit ? shloka.audioSanskrit : shloka.audio) {
						audioCount += 1
					}
				}
			}
			
//			self.progressValue = 0.3
//			DispatchQueue.main.async {
//				progress?(self.progressValue)
//			}

			//Save book to DB
			_ = book.insertOrReplace()
			
			//Insert chapters
			Chapter.insertOrReplaceAll(chapters)
			
			print("chapters inserted at: \(self.progressValue)")
			
			//Inform for completion:
			DispatchQueue.main.async {
				progress?(1.0)
				self.timer?.invalidate()
				self.timer = nil
				self.progressBlock = nil
				print("progress set manually to 1.0")
			}

			//Call block
			_ = success?(chapters, audioCount > 0)
			
		}, error: { (err: RequestError) in
			print(err)
			
			//Inform for error:
			//Call block
			error?(err)
		})
	}
	
	@objc func timer_tick(_ sender: Timer) {
		self.progressValue = min(progressValue + 0.01, 1.0)
		print(progressValue)
		DispatchQueue.main.async {
			self.progressBlock?(self.progressValue)
		}
		if self.progressValue == 1.0 {
			print("timer_tick: progress finished")
			self.timer?.invalidate()
			self.timer = nil
			self.progressBlock = nil
		}
	}
	
	//MARK: - Download book audio
	static let kLoadingIterationTimerSec = 0.5
	//NOTE: there is deadlock with > 1 simultaneous download
	static let kMaxAllowedRequests = 3
	
	func downloadAudio(book: Book,
					   //Got recently from server or need to update from server
					   chapters: [Chapter] = [Chapter](),
					   isSanskrit: Bool,
					   //NOTE: optional is @escaping
					   success:  (() -> ())?,
					   progress: ((Float) -> ())?,
					   error: RequestErrorBlock?) {
		let bookId = book.id
		
		print("Downloading audio for book \(bookId)")
		
		//Store current download in UserDefaults; reset previous download, if was not completed
		var downloadInfo: DownloadInfo
		let prevDownloadInfo = DownloadInfo.getByID(bookId: bookId, isSanskrit: isSanskrit)
		if prevDownloadInfo == nil {
			downloadInfo = DownloadInfo(bookId: bookId, isSanskrit: isSanskrit, isDownloading: true, isDownloaded: false, isResumed: false, totalDownloads: 0, completedDownloads: 0, downloadItems: [DownloadItem]())
		} else {
			print("Resetting download: \(prevDownloadInfo!.bookId)")
			
			downloadInfo = prevDownloadInfo!
			downloadInfo.isDownloading = true
			downloadInfo.isResumed = true
			downloadInfo.completedDownloads = 0
		}
		
		DownloadInfo.save(downloadInfo)
		
		let needToUpdate = chapters.count == 0
		
		if needToUpdate {
			GitaRequestManager.getChapters(bookId: bookId, success: { (chapters: [Chapter]) in
				
				self.downloadAudioInner(book: book, chapters: chapters, downloadInfo: downloadInfo, success: success, progress: progress, error: error)
				
			}, error: { (err: RequestError) in
				print(err)
				
				//Mark error download incomplete
				downloadInfo.isDownloading = false
				downloadInfo.isResumed = false
				DownloadInfo.save(downloadInfo)
				
				//Inform for error:
				//Call block
				error?(err)
				
				//Create notification
				let message = DownloadErrorMessage(bookId: downloadInfo.bookId, isSanskrit: downloadInfo.isSanskrit, error: err)
				NotificationCenter.default.post(message.notificationForObject(self))
				
				//			GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownloadError, action: "Failed Data/Chapters request", details: err.description)
			})
		} else {
			self.downloadAudioInner(book: book, chapters: chapters, downloadInfo: downloadInfo, success: success, progress: progress, error: error)
		}
	}
	
	private func downloadAudioInner(book: Book,
							chapters: [Chapter],
							downloadInfo: DownloadInfo,
							success:  (() -> ())?,
							progress: ((Float) -> ())?,
							error: RequestErrorBlock?) {
		let needToUpdate = chapters.count == 0
		//Download all audio to Documents

		var totalDownloads = downloadInfo.isResumed ? downloadInfo.totalDownloads : 0
		
		if !downloadInfo.isResumed {
			//Store current download in UserDefaults
			downloadInfo.totalDownloads = totalDownloads
			DownloadInfo.save(downloadInfo)
		}
		
		DispatchQueue.main.async {
			progress?(downloadInfo.isResumed ?
				//Current progress
				0.01 + (Float(self.getProcessedCount(downloadInfo: downloadInfo)) / Float(totalDownloads)) * 0.98 :
				//Some progress when chapters are downloaded (for user comfort)
				0.011)
		}
		
		//For new download create list of files
		if !downloadInfo.isResumed {
			//Shlokas with individual download state
			var downloadItems = [DownloadItem]()
			downloadItems.reserveCapacity(totalDownloads)
			
			for chapter in chapters {
				for shloka in chapter.shlokas {
					if !String.isNilOrWhiteSpace(downloadInfo.isSanskrit ? shloka.audioSanskrit : shloka.audio) {
						//Link to relative object (chapter is needed to create local file path)
						shloka.chapter = chapter
						
						//Add to download list
						//NOTE: if replicate remote structure, use shlokaAudioRelativePath (... replicateRemoteDirectory: true)
						/////let audioIdentifier = self.shlokaAudioRelativePath(bookId: book.id, chapterId: chapter.id, shlokaAudio: shloka.audio)
						let fileURL = GitaRequestManager.kHostUrl + (downloadInfo.isSanskrit ? shloka.audioSanskrit : shloka.audio)
						let filePath = Book.shlokaAudioRelativePath(bookId: book.id, chapterId: chapter.order, shlokaAudio: (downloadInfo.isSanskrit ? shloka.audioSanskrit : shloka.audio), isSanskrit: downloadInfo.isSanskrit)
						
						downloadItems.append(DownloadItem(chapterOrder: chapter.order, shlokaOrder: shloka.order, isSanskrit: downloadInfo.isSanskrit, fileUrl: fileURL, filePath: filePath))
					}
				}
			}
			
			totalDownloads = downloadItems.count
			
			if totalDownloads > 0 {
				
				downloadInfo.totalDownloads = totalDownloads
				downloadInfo.downloadItems = downloadItems
				DownloadInfo.save(downloadInfo)
				
				GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownload, action: "Begin downloading audio for book \(book.id) : \(Date().fullDateString())")
			}
		}
		
		if downloadInfo.downloadItems.count > 0 {
			self.loadFiles(book: book,
						   chapters: chapters,
						   totalDownloads: totalDownloads,
						   downloadInfo: downloadInfo,
						   completed: {
							
							if needToUpdate {
								//Save book to DB
								_ = book.insertOrReplace()
								
								//Insert chapters when all audio downloaded
								Chapter.insertOrReplaceAll(chapters)
							}
							
							//Remove completed download
							DownloadInfo.clear(bookId: book.id, isSanskrit: downloadInfo.isSanskrit)
							
							progress?(1.0)
							
							//Inform for completion:
							//Call block
							_ = success?()
							
							//Create notification
							let message = DownloadCompletedMessage(bookId: downloadInfo.bookId, isSanskrit: downloadInfo.isSanskrit, chaptersCount: chapters.count, completedDownloads: totalDownloads)
							NotificationCenter.default.post(message.notificationForObject(self))
							
							GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownload, action: "Finished downloading audio for book \(book.id) : \(Date().fullDateString())")
			},
						   progress: progress,
						   error: { (err: RequestError) in
							print(err)
							
							//Stop download & mark error download incomplete
							self.stopDownload(downloadInfo: downloadInfo)
							
							//Inform for error:
							//Call block
							error?(err)
							
							//Create notification
							let message = DownloadErrorMessage(bookId: downloadInfo.bookId, isSanskrit: downloadInfo.isSanskrit, error: err)
							NotificationCenter.default.post(message.notificationForObject(self))
			})
		} else {
			
			if needToUpdate {
				progress?(0.5)
				
				//Save book to DB
				_ = book.insertOrReplace()
				
				//Insert chapters immediately if no audio
				Chapter.insertOrReplaceAll(chapters)
			}
			
			progress?(1.0)
			
			//Remove completed download
			DownloadInfo.clear(bookId: book.id, isSanskrit: downloadInfo.isSanskrit)
			
			//Inform for completion:
			//Call block
			_ = success?()
			
			//Create notification
			let message = DownloadCompletedMessage(bookId: downloadInfo.bookId, isSanskrit: downloadInfo.isSanskrit, chaptersCount: chapters.count, completedDownloads: 0)
			NotificationCenter.default.post(message.notificationForObject(self))
		}
	}
	
	private func loadFiles(book: Book,
				   chapters: [Chapter],
				   totalDownloads: Int,
				   downloadInfo: DownloadInfo,
				   completed: @escaping (() -> ()),
				   progress: ((Float) -> ())?,
				   error: @escaping RequestErrorBlock ) {
		//Check if downloading is case of download cancelled
		if !downloadInfo.isDownloading {
			return
		}
		
		let cntUnprocessed = getUnprocessedCount(downloadInfo: downloadInfo)
		let cntProcessing = getProcessingCount(downloadInfo: downloadInfo)
		
		if cntUnprocessed > 0
		{
			if (cntProcessing < DownloadManager.kMaxAllowedRequests)
			{
				let needToRunCounter = min(DownloadManager.kMaxAllowedRequests -  cntProcessing, cntUnprocessed);
				let unprocessedIndexes = getUnprocessedIndexes(downloadInfo: downloadInfo)
				
				for i in 0...needToRunCounter-1
				{
					let index = unprocessedIndexes[i]
					let itemToLoad = downloadInfo.downloadItems[index]
					itemToLoad.isDownloading = true
					//TODO: store downloadItem individually to minimize work on save
					DownloadInfo.save(downloadInfo)
					
					//Load file
					downloadFile(downloadIndex: index,
								 totalDownloads: totalDownloads,
								 downloadInfo: downloadInfo,
								 completed: completed,
								 next: { (totalDownloads: Int, downloadInfo: DownloadInfo) in
									//TODO: get download info from singleton
									//Check if downloading is case of download cancelled
									if let freshDownloadInfo = DownloadInfo.getByID(bookId: downloadInfo.bookId, isSanskrit: downloadInfo.isSanskrit) {
										if downloadInfo.isDownloading {
											self.loadFiles(book: book,
														   chapters: chapters,
														   totalDownloads: totalDownloads,
														   downloadInfo: freshDownloadInfo,
														   completed: completed,
														   progress: progress,
														   error: error)
										} else {
											print("downloadInfo cancelled")
										}
									}
					}, progress: progress,
					   error: {(err: RequestError) in
						//Stop download if timeout or server error
						if !err.isConnectionError || err.code != 404 {
							itemToLoad.isDownloaded = true
							itemToLoad.isDownloading = false
							itemToLoad.filePath = String()
							downloadInfo.completedDownloads += 1
							DownloadInfo.save(downloadInfo)
							
							//							GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownloadError, action: "error downloading files at \(String(format: "%2.f%%", 100 * (Float(index + 1) / Float(totalDownloads))))", details: itemToLoad.fileUrl)
							GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownload, action: "Download stopped at \(String(format: "%2.f%%", 100 * (Float(index + 1) / Float(totalDownloads))))")
							
							error(err)
							
						} else { //Connection error 404 - ignore and go next
							if self.getProcessedCount(downloadInfo: downloadInfo) == totalDownloads {
								completed();
							} else {
								itemToLoad.isDownloaded = true
								itemToLoad.isDownloading = false
								downloadInfo.completedDownloads += 1
								DownloadInfo.save(downloadInfo)
								
								//								GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownloadError, action: "File not found on server in book: \(book.id)", details: itemToLoad.fileUrl)
								
								self.loadFiles(book: book,
											   chapters: chapters,
											   totalDownloads: totalDownloads,
											   downloadInfo: downloadInfo,
											   completed: completed,
											   progress: progress,
											   error: error)
							}
						}
					})
				}
			}
		}
	}
	
	func getProcessingCount(downloadInfo: DownloadInfo) -> Int {
		
		var count = 0
		for item in downloadInfo.downloadItems {
			if item.isDownloading {
				count += 1;
			}
		}
		
		return count
	}
	
	func getUnprocessedIndexes(downloadInfo: DownloadInfo) -> [Int] {
		var indexes = [Int]()
		indexes.reserveCapacity(downloadInfo.downloadItems.count)
		for i in 0...(downloadInfo.downloadItems.count - 1) {
			let item = downloadInfo.downloadItems[i]
			if !item.isDownloaded && !item.isDownloading {
				indexes.append(i)
			}
		}
		
		return indexes
	}
	
	func getProcessedCount(downloadInfo: DownloadInfo) -> Int {
		
		var count = 0
		for item in downloadInfo.downloadItems {
			if item.isDownloaded {
				count += 1;
			}
		}
		
		return count
	}
	
	func getUnprocessedCount(downloadInfo: DownloadInfo) -> Int {
		
		var count = 0
		for item in downloadInfo.downloadItems {
			if !item.isDownloaded && !item.isDownloading {
				count += 1;
			}
		}
		
		return count
	}
	
	private func downloadFile(downloadIndex: Int,
							  totalDownloads: Int,
							  downloadInfo: DownloadInfo,
							  completed: @escaping (() -> ()),
							  next: @escaping ((Int, DownloadInfo) -> ()),
							  progress: ((Float) -> ())?,
							  error: RequestErrorBlock?) {
		let downloadItem = downloadInfo.downloadItems[downloadIndex]
		var downloadCount = self.getProcessedCount(downloadInfo: downloadInfo)
		
//		print("------- download \(downloadItem.fileUrl)")
		
		GitaRequestManager.downloadFile(
			fileUrl: downloadItem.fileUrl,
			method: "GET",
			headers: nil,
			configuration: RequestManagerConfiguration(),
			contextKey: "Book\(downloadInfo.bookId)_\(downloadInfo.isSanskrit ? "s" : "t")_\(downloadItem.fileUrl)",
			cacheType: .none,
			cachePath: nil,
			path: downloadItem.filePath,
			success: { (data) in
				
				downloadItem.isDownloading = false
				downloadItem.isDownloaded = true
				
				downloadCount = self.getProcessedCount(downloadInfo: downloadInfo)
				
				//Save progress state
				downloadInfo.completedDownloads = downloadCount
				DownloadInfo.save(downloadInfo)
				
				//Save file path to DB
				if downloadItem.isSanskrit {
					Shloka.updateAudioSanskritFile(bookId: downloadInfo.bookId, chapterOrder: downloadItem.chapterOrder, shlokaOrder: downloadItem.shlokaOrder, audioSanskritFile: downloadItem.filePath)
				} else {
					Shloka.updateAudioFile(bookId: downloadInfo.bookId, chapterOrder: downloadItem.chapterOrder, shlokaOrder: downloadItem.shlokaOrder, audioFile: downloadItem.filePath)
				}

				//Inform for progress:
				//Call block
				progress?(0.01 + (Float(self.getProcessedCount(downloadInfo: downloadInfo)) / Float(totalDownloads)) * 0.98)
				
				//Create notification
				let message = DownloadProgressMessage(bookId: downloadInfo.bookId, isSanskrit: downloadInfo.isSanskrit, totalDownloads: downloadInfo.totalDownloads, completedDownloads: downloadInfo.completedDownloads)
				NotificationCenter.default.post(message.notificationForObject(self))
				
				//If completed, handle final
				if downloadCount == totalDownloads {
					print("Completed download")
					completed()
				} else {
					print("Completed download #\(downloadCount) of book \(downloadInfo.bookId).\(downloadInfo.isSanskrit ? "sanskrit" : "translation")")
					next(totalDownloads, downloadInfo)
				}
		},
			progress: nil,
			error: error)
	}

	func stopDownload(downloadInfo: DownloadInfo) {
		//Mark download incomplete
		downloadInfo.isDownloading = false
		downloadInfo.isResumed = false
		DownloadInfo.save(downloadInfo)
		
		for downloadItem in downloadInfo.downloadItems {
			if downloadItem.isDownloading {
				//Mark download stopped
				downloadItem.isDownloading = false
			}
		}
		
		let contextKey = "Book\(downloadInfo.bookId)_\(downloadInfo.isSanskrit ? "s" : "t")*"
		GitaRequestManager.cancelAllConnections(contextKey)
		DownloadInfo.save(downloadInfo)
		
		//NOTE: do not notify about canceled download because we do not need to remove progress (download will be resumed)
	}
	
	func downloadAudio(book: Book, isSanskrit: Bool) {
		downloadAudio(book: book, isSanskrit: isSanskrit, success: nil, progress: nil, error: nil)
	}
}
