//
//  AudioManager.swift
//  Gita
//
//  Created by Olga Zhegulo  on 16/05/2018.
//  Copyright © 2018 Iron Water Studio. All rights reserved.
//

import UIKit

protocol AudioManagerDelegate: class {
	func audioManagerDidCompletedTrack()
}

final class AudioManager {
	static let shared = AudioManager()
	
	weak var delegate: AudioManagerDelegate?
	
	private var soundManager = SoundManager.shared
	
	private var duration: Float64 = 0.0
	private var currentTime: TimeInterval = 0.0
	
	private(set) var isPlaying: Bool = false
	
	private var timer: Timer?
	
	//Variable to check end of music: when does not changed, track is finished
	private var lastMusicTime: TimeInterval = 0

	//didCompletedTrack
	//play (chapter, shloka)

	//	func play(url: URL?) {
	func play(filePath: String) {
		GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryUI, action: "Play audio")
		
		isPlaying = true
		
		//Start progress && detect track end
		self.lastMusicTime = 0
		timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timer_UpdatePlayerTime), userInfo: nil, repeats: true)
		timer!.fire()

//		if currentTime == 0.0 {
			soundManager.play(url: NSURL.fileURL(withPath: filePath))
//		} else {
//			soundManager.resume()
//		}

		/* //TODO: when play stream
		if let url = url {
			self.isPlaying = true
			
			//Start progress
			self.lastMusicTime = 0
			timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timer_UpdatePlayerTime), userInfo: nil, repeats: true)
			timer!.fire()
		
			//Play sound
			if soundManager.currentTime.isNaN {
				soundManager.play(url: url)
			} else {
				soundManager.resume()
			}
		}
		*/
	}
	
	func removeTimer() {
		self.delegate = nil
		timer?.invalidate()
		timer = nil
	}
	
	@objc
	private func timer_UpdatePlayerTime(_ sender: Any) {
		updatePlayerTime(soundManager.currentTime)
	}
	
	private func updatePlayerTime(_ currentTime: TimeInterval) {
		let previousMusicTime = self.lastMusicTime
		self.lastMusicTime = currentTime
		
//		print("background audio: \(currentTime)")
		
		//Check if music finished: music started && music time not changed (because player time at the end of track could be less than music duration)
		if currentTime > Double.ulpOfOne && abs(currentTime - previousMusicTime) <= Double.ulpOfOne {
			didCompletedTrack()
		}
	}

	func didCompletedTrack() {
		GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryUI, action: "Completed playing audio")
		
		//Reset current time & remove old player
		soundManager.stop()
		
		self.isPlaying = false
		
		timer?.invalidate()
		timer = nil

		//Reset time
		currentTime = 0.0
		
		//Go next shloka
		self.delegate?.audioManagerDidCompletedTrack()
	}
}
