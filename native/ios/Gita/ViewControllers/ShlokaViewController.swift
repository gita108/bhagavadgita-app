//
//  ShlokaViewController.swift
//  Gita
//
//  Created by mikhail.kulichkov on 25/04/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

//protocol ShlokaViewControllerDelegate {
//	func shlokaViewControllerBookmarkToggled(_ shlokaVC: ShlokaViewController)
//	func shlokaViewControllerDidSelectNext(_ shlokaVC: ShlokaViewController)
//	func shlokaViewControllerDidSelectPrevious(_ shlokaVC: ShlokaViewController)
//}

final class ShlokaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShlokaHeaderTableViewCellDelegate, ShlokaPlayerViewDelegate, CommentViewControllerDelegate, UIGestureRecognizerDelegate {
	
	public enum AudioMode: Int {
		case `default` = 0
		case start
		case `continue`
	}
	
    private var shlokaModel: ShlokaModel!

	var chapterNumber: Int = 1
    var shlokaNumber: Int = 0
	
    private var moreInterpretationsHidden = true
    var nextIsEnabled = true
    var previousIsEnabled = true
    var backBarButtonTitle: String?
	
	private(set) var audioMode: AudioMode = .`default`
	
	//Stop player if not switching to next audio automatically
	var stopAudioOnDisappear = true
	
	private var commented: Bool { return !String.isNilOrWhiteSpace(shlokaModel.userComment) }
	var bookmarked: Bool {
		get { return shlokaModel.isBookmarked }
		set {
			shlokaModel.isBookmarked = newValue
			configureBookmarkButton()
		}
	}
	
    var delegate: ShlokaDelegate?
	
    private let tableView = UITableView()
    private var shlokaPlayerView = ShlokaPlayerView()
	//Fill bottom for iPhoneX. Same color as player
	private var vPlayerContainer = UIView().background(.gray5)
	
	private var cPlayerContainerHeight: NSLayoutConstraint!
	private var cPlayerBottom: NSLayoutConstraint!

	//MARK: - initialization
	init(_ model: ShlokaModel, audioMode: AudioMode, backButtonTitle: String?, delegate: ShlokaDelegate?) {
		self.shlokaModel = model
		self.shlokaNumber = model.shlokaOrder
		self.chapterNumber = model.chapterOrder
		
		self.audioMode = audioMode
		self.backBarButtonTitle = backButtonTitle
		
		self.delegate = delegate
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		self.view = UIView()
		
        view.backgroundColor = .white
		
		view.addSubview(tableView)
		view.addSubview(vPlayerContainer)
		vPlayerContainer.addSubview(shlokaPlayerView)
		
		ShlokaHeaderTableViewCell.register(for: tableView)
		ShlokaSeparatorTableViewCell.register(for: tableView)
		ShlokaSanskritTableViewCell.register(for: tableView)
		ShlokaTranscriptionTableViewCell.register(for: tableView)
		ShlokaWordsTableViewCell.register(for: tableView)
		ShlokaTranslationTableViewCell.register(for: tableView)
		ShlokaInterpretationTableViewCell.register(for: tableView)
		
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
		
		cPlayerContainerHeight = (vPlayerContainer.heightItem == 0.0)
		
        cPlayerBottom = (shlokaPlayerView.bottomItem == vPlayerContainer.bottomItem ~ 750)
		activateConstraints(
			tableView.dockTop(),
			vPlayerContainer.pinTop(to: tableView).leading().trailing().bottom(),
			
			shlokaPlayerView.dockTop().height(57),
			[cPlayerBottom],
			[cPlayerContainerHeight]
		)
		
		addSwipe()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//Navigation items
        let btnComment = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(btnCommentPressed))
        let btnBookmark = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(btnBookmarkPressed))
        
        navigationItem.setRightBarButtonItems([btnBookmark, btnComment], animated: false)

		//Changes player and nav bar buttons
		loadShloka()
    }
    
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		//Setup player & bottom of player depending by audio presence
		var playerPadding: CGFloat = 0.0

		if #available(iOS 11.0, *) {
			playerPadding = self.view.safeAreaInsets.bottom
		} else {
		}
		
		let hasAudio = (Settings.shared.useSanskritAudio || Settings.shared.useTranslationAudio) &&
			shlokaModel.hasDownloadedAudio(isSanskrit: Settings.shared.useSanskritAudio)
		cPlayerContainerHeight.constant = hasAudio ? 57.0 + playerPadding : 0.0
		cPlayerBottom.constant = hasAudio ? playerPadding : 0.0
	}

	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UIDevice.isIPad {
            setBackButton(title: backBarButtonTitle ?? "")
        }
		
		GAHelper.logScreen("Shloka \(shlokaModel.name)")
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if (Settings.shared.useTranslationAudio || Settings.shared.useSanskritAudio) &&
			shlokaModel.hasDownloadedAudio(isSanskrit: Settings.shared.useSanskritAudio) {
			if audioMode == .start {
				self.shlokaPlayerView.play()
			} else if audioMode == .`continue` {
				self.shlokaPlayerView.continuePlaying()
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		//Audio is playing only at shloka screen
		if stopAudioOnDisappear {
			stopPlayer()
		}
	}
	
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = view.bounds.width
        switch indexPath.section {
        case 0:
            return ShlokaHeaderTableViewCell.height(title: shlokaModel.title, width: width)
        case 1, 4, 7:
            return ShlokaSeparatorTableViewCell.height()
        case 2:
            return ShlokaSanskritTableViewCell.height(text: shlokaModel.originalText, width: width)
        case 3:
            return ShlokaTranscriptionTableViewCell.height(transcription: shlokaModel.transcription, width: width)
        case 5:
            return ShlokaWordsTableViewCell.height(words: shlokaModel.dictionary, width: width)
        case 6:
            let translation = shlokaModel.translations[indexPath.row].text
            return ShlokaTranslationTableViewCell.height(translation: translation, width: width)
        case 8:
			if let mainInterpretation = shlokaModel.interpretations.first {
				return ShlokaInterpretationTableViewCell.height(title: mainInterpretation.title, interpretation: mainInterpretation.text, width: view.bounds.width)
			}
            return 0.0
        case 9:
            let interpretation = shlokaModel.interpretations[indexPath.row + 1]
            return ShlokaInterpretationTableViewCell.height(title: interpretation.title, interpretation: interpretation.text, width: view.bounds.width)
        case 10:
            return 60.0
        default:
            return 0.0
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return (Settings.shared.showSanskrit || Settings.shared.showTranscription) ? 1 : 0
        case 2:
            return Settings.shared.showSanskrit ? 1 : 0
        case 3:
            return Settings.shared.showTranscription ? 1 : 0
        case 4, 5:
            if Settings.shared.showVocabulary {
                return shlokaModel.dictionary.count > 0 ? 1 : 0
            }
            return 0
        case 6:
            return shlokaModel.translations.count
        case 7, 8:
            return Settings.shared.showComments && shlokaModel.interpretations.count > 0 ? 1 : 0
        case 9:
            if !Settings.shared.showComments {
				return 0
			}
            return moreInterpretationsHidden ? 0 : shlokaModel.interpretations.count - 1
        case 10:
            if !Settings.shared.showComments { return 0 }
            // Hide cell with button if there's no additional interpretations
            return shlokaModel.interpretations.count > 1 ? 1 : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Header with title
			
			let shlokaHeaderCell: ShlokaHeaderTableViewCell = tableView.dequeue(for: indexPath)
			shlokaHeaderCell.fill(
				number: shlokaModel.name,
				title: shlokaModel.title,
				delegate: self,
				previousIsEnabled: previousIsEnabled,
				nextIsEnabled: nextIsEnabled)
            
            return shlokaHeaderCell
        case 1, 4, 7:
            // Separator
            let shlokaSeparatorCell: ShlokaSeparatorTableViewCell = tableView.dequeue(for: indexPath)
            return shlokaSeparatorCell
        case 2:
            // Sanskrit
			let shlokaSanskritCell: ShlokaSanskritTableViewCell = tableView.dequeue(for: indexPath)
			shlokaSanskritCell.fill(text: shlokaModel.originalText)
            return shlokaSanskritCell
        case 3:
            // Transcription
			let shlokaTranscriptionCell: ShlokaTranscriptionTableViewCell = tableView.dequeue(for: indexPath)
			shlokaTranscriptionCell.fill(transcription: shlokaModel.transcription)
            return shlokaTranscriptionCell
        case 5:
            // Dictionary
			let shlokaWordsCell: ShlokaWordsTableViewCell = tableView.dequeue(for: indexPath)
			shlokaWordsCell.fill(words: shlokaModel.dictionary)
            return shlokaWordsCell
        case 6:
            // Translations
            let shlokaTranslationCell: ShlokaTranslationTableViewCell = tableView.dequeue(for: indexPath)
            let translation = shlokaModel.translations[indexPath.row]
            shlokaTranslationCell.fill(language: translation.lang, translation: translation.text)
            return shlokaTranslationCell
        case 8:
            // Main interpretation
            let shlokaInterpretationCell: ShlokaInterpretationTableViewCell = tableView.dequeue(for: indexPath)
            if let mainInterpretation = shlokaModel.interpretations.first {
                shlokaInterpretationCell.fill(title: mainInterpretation.title, author: mainInterpretation.code, interpretation: mainInterpretation.text)
            }
            return shlokaInterpretationCell
        case 9:
            // Other interpretations
            let shlokaInterpretationCell: ShlokaInterpretationTableViewCell = tableView.dequeue(for: indexPath)
            let interpretation = shlokaModel.interpretations[indexPath.row + 1]
            shlokaInterpretationCell.fill(title: interpretation.title, author: interpretation.code, interpretation: interpretation.text)
            return shlokaInterpretationCell
        case 10:
            // Show/hide button
            
            // Getting title for interpretations quantity
            let localizedInterpretationsNumberFormatString = Local("Shloka.ShowButton.Interpretation.Quantity")
            let interpretationsString = String.localizedStringWithFormat(localizedInterpretationsNumberFormatString, self.shlokaModel.interpretations.count - 1)
            
            let showHideButtonTitle = moreInterpretationsHidden ? interpretationsString : Local("Shloka.HideButton.Title")
            let shlokaShowHideButton = ShlokaShowHideButtonTableViewCell(title: showHideButtonTitle) {[unowned self] in
                self.moreInterpretationsHidden = !self.moreInterpretationsHidden
                self.tableView.reloadSections(IndexSet(integer: 9), with: .automatic)
                
                if let buttonCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 10)) as? ShlokaShowHideButtonTableViewCell {
                    buttonCell.setButtonTitle(self.moreInterpretationsHidden ? interpretationsString : Local("Shloka.HideButton.Title"))
                }
            }
            return shlokaShowHideButton
        default:
            return UITableViewCell()
        }
    }
	
	//MARK: - ShlokaHeaderTableViewCellDelegate
	
	func didSelectNextShloka(_ cell: ShlokaHeaderTableViewCell) {
		self.delegate?.shlokaViewControllerDidSelectNext(self)
	}
	
	func didSelectPreviousShloka(_ cell: ShlokaHeaderTableViewCell) {
		self.delegate?.shlokaViewControllerDidSelectPrevious(self)
	}
	
    //MARK: - ShlokaPlayerViewDelegate
   
    func backPressed(shlokaPlayerView: ShlokaPlayerView) {
        print("Rewind was pressed on player")
    }
    
    func forwardPressed(shlokaPlayerView: ShlokaPlayerView) {
        print("Fast forward was pressed on player")
    }
	
	func didCompletedTrack(shlokaPlayerView: ShlokaPlayerView) {
		self.delegate?.didCompletedTrack(self)
	}
	
	//MARK: CommentViewControllerDelegate
	func didChangedComment(controller: CommentViewController, comment: String) {
		//Update dataitem
		shlokaModel.userComment = comment
		
		//Update interface
		configureCommentButton()
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
    // MARK: - Actions
	@objc private func btnBack_Click() {
		_ = self.navigationController?.popViewController(animated: true)
	}

    @objc private func btnCommentPressed() {
		let vc = CommentViewController(comment: shlokaModel.userComment, delegate: self, chapterOrder: shlokaModel.chapterOrder, shlokaOrder: shlokaModel.shlokaOrder)
		self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func btnBookmarkPressed() {
		//Update dataitem
        shlokaModel.isBookmarked = !shlokaModel.isBookmarked
		
		GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryUI, action: bookmarked ? "Added bookmark" : "Removed bookmark")
		
		//Update DB
        Bookmark.updateBookmarked(chapterOrder: chapterNumber, shlokaOrder: shlokaNumber, bookmarked: bookmarked)
		
		//Update interface
		configureBookmarkButton()

		//Inform delegate
		delegate?.toggledBookmark(from: self, chapterOrder: chapterNumber, shlokaOrder: shlokaNumber, bookmarked: shlokaModel.isBookmarked)
    }
    
    func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
	
	func handleSwipe(recognizer:UISwipeGestureRecognizer) {
		switch recognizer.direction {
			
		case UISwipeGestureRecognizerDirection.right:
			self.delegate?.shlokaViewControllerDidSelectPrevious(self)
			break
		case UISwipeGestureRecognizerDirection.left:
			self.delegate?.shlokaViewControllerDidSelectNext(self)
			break
		default:
			break
		}
	}
	
    // MARK: - Helpers
    
	func addSwipe() {
		let directions: [UISwipeGestureRecognizerDirection] = [.right, .left]
		for direction in directions {
			let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
			gesture.direction = direction
			view.addGestureRecognizer(gesture)
		}		
	}
	
    func loadShloka() {
		
		if audioMode == .`default` {
			//Reset previous page audio
			SoundManager.shared.stop()
		}
		
 		configureBookmarkButton()
		configureCommentButton()

		//NOTE: audio is hidden if both translarion and sanskrit audio are turned off in settings
		let hasAudio = (Settings.shared.useSanskritAudio || Settings.shared.useTranslationAudio) &&
			shlokaModel.hasDownloadedAudio(isSanskrit: Settings.shared.useSanskritAudio)
		
		shlokaPlayerView.isHidden = !hasAudio
		shlokaPlayerView.delegate = hasAudio ? self : nil
		
		if hasAudio {
			shlokaPlayerView.name = "\(shlokaModel.name). \(shlokaModel.title)"
			shlokaPlayerView.url = URL(fileURLWithPath: shlokaModel.audioPath(isSanskrit: Settings.shared.useSanskritAudio))
		} else {
			shlokaPlayerView.url = nil
		}
    }
    
    func configureCommentButton() {
        let btnComment = navigationItem.rightBarButtonItems?.last
        var imageName: String
        if commented {
            imageName = UIDevice.isIPad ? "ic_commented_white" : "ic_commented"
        } else {
            imageName = "ic_comment"
        }
		
        btnComment?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
    }
    
    func configureBookmarkButton() {
        let btnBookmark = navigationItem.rightBarButtonItems?.first
        var imageName: String
        if bookmarked {
            imageName = UIDevice.isIPad ? "ic_bookmarked_white" : "ic_bookmarked"
        } else {
            imageName = "ic_bookmark"
        }
        
        btnBookmark?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
    }
    
    private func setBackButton(title: String) {
		let backItemTitleAttributes = [
            NSForegroundColorAttributeName: UIColor.red1,
            NSFontAttributeName: UIFont(type: .regular, size: 16.0)
        ]
        
        let backButtonTitle = NSAttributedString(string: title, attributes: backItemTitleAttributes)
        let backButtonImage = UIImage(named:"ic_back") ?? UIImage()
        let backButtonTitleSize = Style.size(for: backButtonTitle, font: UIFont(type: .regular, size: 16.0), width: CGFloat.greatestFiniteMagnitude, height: 30.0)
        
        let backButtonTitleLeftPadding: CGFloat = 19.0
        let backButtonWidth = backButtonImage.size.width + (ceil(backButtonTitleSize.width) - backButtonImage.size.width) + backButtonTitleLeftPadding
        let backButtonContainer = UIView(frame: CGRect(x: 0.0, y: 0.0, width: backButtonWidth, height: 30.0))
        
        // Create back button image
        let backButtonImageView = UIImageView(frame: CGRect(x: 0.0, y: 5.5, width: backButtonImage.size.width, height: backButtonImage.size.height))
        backButtonImageView.image = backButtonImage
        backButtonContainer.addSubview(backButtonImageView)
        
        // Create back button title
        let label = UILabel(frame: CGRect(x: backButtonTitleLeftPadding, y: backButtonImage.size.height + 5.5 - ceil(backButtonTitleSize.height), width: ceil(backButtonTitleSize.width), height: ceil(backButtonTitleSize.height)))
        label.attributedText = backButtonTitle
        backButtonContainer.addSubview(label)
        
        // Create snapshot of back button
        UIGraphicsBeginImageContextWithOptions(backButtonContainer.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            backButtonContainer.layer.render(in: context)
        }
        let backButtonSnapshot: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        let backItem = UIBarButtonItem(image: backButtonSnapshot, landscapeImagePhone: backButtonSnapshot, style: .plain, target: self, action: #selector(backButtonPressed))
        backItem.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: -22.0)
		
        navigationItem.hidesBackButton = true
        navigationItem.backBarButtonItem = nil
        navigationItem.leftBarButtonItem = backItem
    }
	
	func stopPlayer() {
		shlokaPlayerView.stop()
	}
}

