//
//  ShlokaPlayerView.swift
//  Gita
//
//  Created by mikhail.kulichkov on 24/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

protocol ShlokaPlayerViewDelegate {
	func didCompletedTrack(shlokaPlayerView: ShlokaPlayerView)
}

final class ShlokaPlayerView: UIView {
	
	var name: String {
		didSet {
			lblTitle.text = name
		}
	}

	var url: URL? {
		didSet {
			if let url = url {
				duration = SoundManager.duration(url: url)
			} else {
				duration = 0
			}
		}
	}
	
	var delegate: ShlokaPlayerViewDelegate?
	
	private var duration: Float64 = 0.0
	private var currentTime: TimeInterval = 0.0

	private(set) var isPlaying: Bool = false
	
	private var timer: Timer?
	
	//Variable to check end of music: when does not changed, track is finished
	private var lastMusicTime: TimeInterval = 0

	private var cProgressWidth: NSLayoutConstraint?
	
    private let lblTitle: UILabel = {
        let lblTitle = UILabel()
        
        lblTitle.font = UIFont(type: .bold, size: 16.0)
        lblTitle.textColor = .gray1
        lblTitle.textAlignment = .left
        
        return lblTitle
    }()
    
    private lazy var btnPlay: UIButton = {
		let btnPlay = UIButton(type: .custom)
        let image = UIImage(named: "ic_audio_play")
        btnPlay.setImage(image, for: .normal)
		
		btnPlay.addTarget(self, action: #selector(btnPlay_Click), for: .touchUpInside)

		return btnPlay
    }()
    
    private lazy var btnPause: UIButton = {
        let btnPause = UIButton(type: .custom)
        let image = UIImage(named: "ic_audio_pause")
        btnPause.setImage(image, for: .normal)
		
		btnPause.addTarget(self, action: #selector(btnPause_Click), for: .touchUpInside)

		return btnPause
    }()

	private let vProgressBackground = UIView().background(.gray4)

	private let vProgress = UIView().background(.red1)
	
	init(name: String, url: URL?) {
		self.name = name
		self.url = url
		
        super.init(frame: .zero)
        
        backgroundColor = .gray5
		
		addSubviews(lblTitle)
		lblTitle.text = name
		
		let playerContainer = UIView()
		playerContainer.backgroundColor = .clear
		
		addSubview(playerContainer)
		playerContainer.addSubviews(btnPlay, btnPause)
		
		//Make 16px from play icon edge space 
		btnPlay.imageEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 0)
		//Because pause image is 2px less
		btnPause.imageEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0)
		
        btnPlay.isHidden = false
		btnPause.isHidden = true
		
		addSubview(vProgressBackground)
		addSubview(vProgress)
		
		cProgressWidth = (vProgress.widthItem == 0.0)
		
		let cProgressVerticalPosition = UIDevice.deviceName == .iPhoneX ?
			vProgress.topItem == topItem :
			vProgress.bottomItem == bottomItem
		
        activateConstraints(
			lblTitle.leadingItem == leadingItem + 16.0,
			lblTitle.centerYItem == centerYItem,
			lblTitle.trailingItem == playerContainer.leadingItem,

			playerContainer.topItem == topItem,
			playerContainer.bottomItem == bottomItem,
			playerContainer.trailingItem == trailingItem,
			playerContainer.widthItem == 53.0,
			
			btnPlay.topItem == playerContainer.topItem,
			btnPlay.bottomItem == playerContainer.bottomItem,
			btnPlay.leadingItem == playerContainer.leadingItem,
            btnPlay.trailingItem == playerContainer.trailingItem,
            
            btnPause.topItem == playerContainer.topItem,
            btnPause.bottomItem == playerContainer.bottomItem,
            btnPause.leadingItem == playerContainer.leadingItem,
            btnPause.trailingItem == playerContainer.trailingItem,

            vProgress.heightItem == 2.0,
            vProgress.leadingItem == leadingItem,
            cProgressWidth!,
            cProgressVerticalPosition,
			
			vProgressBackground.heightItem == 2.0,
			vProgressBackground.leadingItem == leadingItem,
			vProgressBackground.trailingItem == trailingItem,
			vProgressBackground.topItem == vProgress.topItem
        )
    }
	
	convenience init() {
		self.init(name: String(), url: nil)
	}
	
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
    // MARK: - Actions:
	func btnPlay_Click(sender: UIButton) {
		self.play()
    }

    func btnPause_Click(sender: UIButton) {
		self.pause()
	}
	
	@objc func timer_Tick(_ sender: Timer) {
		
		let currentTime = SoundManager.shared.currentTime
		
		if !currentTime.isNaN {
			let previousMusicTime = self.lastMusicTime
			self.lastMusicTime = currentTime
			
			//Show player progress
			let currentPoint = duration > 0 ? currentTime / duration : 0.0
			setProgressValue(CGFloat(currentPoint))
			
			//Check if music finished: music started && music time not changed (because player time at the end of track could be less than music duration)
			if currentTime > Double.ulpOfOne && abs(currentTime - previousMusicTime) <= Double.ulpOfOne {
				self.soundManagerDidCompletedTrack()
			}
		}
	}
	
    // MARK: - Methods
	func updateIsPlaying(_ isPlaying: Bool) {
		self.isPlaying = isPlaying
		
        btnPlay.isHidden = isPlaying
        btnPause.isHidden = !isPlaying
		
		if isPlaying {
			if timer != nil {
				timer?.invalidate()
			}
			
			currentTime = SoundManager.shared.currentTime
			lastMusicTime = 0.0
			
			if currentTime > 0 {
				//Show player progress
				let currentPoint = duration > 0 ? currentTime / duration : 0.0
				setProgressValue(CGFloat(currentPoint))
			}

			self.timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.timer_Tick), userInfo: nil, repeats: true)
		} else {
			timer?.invalidate()
			timer = nil
		}
    }
	
	func setProgressValue(_ value: CGFloat) {
//		print("progress: \(value)")
		cProgressWidth?.constant = self.frame.size.width * max(value, 0)
	}
	
	func stop() {
		if isPlaying {
			SoundManager.shared.stop()
		}
		
		currentTime = 0.0
		
		updateIsPlaying(false)
	}
	
	func play() {
		
		guard let url = url else {
			return
		}
		
		GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryUI, action: "Play audio")
		
		//Set delegate if begin to play
		if currentTime == 0.0 {
			SoundManager.shared.play(url: url)
		} else {
			SoundManager.shared.resume()
		}
		
		updateIsPlaying(true)
	}
	
	func pause() {
		GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryUI, action: "Pause audio")
		
		if isPlaying {
			currentTime = SoundManager.shared.currentTime
			SoundManager.shared.pause()
		}
		
		updateIsPlaying(false)
	}
	
	//Initialize play button & timer and let Sound Manager continue to play
	func continuePlaying() {
		updateIsPlaying(true)
	}
	
	func soundManagerDidCompletedTrack() {
		GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryUI, action: "Completed playing audio")
		
		//Reset current time & remove old player
		SoundManager.shared.stop()
		
		//Stop timer and show play button
		updateIsPlaying(false)
		
		//Reset time
		currentTime = 0.0
		
		//Reset progress
		setProgressValue(0.0)
		
		//Go next shloka
		self.delegate?.didCompletedTrack(shlokaPlayerView: self)
	}
}
