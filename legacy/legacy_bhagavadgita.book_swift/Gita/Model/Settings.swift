//
//  Settings.swift
//  Gita
//
//  Created by mikhail.kulichkov on 29/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

class Settings {
        
	private let kDataInitialized = "DataInitialized"
	private let kHasDisplayedGuide = "HasDisplayedGuide"

	private let kShowSanskritSetting = "ShowSanskritSetting"
    private let kShowTranscriptionSetting = "ShowTranscriptionSetting"
    private let kShowVocabularySetting = "ShowVocabularySetting"
    private let kShowCommentsSetting = "ShowCommentsSetting"
	
	private let kUseTranslationAudioSetting = "UseTranslationAudio"
	private let kUseSanskritAudioSetting = "UseSanskritAudio"
	private let kAutoPlayAudioSetting = "AutoPlayAudio"

    private let kSelectedShlokaIndex = "SelectedShlokaIndex"
    private let kSelectedChapterIndex = "SelectedChapterIndex"
    
	private let kDefaultBookId = "DefaultBookId"

	static let shared = Settings()
    
    required init() {}
    
    required init(_ settings: Settings) {
        dataInitialized = settings.dataInitialized
        showSanskrit = settings.showSanskrit
        showTranscription = settings.showTranscription
        showVocabulary = settings.showVocabulary
        showComments = settings.showComments
		useTranslationAudio = settings.useTranslationAudio
		useSanskritAudio = settings.useSanskritAudio
		autoPlayAudio = settings.autoPlayAudio
    }
    
	var dataInitialized: Bool {
		get {
			return UserDefaults.standard.bool(forKey: kDataInitialized)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: kDataInitialized)
		}
	}
	
	var hasDisplayedGuide: Bool {
		get {
			return UserDefaults.standard.bool(forKey: kHasDisplayedGuide)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: kHasDisplayedGuide)
		}
	}

	var showSanskrit: Bool {
        get {
            if UserDefaults.standard.object(forKey: kShowSanskritSetting) == nil {
                self.showSanskrit = true
            }
            return UserDefaults.standard.bool(forKey: kShowSanskritSetting)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kShowSanskritSetting)
        }
    }
    
    var showTranscription: Bool {
        get {
            if UserDefaults.standard.object(forKey: kShowTranscriptionSetting) == nil {
                self.showTranscription = true
            }
            return UserDefaults.standard.bool(forKey: kShowTranscriptionSetting)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kShowTranscriptionSetting)
        }
    }
    
    var showVocabulary: Bool {
        get {
            if UserDefaults.standard.object(forKey: kShowVocabularySetting) == nil {
                self.showVocabulary = true
            }
            return UserDefaults.standard.bool(forKey: kShowVocabularySetting)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kShowVocabularySetting)
        }
    }
    
    var showComments: Bool {
        get {
            if UserDefaults.standard.object(forKey: kShowCommentsSetting) == nil {
                self.showComments = true
            }
            return UserDefaults.standard.bool(forKey: kShowCommentsSetting)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kShowCommentsSetting)
        }
    }
    
	var useTranslationAudio: Bool {
		get {
			if UserDefaults.standard.object(forKey: kUseTranslationAudioSetting) == nil {
				self.useTranslationAudio = true
			}
			return UserDefaults.standard.bool(forKey: kUseTranslationAudioSetting)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: kUseTranslationAudioSetting)
		}
	}
	
	var useSanskritAudio: Bool {
		get {
			if UserDefaults.standard.object(forKey: kUseSanskritAudioSetting) == nil {
				self.useSanskritAudio = false
			}
			return UserDefaults.standard.bool(forKey: kUseSanskritAudioSetting)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: kUseSanskritAudioSetting)
		}
	}
	
	var autoPlayAudio: Bool {
		get {
			if UserDefaults.standard.object(forKey: kAutoPlayAudioSetting) == nil {
				self.autoPlayAudio = false
			}
			return UserDefaults.standard.bool(forKey: kAutoPlayAudioSetting)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: kAutoPlayAudioSetting)
		}
	}

	var selectedShloka: (chapterIndex: Int, shlokaIndex: Int) {
        get {
            let selectedChapterIndex = UserDefaults.standard.integer(forKey: kSelectedChapterIndex)
            let selectedShlokaIndex = UserDefaults.standard.integer(forKey: kSelectedShlokaIndex)
            return (chapterIndex: selectedChapterIndex, shlokaIndex: selectedShlokaIndex)
        }
        set {
            UserDefaults.standard.set(newValue.chapterIndex, forKey: kSelectedChapterIndex)
            UserDefaults.standard.set(newValue.shlokaIndex, forKey: kSelectedShlokaIndex)
        }
    }

	//Dynamic property got from DB
	var selectedlanguagesIDs: [Int] {
		return Language.loadSelected().map { $0.id }
	}
	
	var defaultBookId: Int {
		get {
			return UserDefaults.standard.integer(forKey: kDefaultBookId)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: kDefaultBookId)
		}
	}
	
	var defaultLanguageId: Int? {
		get {
			return Book.getByID(self.defaultBookId)?.languageId
		}
	}
}

extension Settings: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(self)
    }
    
}

extension Settings: Equatable {
    public static func ==(lhs: Settings, rhs: Settings) -> Bool {
        if lhs.showSanskrit != rhs.showSanskrit { return false }
        if lhs.showTranscription != rhs.showTranscription { return false }
        if lhs.showVocabulary != rhs.showVocabulary { return false }
        if lhs.showComments != rhs.showComments { return false }
        if lhs.selectedlanguagesIDs != rhs.selectedlanguagesIDs { return false }
        return true
    }
}
