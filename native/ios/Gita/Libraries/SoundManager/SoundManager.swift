//
//  SoundManager.swift
//  Gita
//
//  Created by Olga Zhegulo  on 02/06/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import AVFoundation

final class SoundManager {
    
    static let shared = SoundManager(audioSessionCategory: AVAudioSessionCategoryPlayback)
	
	private var player: AVPlayer?
	
    var currentTime: Double {
        let currentTime = player?.currentTime() ?? CMTime()
//        return CMTimeGetSeconds(currentTime)
		let result = CMTimeGetSeconds(currentTime)
		if result < 0 {
			print("player == nil \(player == nil)")
		}
		return result
    }
    
    var isReadyToPlay: Bool {
        if let player = player, let currentItem = player.currentItem {
            return currentItem.status == .readyToPlay
        }
        return false
    }
    
    var isMuted: Bool {
        set {
            player?.isMuted = newValue
        }
        get {
            return player?.isMuted ?? false
        }
    }
    
	private init() {
		player = AVPlayer()
	}
    
    convenience init(audioSessionCategory: String?) {
        self.init()
        if let category = audioSessionCategory {
            do {
                try AVAudioSession.sharedInstance().setCategory(category)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Error during setting category: \(category)")
            }
        }
    }
    
	func play(url: URL) {
        
        if currentTime.isNaN {
            //Clear resources
            stop()
            
            //Play source
            player = AVPlayer(url: url)
            player?.volume = 1.0
        }
        
        player?.play()
	}
	
	func pause() {
		player?.pause()
	}
	
	func resume() {
		player?.play()
	}
	
	func stop() {
		player?.pause()
		player = nil
	}
	
    func seek(time: TimeInterval) {
		//Fix for seek in stream
		var currentAssetTimeScale: CMTimeScale = 1
		if let player = self.player, let currentItem = player.currentItem {
			currentAssetTimeScale = currentItem.asset.duration.timescale
		}
		
		let seekTime = CMTime(seconds: time, preferredTimescale: currentAssetTimeScale)
		player?.seek(to: seekTime)
    }
    
    /**
     Duration in seconds
    */
	static func duration(url: URL) -> Double {
		let audioAsset = AVURLAsset(url: url)
		let audioDuration: CMTime = audioAsset.duration
		return CMTimeGetSeconds(audioDuration)
	}
    
    static func playSystemSound(systemSoundID: SystemSoundID) {
        AudioServicesPlaySystemSoundWithCompletion(systemSoundID, nil)
    }

}
