//
//  ContentsViewController.swift
//  Gita
//
//  Created by mikhail.kulichkov on 25/04/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

final class ContentsViewController: UIViewController,
	UITableViewDataSource, UITableViewDelegate,
	SearchResultsDelegate,
	ShlokaDelegate,
	SettingsViewControllerDelegate,
	ShlokasChapterContentsTableViewCellDelegate,
	ChapterContentsHeaderViewDelegate,
	QuoteViewShareDelegate,
	AudioManagerDelegate {

    private let kChapterContentsHeaderID = "ChapterContentsHeaderView"

	private var chapterEntries = [ContentsEntryModel]()
	private var quote: Quote? = nil
	
	private var hasQuote: Bool {
		return self.quote != nil
	}
	
	//Relative number of chapter section (ignore quote section)
	private var showingSection: Int? = 0
	
    fileprivate var selectedShloka: (chapterIndex: Int, shlokaIndex: Int) {
        get {
            return Settings.shared.selectedShloka
        }
        set {
            Settings.shared.selectedShloka = newValue
        }
    }
	
	fileprivate var lastDisplayedShloka: (chapterIndex: Int, shlokaIndex: Int) = (chapterIndex: -1, shlokaIndex: -1)
	
    private let tableView = UITableView()
	
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
		//For switching next track in background
		UIApplication.shared.beginReceivingRemoteControlEvents()

        navigationItem.title = Local("Contents.Navigation.Title")
        view.backgroundColor = .white
        
        selectedShloka = Settings.shared.selectedShloka
		
		tableView.separatorInset = .zero
        tableView.separatorColor = UIColor.gray5
		
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
		tableView.delegate = self
		tableView.dataSource = self
		
		QuoteTableViewCell.register(for: tableView)
        ShlokasChapterContentsTableViewCell.register(for: tableView)
        tableView.register(ChapterContentsHeaderView.self, forHeaderFooterViewReuseIdentifier: kChapterContentsHeaderID)
        
        view.addSubview(tableView)

		activateConstraints(
            tableView.edges()
        )
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_settings"), style: .plain, target: self, action: #selector(btnSettingsPressed))
		let btnSearch = UIBarButtonItem(image: UIImage(named: "ic_search_white"), style: .plain, target: self, action: #selector(btnSearch_Click))
		let btnBookmarks = UIBarButtonItem(image: UIImage(named: "ic_bookmarks"), style: .plain, target: self, action: #selector(btnBookmarks_Click))
		navigationItem.setRightBarButtonItems([btnBookmarks, btnSearch], animated: false)

		let navBar = UINavigationBar()
		let navItem = UINavigationItem()
		navItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_settings"), style: .plain, target: self, action: #selector(btnSettingsPressed))
		navBar.pushItem(navItem, animated: false)
		
		if !UIDevice.isIPad {
			loadData()
		}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavigationBar(isRed: true)
		
		if UIDevice.isIPad {
			loadData()
		}
		
		GAHelper.logScreen(String(describing: type(of: self)))
		
		NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
    }
	
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !(presentedViewController is UINavigationController) && !UIDevice.isIPad {
            setUpNavigationBar(isRed: false)
        }
    }
	
	override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
		for cell in tableView.visibleCells {
			if let cell = cell as? ShlokasChapterContentsTableViewCell {
				cell.invalidateLayout()
			}
		}
	}
	
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
		return chapterEntries.count + (hasQuote ? 1 : 0)
    }
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if hasQuote && indexPath.section == 0 && indexPath.row == 0 {
			let cell: QuoteTableViewCell = tableView.dequeue(for: indexPath)
			cell.delegate = self
			cell.quote = self.quote!
			
			return cell
		} else {
			let relativeSection = indexPath.section - (hasQuote ? 1 : 0)
			let shlokaCell: ShlokasChapterContentsTableViewCell = tableView.dequeue(for: indexPath)
			shlokaCell.delegate = self
			
//			print("Chapter reload: \(chapterEntries[relativeSection].name), relative \(relativeSection), showing: \(showingSection != nil ? String(showingSection!) : "none")")

//			configureCell(shlokaCell, section: relativeSection)
			
			//Reload contents for expanded chapter
			
			// If selected shloka is in showingChapter select this shloka in Cell
			var currentSelected: Int? = nil
			let chapterIndex = relativeSection
			if selectedShloka.chapterIndex == chapterIndex {
				currentSelected = selectedShloka.shlokaIndex
			}
			
			shlokaCell.fill(shlokas: chapterEntries[chapterIndex].shlokas, selectedShloka: currentSelected)

			return shlokaCell
		}
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if hasQuote && section == 0 {
			return UIView()
		}
		else {
			let relativeSection = section - (hasQuote ? 1 : 0)
			
			let chapter = chapterEntries[relativeSection]
			if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kChapterContentsHeaderID) as? ChapterContentsHeaderView {
				
				//NOTE: single shloka entry can include multiple shlokas, so use name of last shloka as number
//				let shlokasCount = chapter.shlokas.count > 0 ?
//					(Int(chapter.shlokas.last!.name.split(["."], removeSeparators: true, removeEmptyEntries: true).last ?? "0")!) :
//				0
				var shlokasCount = 0
				if chapter.shlokas.count > 0 {
					//Example: 15 or 15-18
					let lastShlokaNumber = chapter.shlokas.last!.name.split(["."], removeSeparators: true, removeEmptyEntries: true).last ?? String()
					
					if let number = Int(lastShlokaNumber) {
						shlokasCount = number
					} else {
						let lastShlokaNumberPart = chapter.shlokas.last!.name.split(["-"], removeSeparators: true, removeEmptyEntries: true).last ?? String()
						shlokasCount = Int(lastShlokaNumberPart) ?? 0
					}					
				}
				
				headerView.fill(
					expanded:(relativeSection == showingSection),
					section: relativeSection,
					chapterNumber: "\(Local("Contents.Chapter.Title")) \(chapter.chapterOrder)",
					chapterTitle: chapter.name,
					shlokasCount: shlokasCount)
				
				headerView.delegate = self
				headerView.section = relativeSection
				
				return headerView
			}
		}
		
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if hasQuote && indexPath.section == 0 {
			return QuoteTableViewCell.height(quote: self.quote!, width: view.bounds.width)
		} else {
			let relativeSection = indexPath.section - (hasQuote ? 1 : 0)
			if showingSection != relativeSection {
				return 0.01
			}
			
			let shlokasNumber = chapterEntries[relativeSection].shlokas.count
			return ShlokasChapterContentsTableViewCell.height(for: shlokasNumber, width: view.bounds.width)
		}
    }
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if hasQuote && section == 0 {
			return 0.01
		} else {
			let chapter = chapterEntries[section - (hasQuote ? 1 : 0)]
			return ChapterContentsHeaderView.height(chapterNumber: "\(Local("Contents.Chapter.Title")) \(chapter.chapterOrder)",
				chapterTitle: chapter.name,
				width: view.bounds.width,
				shlokasCount: chapter.shlokas.count)
		}
	}
    
	// MARK: - SearchResultsDelegate
	
	func searchResults(_ searchResultViewController: ContentsSearchResultViewController, didSelectValue value: Any?) {
		// Handle picked value here (worked with Roman's solution)
		searchResultViewController.searchController?.dismiss(animated: false, completion: {
			if let shlokaModel = value as? ShlokaModel {
				self.openShloka(from: self, chapterOrder: shlokaModel.chapterOrder, shlokaOrder: shlokaModel.shlokaOrder, backBarButtonTitle: Local("Shloka.BackButton.Title.Contents"))
			}
		})
	}
	
    // MARK: - ShlokaDelegate
	
	func toggledBookmark(from controller: UIViewController, chapterOrder: Int, shlokaOrder: Int, bookmarked: Bool) {
		//Remove bookmark icon from shloka
		updateBookmark(chapterOrder: chapterOrder, shlokaOrder: shlokaOrder)
		
		//Update shloka if bookmark is deleted and shloka on screen (bookmarks + swipe delete)
		if controller is BookmarksViewController {
			if let viewControllers = splitViewController?.viewControllers, viewControllers.count > 1 {
				if let detailNavVC = splitViewController?.viewControllers.last as? UINavigationController,
					let shlokaVC = detailNavVC.topViewController as? ShlokaViewController {
					//If changed bookmark is displayed
					if shlokaVC.chapterNumber == chapterOrder && shlokaVC.shlokaNumber == shlokaOrder {
						shlokaVC.bookmarked = bookmarked
					}
				}
			}
		}
	}
	
	func shlokaViewControllerDidSelectNext(_ shlokaVC: ShlokaViewController) {
		//Open next shloka with audio stopped by default
		self.shlokaViewControllerDidSelectNext(shlokaVC, audioMode: .`default`)
	}
	
	//Helper method
	private func shlokaViewControllerDidSelectNext(_ shlokaVC: ShlokaViewController, audioMode: ShlokaViewController.AudioMode = .`default`) {
        if selectedShloka.shlokaIndex < chapterEntries[selectedShloka.chapterIndex].shlokas.count - 1 {
            selectedShloka.shlokaIndex += 1
        } else if selectedShloka.chapterIndex < chapterEntries.count - 1 {
            selectedShloka.chapterIndex += 1
            selectedShloka.shlokaIndex = 0
        } else {
            return
        }
		
		let navStackCount = shlokaVC.navigationController?.viewControllers.count ?? 0
        let backBarButtonTitle: String = navStackCount > 1 ?
			(shlokaVC.navigationController?.viewControllers[navStackCount - 2] is ContentsViewController ?
				Local("Shloka.BackButton.Title.Contents") :
				Local("Shloka.BackButton.Title.Bookmarks"))
			: ""
		
		displayShloka(chapterIndex: selectedShloka.chapterIndex, shlokaIndex: selectedShloka.shlokaIndex, navigation: true, backBarButtonTitle: backBarButtonTitle, delegate: shlokaVC.delegate, audioMode:  audioMode)
    }
    
    func shlokaViewControllerDidSelectPrevious(_ shlokaVC: ShlokaViewController) {
        if selectedShloka.shlokaIndex > 0 {
            selectedShloka.shlokaIndex -= 1
        } else if selectedShloka.chapterIndex > 0 {
            selectedShloka.chapterIndex -= 1
            selectedShloka.shlokaIndex = chapterEntries[selectedShloka.chapterIndex].shlokas.count - 1
        } else {
            return
        }
        
		let navStackCount = shlokaVC.navigationController?.viewControllers.count ?? 0
		
		let backBarButtonTitle: String = navStackCount > 1 ?
			(shlokaVC.navigationController?.viewControllers[navStackCount - 2] is ContentsViewController ?
				Local("Shloka.BackButton.Title.Contents") :
				Local("Shloka.BackButton.Title.Bookmarks"))
			: ""
		
		//NOTE: same delegate as for source shloka controller
		displayShloka(chapterIndex: selectedShloka.chapterIndex, shlokaIndex: selectedShloka.shlokaIndex, navigation: true, backBarButtonTitle: backBarButtonTitle, delegate: shlokaVC.delegate)
    }
	
	func openShloka(from controller: UIViewController, chapterOrder: Int, shlokaOrder: Int) {
		if let bookmarksVC = controller as? BookmarksViewController {
			openShloka(from: bookmarksVC, chapterOrder: chapterOrder, shlokaOrder: shlokaOrder, backBarButtonTitle: Local("Shloka.BackButton.Title.Bookmarks"))
		}
	}
	
	func didCompletedTrack(_ vc: ShlokaViewController) {
		if !Settings.shared.autoPlayAudio {
			return
		}

		GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryUI, action: "Play next")
		
		if UIApplication.shared.applicationState == .active {
			
			//Do not stop player of previous shloka if switching audio automatically
			if let shlokaVC = getCurrentShlokaVC() {
				//Do not stop player of previous shloka if switching audio automatically
				shlokaVC.stopAudioOnDisappear = false
			}
			
			//Open next screen and play
			self.shlokaViewControllerDidSelectNext(vc, audioMode: .start)
		} else {
			//Get next shloka, extract audio and play in background
			audioManagerDidCompletedTrack()
		}
	}
	
	//MARK: - AudioManagerDelegate
	func audioManagerDidCompletedTrack() {
		if !Settings.shared.autoPlayAudio {
			return
		}
		
		//In background just play
		var chapterIndex = Settings.shared.selectedShloka.chapterIndex
		var shlokaIndex = Settings.shared.selectedShloka.shlokaIndex
		
		if shlokaIndex < chapterEntries[selectedShloka.chapterIndex].shlokas.count - 1 {
			shlokaIndex += 1
		} else if selectedShloka.chapterIndex < chapterEntries.count - 1 {
			chapterIndex += 1
			shlokaIndex = 0
		} else {
			return
		}
		
		//Store new index
		Settings.shared.selectedShloka = (chapterIndex: chapterIndex, shlokaIndex: shlokaIndex)
		
		//Get numbers
		let selectedChapter = chapterEntries[chapterIndex]
		let shlokaOrder = selectedChapter.shlokas[shlokaIndex].order
		
		let chapterNumber = selectedChapter.chapterOrder
		let shlokaNumber = shlokaOrder
		
		if let shlokaModel = ShlokaModel.get(chapterOrder: chapterNumber, shlokaOrder: shlokaNumber, bookId: Settings.shared.defaultBookId, languageIds: Settings.shared.selectedlanguagesIDs),
			Settings.shared.useTranslationAudio || Settings.shared.useSanskritAudio,
			shlokaModel.hasDownloadedAudio(isSanskrit: Settings.shared.useSanskritAudio) {
			
			AudioManager.shared.delegate = self
			AudioManager.shared.play(filePath: shlokaModel.audioPath(isSanskrit: Settings.shared.useSanskritAudio))
		} else {
			print("shlokaModel error")
		}
	}

	//MARK: - Notification
	func applicationDidBecomeActive(notification: Notification) {
		//Stop switching tracks in background
		AudioManager.shared.delegate = nil
		AudioManager.shared.removeTimer()
		
		//Had switched to next shloka in background
		if lastDisplayedShloka.chapterIndex >= 0 && lastDisplayedShloka.chapterIndex != selectedShloka.chapterIndex ||
			lastDisplayedShloka.shlokaIndex >= 0 && lastDisplayedShloka.shlokaIndex != selectedShloka.shlokaIndex {
			
			if let shlokaVC = getCurrentShlokaVC() {
				//Do not stop player of previous shloka if switching audio automatically
				shlokaVC.stopAudioOnDisappear = false
				
				//Display next shloka with audio progress at SoundManager current time
				displayShloka(chapterIndex: selectedShloka.chapterIndex, shlokaIndex: selectedShloka.shlokaIndex, navigation: true, backBarButtonTitle: shlokaVC.backBarButtonTitle, delegate: shlokaVC.delegate, audioMode: .`continue`)
			}
		}		
	}
	
	//MARK: - SettingsViewControllerDelegate
	
	func settingsDidChanged() {
		if UIDevice.isIPad {
			displayShloka(chapterIndex: selectedShloka.chapterIndex, shlokaIndex: selectedShloka.shlokaIndex, navigation: true, backBarButtonTitle: Local("Shloka.BackButton.Title.Contents"), delegate: self.shlokaDelegate())
		}
	}
	
	//MARK: - ChapterContentsHeaderViewDelegate
	
	func didSelected(_ view: ChapterContentsHeaderView) {
		self.showHideShlokas(section: view.section)
	}
	
	//MARK: - ShlokasChapterContentsTableViewCellDelegate
	
	func didSelectCell(_ cell: ShlokasChapterContentsTableViewCell, itemIndex: Int) {
		if showingSection != nil {
			self.selectedShloka.shlokaIndex = itemIndex
			self.selectedShloka.chapterIndex = self.showingSection!
			let backBarButtonTitle: String = Local("Shloka.BackButton.Title.Contents")
			
			self.displayShloka(chapterIndex: self.showingSection!, shlokaIndex: itemIndex, navigation: true, backBarButtonTitle: backBarButtonTitle, delegate: self)
		}
	}
	
	//MARK: - QuoteViewShareDelegate
	func share(_ view: QuoteTableViewCell, quote: Quote) {
		let activityVC = UIActivityViewController(activityItems: [quote.text + "\n" + quote.author], applicationActivities: nil)
		
		if UIDevice.isIPad, let popover = activityVC.popoverPresentationController {
			popover.sourceRect = self.view.bounds
			popover.sourceView = self.view
			popover.permittedArrowDirections = [.left]
		}
		self.present(activityVC, animated: true)
	}

	func open(_ view: QuoteTableViewCell, quote: Quote) {
		self.navigationController?.pushViewController(QuoteViewController(quote: quote), animated: true)
	}
	
	// MARK: - Actions
    @objc
    func btnSettingsPressed() {
        let settingsVC = SettingsViewController()
        settingsVC.delegate = self
        let settingsNavVC = UINavigationController(rootViewController: settingsVC)

        present(settingsNavVC, animated: true, completion: nil)
    }
	
	func btnSearch_Click() {
		let searchController = ContentsSearchResultViewController.create(with: self)
		navigationController?.present(searchController, animated: true, completion: nil)
	}
	
	func btnBookmarks_Click() {
		if UIDevice.isIPad {
			if let viewControllers = splitViewController?.viewControllers, viewControllers.count > 1 {
				//Replace left (master) with bookmarks list
				if let masterNavVC = splitViewController?.viewControllers.first as? UINavigationController {
					masterNavVC.pushViewController(BookmarksViewController(delegate: self), animated: true)
				}
				
				//Open first bookmark, if any; otherwise keep current shloka
				let bookmarks = BookmarkModel.loadAll()
				if bookmarks.count > 0 {
					let firstBookmark = bookmarks[0]
					//NOTE: use this method instead of display shloka to pass order instead of index
					openShloka(from: self, chapterOrder: firstBookmark.chapterOrder, shlokaOrder: firstBookmark.shlokaOrder, backBarButtonTitle: Local("Shloka.BackButton.Title.Bookmarks"))
				}
			}
		} else {
			//Show bookmarks list on the whole screen
			navigationController?.pushViewController(BookmarksViewController(delegate: self), animated: true)
		}
	}
	
	// MARK: - Methods
    func loadData() {
		chapterEntries = ContentsEntryModel.getContents()
		tableView.reloadData()
		
		if chapterEntries.count > 0 {
			if UIDevice.isIPad {
				let selectedShloka = Settings.shared.selectedShloka
				
				displayShloka(chapterIndex: selectedShloka.chapterIndex, shlokaIndex: selectedShloka.shlokaIndex, navigation: true, backBarButtonTitle: nil, delegate: shlokaDelegate())
			}
			
			if showingSection != selectedShloka.chapterIndex {
				showHideShlokas(section: selectedShloka.chapterIndex)
			}
		}
		
		GitaRequestManager.getQuote(success: { (quote) in
			if let quote = quote, !String.isNilOrWhiteSpace(quote.text) {
				self.quote = quote
				self.tableView.reloadData()
			}
		}) { (err) in
			print(err)
		}
	}
	
	func openShloka(from controller: UIViewController, chapterOrder: Int, shlokaOrder: Int, backBarButtonTitle: String) {
		if let chapterIndex = chapterEntries.index(where: { $0.chapterOrder == chapterOrder }),
			let shlokaIndex = chapterEntries[chapterIndex].shlokas.index(where: { $0.order == shlokaOrder }) {
			
			let navStackCount = controller.navigationController?.viewControllers.count ?? 0
			let parentController = navStackCount > 1 ? controller.navigationController?.viewControllers[navStackCount - 1] : nil
			displayShloka(chapterIndex: chapterIndex, shlokaIndex: shlokaIndex, navigation: true, backBarButtonTitle: backBarButtonTitle, delegate: parentController != nil ? parentController as? ShlokaDelegate : self)
		}
	}
	
	//NOTE: if delegate is nil, keep the same delegate for shloka that was
	func displayShloka(chapterIndex: Int, shlokaIndex: Int, navigation: Bool, backBarButtonTitle: String?, delegate: ShlokaDelegate? = nil, audioMode: ShlokaViewController.AudioMode = .`default`) {
		
		selectedShloka = (chapterIndex: chapterIndex, shlokaIndex: shlokaIndex)
		
		//Store last displayed shloka (to refresh screen when went foreground after played next shloka in background)
		if UIApplication.shared.applicationState == .active {
			lastDisplayedShloka = (chapterIndex: chapterIndex, shlokaIndex: shlokaIndex)
		}
		
        // Select current shloka at ContentsVC
		let absoluteSection = selectedShloka.chapterIndex + (hasQuote ? 1 : 0)
        if let shlokaCell = tableView.cellForRow(at: IndexPath(row: 0, section: absoluteSection)) as? ShlokasChapterContentsTableViewCell {
            shlokaCell.setSelection(shlokaNumber: selectedShloka.shlokaIndex)
        }
        
        let selectedChapter = chapterEntries[chapterIndex]
        let shlokaOrder = selectedChapter.shlokas[shlokaIndex].order
		
		let shlokaModel = ShlokaModel.get(chapterOrder: selectedChapter.chapterOrder, shlokaOrder: shlokaOrder, bookId: Settings.shared.defaultBookId, languageIds: Settings.shared.selectedlanguagesIDs)

		let shlokaVC = ShlokaViewController(shlokaModel!, audioMode: audioMode, backButtonTitle: backBarButtonTitle, delegate: delegate)
		
        if navigation {
			shlokaVC.previousIsEnabled = !(chapterIndex == 0 && shlokaIndex == 0)
			
			shlokaVC.nextIsEnabled = !(chapterIndex == chapterEntries.count - 1 && shlokaIndex == (chapterEntries.last?.shlokas.count)! - 1)
		} else {
            shlokaVC.nextIsEnabled = false
            shlokaVC.previousIsEnabled = false
        }
		
        if UIDevice.isIPad {
            // Show another chapter on iPad SplitVC
            if showingSection != chapterIndex {
                showHideShlokas(section: chapterIndex)
            }
            
            if let viewControllers = splitViewController?.viewControllers, viewControllers.count > 1 {
                if let detailNavVC = splitViewController?.viewControllers.last as? UINavigationController {
                    detailNavVC.viewControllers = [shlokaVC]
                }
            }
        } else {
            if let viewControllers = navigationController?.viewControllers, viewControllers.last is ShlokaViewController {
				navigationController?.viewControllers[(navigationController?.viewControllers.count)! - 1] = shlokaVC
             } else {
                navigationController?.pushViewController(shlokaVC, animated: true)
            }
        }
	}
	
	private func getCurrentShlokaVC() -> ShlokaViewController? {
		//iPhone
		if let shlokaVC = self.navigationController?.topViewController as? ShlokaViewController {
			return shlokaVC
		}
		//iPad
		else if let viewControllers = splitViewController?.viewControllers, viewControllers.count > 1,
			let rightNavVC = splitViewController?.viewControllers.last as? UINavigationController,
			let shlokaVC = rightNavVC.topViewController as? ShlokaViewController {
			
			return shlokaVC
		}

		return nil
	}
	
	//Controller that opens shlokas
	func shlokaDelegate() -> ShlokaDelegate {
		var mainNavVC: UINavigationController? = nil
		
		if UIDevice.isIPad {
			if let viewControllers = splitViewController?.viewControllers, viewControllers.count > 1 {
				mainNavVC = splitViewController?.viewControllers.first as? UINavigationController			}
		} else {
			mainNavVC = self.navigationController
		}
		
		let navStackCount = mainNavVC?.viewControllers.count ?? 0
		let parentController = navStackCount > 1 ? mainNavVC?.viewControllers[navStackCount - 1] : nil
		return parentController as? ShlokaDelegate ?? self
	}
	
    func showHideShlokas(section: Int) {
		//Toggle chapter header and toggle new opened section
		//If chapter is opened
		let prevShowingSection = showingSection
		
        if let openedChapter = showingSection {
			animateHeader(section: hasQuote ? openedChapter + 1 : openedChapter)
            showingSection = nil
			
			//If new section is different from old, open new selected chapter
            if openedChapter != section {
                showingSection = section
                animateHeader(section: hasQuote ? section + 1 : section)
            }
        } else {
			//All sections are closed
			//Store new selected section
            showingSection = section
			//Expand new opened section header with animation
            animateHeader(section: hasQuote ? section + 1 : section)
        }
		
		//Collapse/expand chapter contents
		let absoluteSection = section + (hasQuote ? 1 : 0)
	
		var pathsToReload = [IndexPath(row: 0, section: absoluteSection)]
		if let prevShowingSection = prevShowingSection {
			pathsToReload.append(IndexPath(row: 0, section: prevShowingSection))
		}
		tableView.reloadRows(at: pathsToReload, with: .none)
		
		//If new chapter is expanded, scroll to its top
		if showingSection != nil {
			//Let active section reload before scroll
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				let sectionToScroll = absoluteSection == 1 ? 0 : absoluteSection
				self.tableView.scrollToRow(at: IndexPath(row: 0, section: sectionToScroll), at: .top, animated: true)
			}
		}
    }

	//Toggle disclosure with animation
    func animateHeader(section: Int) {
        if let headerView = tableView.headerView(forSection: section) as? ChapterContentsHeaderView {
            headerView.animateDisclosure()
        }
    }
    
    func configureCell(_ shlokaCell: ShlokasChapterContentsTableViewCell, section: Int) {
        // If selected shloka is in showingChapter select this shloka in Cell
        var currentSelected: Int? = nil
		let chapterIndex = section
        if selectedShloka.chapterIndex == chapterIndex {
            currentSelected = selectedShloka.shlokaIndex
        }
        
        shlokaCell.fill(shlokas: chapterEntries[chapterIndex].shlokas, selectedShloka: currentSelected)
	}
    
    func setUpNavigationBar(isRed: Bool) {
		UIApplication.shared.statusBarStyle = isRed ? .lightContent : .default
		navigationController?.navigationBar.tintColor = isRed ? .white : .red1
		navigationController?.navigationBar.barTintColor = isRed ? .red1 : .white
		navigationController?.navigationBar.titleTextAttributes = [
			NSFontAttributeName: Style.navBarFont,
			NSForegroundColorAttributeName: isRed ? UIColor.white : UIColor.gray1
		]
		
		// Fixing troubles with PopVC on different iOS versions
		// This is inly for iOS versions less than 10.0
		if #available(iOS 10.0, *) {
		} else {
			let transition = CATransition()
			transition.duration = 0.25
			transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			transition.type = kCATransitionFade
			navigationController?.navigationBar.layer.add(transition, forKey: nil)
			UIView.animate(withDuration: 0.25) {[weak weakSelf = self] in
				weakSelf?.navigationController?.navigationBar.backgroundColor = isRed ? .red1 : .white
			}
		}
    }

	func updateBookmark(chapterOrder: Int, shlokaOrder: Int) {
		if chapterEntries.count > 0, let chapterIndex = chapterEntries.index(where: { $0.chapterOrder == chapterOrder }) {
			let chapter = chapterEntries[chapterIndex]
			
			if let index = chapter.shlokas.index(where: { $0.order == shlokaOrder}) {
				let bookmarked = chapter.shlokas[index].isBookmarked
				chapter.shlokas[index].isBookmarked = !bookmarked
				
				if let shlokaCell = tableView.cellForRow(at: IndexPath(row: 0, section: chapterIndex)) as? ShlokasChapterContentsTableViewCell {
					shlokaCell.setBookmark(shlokaOrder: shlokaOrder, bookmarked: !bookmarked)
				}
			}
		}
	}
}
