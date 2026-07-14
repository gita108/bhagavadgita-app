//
//  SettingsViewController.swift
//  Gita
//
//  Created by mikhail.kulichkov on 25/04/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

protocol SettingsViewControllerDelegate {
    func settingsDidChanged()
}

final class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate, InterpretationSettingsTableViewCellDelegate, SettingsLanguageViewControllerDelegate {

	fileprivate enum SettingsSections: Int {
		case contentLanguages = 0
		case contentTypes = 1
		case audio = 2
		case interpretations = 3
		
		internal static var count: Int {
			var count = 0
			while let _ = SettingsSections(rawValue: count) {
				count += 1
			}
			return count
		}
	}
	
	let sectionTitles = [Local("Settings.Sections.Language.Title"), Local("Settings.Sections.Units.Title"), Local("Settings.Sections.Audio.Title"), Local("Settings.Sections.Interpretations.Title")]
    
    var languages = [Language]()
	var selectedLanguages = [Language]()
    
//    let units: [(title: String, enabled: Bool)] = [
//        (Local("Settings.Units.Sanskrit.Title"), true),
//        (Local("Settings.Units.Transcription.Title"), false),
//        (Local("Settings.Units.Words.Title"), false),
//        (Local("Settings.Units.Comments.Title"), true)
//    ]
	
    var books = [Book]()
    var filteredBooks = [Book]()
	
    let tableView = UITableView()
    
    var downloadedBooksIDs: Set<Int> {
        return Set(filteredBooks.filter { $0.isDownloaded }.map { $0.id })
    }
    
    var oldDownloadedBooksIDs = Set<Int>()
    var oldSettings = Settings()
    var delegate: SettingsViewControllerDelegate?
	
    override func loadView() {
        self.view = UIView()
        let tableViewSideOffset: CGFloat = UIDevice.isIPad ? 128.0 : 0.0
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(dismissController))
        navigationItem.title = Local("Settings.Title")
        view.backgroundColor = .gray5
        
        view.addSubview(tableView)
        
        activateConstraints(
            tableView.leadingItem == view.leadingItem + tableViewSideOffset,
            tableView.trailingItem == view.trailingItem - tableViewSideOffset,
            tableView.topItem == view.topItem,
            tableView.bottomItem == view.bottomItem
        )
    }
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.cellLayoutMarginsFollowReadableWidth = false
        InterpretationSettingsTableViewCell.register(for: tableView)
		UnitSettingsTableViewCell.register(for: tableView)
		
		//Store old settings & books to check if settings were changed on exit
        oldSettings = Settings.shared.copy() as! Settings
        oldDownloadedBooksIDs = downloadedBooksIDs
		
		//Get books from server
		requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
        navigationController?.navigationBar.applyWhiteDesign()
        let titleTextAttributes = [
            NSFontAttributeName: UIFont(type: .regular, size: 18.0),
            NSForegroundColorAttributeName: UIColor.black
        ]
        navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
		
		NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgressMessage(notification:)), name: NSNotification.Name(rawValue: DownloadProgressMessage.identifier), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadCompletedMessage(notification:)), name: NSNotification.Name(rawValue: DownloadCompletedMessage.identifier), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadErrorMessage(notification:)), name: NSNotification.Name(rawValue: DownloadErrorMessage.identifier), object: nil)

		GAHelper.logScreen(String(describing: type(of: self)))
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}
	
    // MARK: - TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SettingsSections.contentLanguages.rawValue:
            return 1
			
		case SettingsSections.contentTypes.rawValue:
			return 4
			
        case SettingsSections.audio.rawValue:
            return 3
			
        case SettingsSections.interpretations.rawValue:
            return filteredBooks.count
			
        default:
            return 0
        }
    }
    
    // Return the row for the corresponding section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SettingsSections.contentLanguages.rawValue:
            let languagesTitles = selectedLanguages.map { $0.name.capitalized }
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.attributedText = Style.cellAttributedText(languagesTitles.joined(separator: ", "))
            return cell
			
        case SettingsSections.contentTypes.rawValue:
			
            switch indexPath.row {
            case 0:
                let title = Local("Settings.Units.Sanskrit.Title")
                let enabled = Settings.shared.showSanskrit
				let cell = tableView.dequeue(for: indexPath) as UnitSettingsTableViewCell
				cell.fill(title: title, enabled: enabled, type: .other, switchAction: { (enabled: Bool) in
                    Settings.shared.showSanskrit = enabled
                })
				return cell
            case 1:
                let title = Local("Settings.Units.Transcription.Title")
                let enabled = Settings.shared.showTranscription
				let cell = tableView.dequeue(for: indexPath) as UnitSettingsTableViewCell
				cell.fill(title: title, enabled: enabled, type: .other, switchAction: { (enabled: Bool) in
                    Settings.shared.showTranscription = enabled
                })
				return cell
            case 2:
                let title = Local("Settings.Units.Words.Title")
                let enabled = Settings.shared.showVocabulary
				let cell = tableView.dequeue(for: indexPath) as UnitSettingsTableViewCell
				cell.fill(title: title, enabled: enabled, type: .other, switchAction: { (enabled: Bool) in
                    Settings.shared.showVocabulary = enabled
                })
				return cell
            case 3:
                let title = Local("Settings.Units.Comments.Title")
                let enabled = Settings.shared.showComments
				let cell = tableView.dequeue(for: indexPath) as UnitSettingsTableViewCell
				cell.fill(title: title, enabled: enabled, type: .other, switchAction: { (enabled: Bool) in
                    Settings.shared.showComments = enabled
                })
				return cell
            default:
                break
            }
			
		case SettingsSections.audio.rawValue:
			switch indexPath.row {
			case 0:
				let title = Local("Settings.Audio.Translation")
				let hasAudio = Book.hasAudio(Settings.shared.defaultBookId, isSanskrit: false)
				let enabled = Settings.shared.useTranslationAudio && hasAudio
				let cell = tableView.dequeue(for: indexPath) as UnitSettingsTableViewCell
				cell.fill(title: title, enabled: enabled, type: .audioTranslation, switchAction: { (enabled: Bool) in
					self.toggleAudio(cell: cell, enabled: enabled)
				})
				//If translation audio is downloading, recreate progress
				if let downloadInfo = DownloadInfo.getByID(bookId: Settings.shared.defaultBookId, isSanskrit: false) {
					cell.showProgress(downloadInfo.progress, isDownloading: true)
					//When downloading setting is enabled and cannot be changed
					cell.setOn(true)
					cell.setEnabled(false)
				} else if !hasAudio {
					cell.setEnabled(false)
				} else {
					cell.setEnabled(true)
				}
				return cell
			case 1:
				let title = Local("Settings.Audio.Sanskrit")
				let hasAudio = Book.hasAudio(Settings.shared.defaultBookId, isSanskrit: true)
				let enabled = Settings.shared.useSanskritAudio && hasAudio
				let cell = tableView.dequeue(for: indexPath) as UnitSettingsTableViewCell
				cell.fill(title: title, enabled: enabled, type: .audioSanskrit, switchAction: { (enabled: Bool) in
					self.toggleAudio(cell: cell, enabled: enabled)
				})
				//TODO: move to fill(..)
				//If sanskrit audio is downloading, recreate progress
				if let downloadInfo = DownloadInfo.getByID(bookId: Settings.shared.defaultBookId, isSanskrit: true) {
					cell.showProgress(downloadInfo.progress, isDownloading: true)
				} else if !hasAudio {
					cell.setEnabled(false)
				} else {
					cell.setEnabled(true)
				}
				return cell
			case 2:
				let title = Local("Settings.Audio.AutoPlay")
				let enabled = Settings.shared.autoPlayAudio
				let cell = tableView.dequeue(for: indexPath) as UnitSettingsTableViewCell
				cell.fill(title: title, enabled: enabled, type: .other, switchAction: { (enabled: Bool) in
					Settings.shared.autoPlayAudio = enabled
				})
				return cell
			default:
				break
			}
			
		case SettingsSections.interpretations.rawValue:
            let cell: InterpretationSettingsTableViewCell = tableView.dequeue(for: indexPath)
			cell.downloadDelegate = self
			cell.delegate = self
			
			let book = filteredBooks[indexPath.row]
			
			//TODO: add download info for chapters, without type
//			let downloadInfo = DownloadInfo.getByID(bookId: book.id, isSanskrit: Settings.shared.useSanskritAudio)
//			if downloadInfo != nil {
//				book.downloadInfo = downloadInfo
//				book.isDownloaded = downloadInfo!.isDownloaded
//			}
			
			cell.fill(title: book.name, isDownloaded: book.isDownloaded, isDownloading: book.downloadInfo != nil && book.id != Settings.shared.defaultBookId)
			
            return cell
        default:
            break
        }
		
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 0, section: SettingsSections.contentLanguages.rawValue) {
			let settingsVC = SettingsLanguageViewController(delegate: self)
			//Pass all languages to Select language screen
            settingsVC.languages = languages
            navigationController?.pushViewController(settingsVC, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // http://stackoverflow.com/questions/31983787/dynamically-change-cell-height-programmatically
    // Height of row depending on height of attributed text in inner UILabel
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SettingsSections.interpretations.rawValue {
            let text = filteredBooks[indexPath.row].name
            let width = self.tableView.frame.width - 154.0
            let font = UIFont(type: .regular, size: 16.0)
            return Style.heightOfText(text, font: font, width: width) + 20.0
        }
        return UITableViewAutomaticDimension
    }
    
    // Customize the section headings for each section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 47.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .gray5
        
        let text = sectionTitles.indices.contains(section) ? sectionTitles[section] : ""
        let label = Style.settingsSubtitleLabel(text: text)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        
        activateConstraints(
            label.leadingItem == headerView.leadingItem + 16.0,
            label.bottomItem == headerView.bottomItem - 3.0
        )
        
        return headerView
    }
    
    // MARK: - SwipeTableViewCellDelegate
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
		
		let filteredBook = filteredBooks[indexPath.row]
		//let _book = books.first(where: { $0.id == filteredBook.id })
		
		guard filteredBook.isDownloaded && Settings.shared.defaultBookId != filteredBook.id else {
			return nil
		}
        
        let deleteAction = SwipeAction(style: .default, title: nil) { [unowned self] action, indexPath in
            print("Delete book(\(indexPath.row))")
			
			//Delete from DB; it could not be book with audio, because default book never is deleted and never changes
			Book.deleteDownloadedBookFromDB(filteredBook.id)
//			DownloadInfo.clear(bookId: filteredBook.id, isSanskrit: Settings.shared.useSanskritAudio)
			
			//Reset dataitem properties
			filteredBook.isDownloaded = false
			filteredBook.chaptersCount = 0
			
			//Reload cell
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "ic_delete")
        deleteAction.backgroundColor = UIColor.red1
        
        return [deleteAction]
    }
	
	//MARK: - Download
	//MARK: - InterpretationSettingsTableViewCellDelegate
	func interpretationDidSelectedDownload(_ cell: InterpretationSettingsTableViewCell) {
		if let indexPath = tableView.indexPath(for: cell) {
			cell.showProgress()
			
			let book = filteredBooks[indexPath.row]
			
			DownloadManager.shared.downloadBook(book: book,
												isSanskrit: Settings.shared.useSanskritAudio,
												success: { (chapters: [Chapter], hasAudio: Bool) in
													self.markBookDownloaded(book: book, chaptersCount: chapters.count)
			}, progress: {(progressValue) in
			},
			   error: { (err: RequestError) in
				print(err)
			})
		}
	}
	
	private func markBookDownloaded(book: Book, chaptersCount: Int) {
		//Update dataitem
		book.isDownloaded = chaptersCount > 0
		//Reset download
		book.downloadInfo = nil
		
		if chaptersCount > 0 {
			book.chaptersCount = chaptersCount
			
			//Reload cell, if book in filtered list
			if let row = filteredBooks.index(where: { $0.id == book.id } ) {
				let indexPath = IndexPath(row: row, section: SettingsSections.interpretations.rawValue)
				self.tableView.reloadRows(at: [indexPath], with: .automatic)
			}
			//??? TODO:
			//				//Reload cell, if visible
			//				for cell in tableView.visibleCells {
			//					if let cell = cell as? InterpretationSettingsTableViewCell,
			//						let indexPath = tableView.indexPath(for: cell) {
			//						if filteredBooks[indexPath.row].id == book.id {
			//							cell.configure(isDownloaded: book.isDownloaded, downloadDetails: nil)
			//						}
			//					}
			//				}
		} else {
			//Reload cell, if book in filtered list
			if let row = filteredBooks.index(where: { $0.id == book.id } ) {
				let indexPath = IndexPath(row: row, section: SettingsSections.interpretations.rawValue)
				self.tableView.reloadRows(at: [indexPath], with: .automatic)
			}
			
			//Alert
			AlertManager.present(message: Local("Settings.DownloadBookError"), buttons: [Local("OK")], dismissBlock: { (buttonIndex) in
			})
		}
	}
	
	//MARK: - Toggle audio (UnitSettingsTableViewCell)
	func toggleAudio(cell: UnitSettingsTableViewCell, enabled: Bool) {
		let isSanskrit = cell.type == .audioSanskrit
		
		if enabled {
			//Download/reuse audio
			if !Book.audioDownloaded(Settings.shared.defaultBookId, isSanskrit: isSanskrit) {
				//Alert + download + show progress
				AlertManager.present(message: Local(isSanskrit ? "Settings.DownloadAudioSanskrit" : "Settings.DownloadAudioTranslation"), buttons: [Local("Download.No"), Local("Download.Yes")], dismissBlock: { (buttonIndex) in
					
					if buttonIndex == 1 {
						
						//Disable switch when downloading
						cell.setEnabled(false)
						cell.showProgress(0, isDownloading: true)
						
						let book = Book.getByID(Settings.shared.defaultBookId)!
						//					let settingValue = isSanskrit ? Settings.shared.useSanskritAudio : Settings.shared.useTranslationAudio
						
						DownloadManager.shared.downloadAudio(book: book, isSanskrit: isSanskrit,  success: {
							if isSanskrit {
								Settings.shared.useSanskritAudio = enabled
							} else {
								Settings.shared.useTranslationAudio = enabled
							}
							
							//Enable switch on success
							cell.setEnabled(true)
							cell.showProgress(1.0, isDownloading: false)
						}, progress: { (progress) in
						}, error: { (err: RequestError) in
							print(err)
							
							//Set switch back + alert
							AlertManager.present(message: Local("Settings.DownloadAudioError"), buttons: [Local("OK")], dismissBlock: { (buttonIndex) in
								
								//Enable switch on error
								cell.setEnabled(true)
								//Reset switch on error
								cell.setOn(false)
							})
						})
					} else {
						//Turn switch back, if user canceled downloading audio (allow to play only from disk)
						cell.setOn(false)
					}
				})
			} else {
				//Audio has not been deleted, no need to download
				if isSanskrit {
					Settings.shared.useSanskritAudio = enabled
				} else {
					Settings.shared.useTranslationAudio = enabled
				}
			}
		} else {
			//Ask if delete audio (fr safetu check if audio is present)
			if Book.audioDownloaded(Settings.shared.defaultBookId, isSanskrit: isSanskrit) {
				AlertManager.present(message: Local(isSanskrit ? "Settings.DeleteAudioSanskrit" : "Settings.DeleteAudioTranslation"), buttons: [Local("Download.No"), Local("Download.Yes")], dismissBlock: { (buttonIndex) in
					
					if buttonIndex == 1 {
						Book.deleteAudio(bookId: Settings.shared.defaultBookId, isSanskrit: isSanskrit)
						if isSanskrit {
							Settings.shared.useSanskritAudio = enabled
						} else {
							Settings.shared.useTranslationAudio = enabled
						}
					} else {
						if isSanskrit {
							Settings.shared.useSanskritAudio = enabled
						} else {
							Settings.shared.useTranslationAudio = enabled
						}
					}
				})
			}
		}
	}
	
    // MARK: - SettingsLanguageViewControllerDelegate
	
	func didSelectedlanguages(languages: [Language]) {
		selectedLanguages = languages
		
		let selectedLanguageIds = selectedLanguages.map { $0.id }
		let defaultBookId = Settings.shared.defaultBookId
		self.filteredBooks = self.books.filter { selectedLanguageIds.contains($0.languageId) || $0.id == defaultBookId }

		tableView.beginUpdates()
		
		tableView.reloadRows(at: [IndexPath(row: 0, section: SettingsSections.contentLanguages.rawValue)], with: .none)
		tableView.reloadSections(IndexSet(integer: SettingsSections.interpretations.rawValue), with: .none)
		
		tableView.endUpdates()
	}

	//MARK: - Methods
	
	func dismissController() {
		
		// If settings are changed or new books are downloaded then reload current shloka via delegate
		if oldSettings.showSanskrit != Settings.shared.showSanskrit ||
			oldSettings.showTranscription != Settings.shared.showTranscription ||
			oldSettings.showVocabulary != Settings.shared.showVocabulary ||
			oldSettings.showComments != Settings.shared.showComments ||
			oldSettings.selectedlanguagesIDs != Settings.shared.selectedlanguagesIDs ||
			oldDownloadedBooksIDs != downloadedBooksIDs {
			
			delegate?.settingsDidChanged()
		}
		
		dismiss(animated: true, completion: nil)
	}
	
	func requestData() {
		
		self.view.showActivityIndicator(color: .red1)
		
		GitaRequestManager.getLanguages(success: { (languages: [Language]) in
			GitaRequestManager.getBooks(success: { (books: [Book]) in
				self.view.hideActivityIndicator()
				
				self.mergeLanguages(languages: languages)
				self.mergeBooks(books: books)
				
				self.tableView.reloadData()
				
			}, error: { (err: RequestError) in
				self.view.hideActivityIndicator()
				
				print(err)
				
				self.loadDataFromDB()
			})
		}, error: { (err: RequestError) in
			self.view.hideActivityIndicator()
			
			print(err)
			
			self.loadDataFromDB()
		})
	}
	
	func mergeLanguages(languages: [Language]) {
		var existingLanguages = Language.loadAll()
		
		//Add languages that are absent locally
		//NOTE: Keep language locally if it is deleted on server.
		
		var newLanguages = [Language]()
		for lang in languages {
			if existingLanguages.first(where: { $0.id == lang.id }) == nil {
				//Add item from server
				newLanguages.append(lang)
			}
		}
		
		existingLanguages.append(contentsOf: newLanguages)
		
		self.languages = existingLanguages.sorted { return $0.id < $1.id }
		self.selectedLanguages = self.languages.filter { $0.isSelected }
	}
	
	func mergeBooks(books: [Book]) {
		
		//Add books that are absent locally
		//NOTE: Keep book locally if it is deleted on server.
		
		var downloadedBooks = Book.loadAll()
		var newBooks = [Book]()
		
		for book in books {
			if downloadedBooks.first(where: { $0.id == book.id } ) == nil {
				//Add item from server
				book.isDownloaded = false
				newBooks.append(book)
			}
		}
		
		downloadedBooks.append(contentsOf: newBooks)
		
		self.books = downloadedBooks.sorted { return $0.id < $1.id }
		
		let selectedLanguageIds = languages.filter { $0.isSelected }.map { $0.id }
		let defaultBookId = Settings.shared.defaultBookId
		self.filteredBooks = self.books.filter { selectedLanguageIds.contains($0.languageId) || $0.id == defaultBookId }
	}
	
	func loadDataFromDB() {
		languages = Language.loadAll()
		selectedLanguages = languages.filter { $0.isSelected }
		
		self.books = Book.loadWithLanguages(selectedLanguages.map { $0.id }, defaultBookId: Settings.shared.defaultBookId)
		let selectedLanguageIds = selectedLanguages.map { $0.id }
		let defaultBookId = Settings.shared.defaultBookId
		self.filteredBooks = books.filter { selectedLanguageIds.contains($0.languageId) || $0.id == defaultBookId }
		
		self.tableView.reloadData()
	}
	
	//MARK: - Notification
	func handleDownloadCompletedMessage(notification: Notification) {
		if let message = DownloadCompletedMessage.messageFromNotification(notification) {
			let isSanskrit = message.isSanskrit
			
			for cell in tableView.visibleCells {
				if let settingCell = cell as? UnitSettingsTableViewCell {
					if isSanskrit && settingCell.type == .audioSanskrit
						|| !isSanskrit && settingCell.type == .audioTranslation {
						
						//Enable switch
						settingCell.setEnabled(true)
						//Remove progress
						settingCell.showProgress(1.0, isDownloading: false)
					}
				}
			}
		}
	}
	
	func handleDownloadProgressMessage(notification: Notification) {
		if let message = DownloadProgressMessage.messageFromNotification(notification),
			let book = books.first (where: { $0.id == message.bookId }) {
			let isSanskrit = message.isSanskrit

			//Update dataitem
			if book.downloadInfo != nil {
				book.downloadInfo!.completedDownloads = message.completedDownloads
			} else {
				book.downloadInfo = DownloadInfo(bookId: book.id, isSanskrit: isSanskrit, isDownloading: true, isDownloaded: false, isResumed: false, totalDownloads: message.totalDownloads, completedDownloads: message.completedDownloads, downloadItems: [DownloadItem]())
			}
			
			//Reload cell, if visible
			for cell in tableView.visibleCells {
				if let settingCell = cell as? UnitSettingsTableViewCell {
					if isSanskrit && settingCell.type == .audioSanskrit
						|| !isSanskrit && settingCell.type == .audioTranslation {
						
						//Show progress
						settingCell.showProgress(message.progress, isDownloading: true)
					}
				}
			}
		}
	}

	func handleDownloadErrorMessage(notification: Notification) {
		if let message = DownloadErrorMessage.messageFromNotification(notification),
			let book = books.first (where: { $0.id == message.bookId }) {
			
			//Reset download
			book.downloadInfo = nil
			
			var indexPath: IndexPath? = nil
			
			//Reload cell, if book in filtered list
			if let row = filteredBooks.index(where: { $0.id == message.bookId } ) {
				indexPath = IndexPath(row: row, section: SettingsSections.interpretations.rawValue)
				
				if let cell = tableView.cellForRow(at: indexPath!) as? InterpretationSettingsTableViewCell {
					cell.hideProgress(success: false)
				}
			}
			
			//Reload cell, if book in filtered list
			if let row = filteredBooks.index(where: { $0.id == book.id } ) {
				let indexPath = IndexPath(row: row, section: SettingsSections.interpretations.rawValue)
				self.tableView.reloadRows(at: [indexPath], with: .automatic)
			}
			
			//Alert
			let downloadInfo = DownloadInfo.getByID(bookId: book.id, isSanskrit: message.isSanskrit)
			print("handleDownloadErrorMessage downloadInfo:\(String(describing: downloadInfo))")
			//Do not show alert if application finished downloads or will resume download
			if downloadInfo == nil || !downloadInfo!.isResumed {
				AlertManager.present(message: Local("Settings.DownloadAudioError"), buttons: [Local("OK")], dismissBlock: { (buttonIndex) in
				})
			}
		}
	}
}

extension UITableView {
    func visibleCells(excluding cell: UITableViewCell) -> [UITableViewCell] {
        var visibleCells = self.visibleCells
        if let index = visibleCells.index(of: cell) {
            visibleCells.remove(at: index)
        }
        return visibleCells
    }
    
}
