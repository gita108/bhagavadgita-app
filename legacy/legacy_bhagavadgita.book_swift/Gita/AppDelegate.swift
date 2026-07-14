//
//  AppDelegate.swift
//  Gita
//
//  Created by mikhail.kulichkov on 24/04/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var sharedInstance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		//Init DB
		DbHelper.initDb()
		if DbHelper.updateIfNeeded() {
			//Reset initialized flag if DB version upgraded
			Settings.shared.dataInitialized = false
			//For v.0 -> v.1: Move audio to Translation directory
			Book.migrateTranslationAudio(bookId: Settings.shared.defaultBookId, isSanskrit: false)
		}
		
		print(DbHelper.dbPath())
		
		//Remove incomplete downloads for previous run
		DownloadInfo.clearAll()
		
		//Reset selected shloka
		Settings.shared.selectedShloka = (chapterIndex: 0, shlokaIndex: 0)

		GAHelper.startTrackingWithId("UA-91314625-2")
		GAHelper.trackUncaughtExceptions = true
		
		GitaRequestManager.sharedConfiguration.timeoutInterval(120)
		
		if !Settings.shared.dataInitialized {

			//Show localized splash screen
			window = UIWindow(frame: UIScreen.main.bounds)
			window?.backgroundColor = .red1
			let splashViewController = SplashViewController()
			window?.rootViewController = splashViewController
			window?.makeKeyAndVisible()

			DownloadManager.shared.downloadInitialData(success: {[unowned self] in

				print("---- finished loading data: \(NSDate())")

				splashViewController.setProgress(progress: 1.0, animated: true)

				//Mark DB initialized
				Settings.shared.dataInitialized = true

				//Stop a bit to let user see 100%
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					//Show main screen
					if Settings.shared.hasDisplayedGuide {
						self.showMainViewController()
					} else {
						self.showGuide()
					}
				}

				}, progress: {(progress) in
					splashViewController.setProgress(progress: progress, animated: true)
			},
				   error: { (error: RequestError) in
					//Do nothing until data loaded
			})

		} else {

			//Show main screen
			window = UIWindow(frame: UIScreen.main.bounds)
			window?.backgroundColor = .red1
			showMainViewController()
			window?.makeKeyAndVisible()
		}
		
		return true
    }

	func applicationDidEnterBackground(_ application: UIApplication) {
		
		//Get books that were interrupted by application went background, not by server error
		for downloadInfo in DownloadInfo.downloads {
			if downloadInfo.isDownloading {
				
				GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownload, action: "Download stopped at \(String(format: "%2.f%%", 100 * (Float(downloadInfo.completedDownloads) / Float(downloadInfo.totalDownloads))))")
				
				DownloadManager.shared.stopDownload(downloadInfo: downloadInfo)
			}
		}
		
		if DownloadInfo.downloads.count > 0 {
			GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownload, action: "Download stopped, application went background")
		}
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		
		//Start interrupted downloads from Settings
		if Settings.shared.dataInitialized  {
			//Get books that were interrupted by application went background, not by server error
			for downloadInfo in DownloadInfo.downloads {
				if !downloadInfo.isDownloaded {
					//Mark download resumed
					downloadInfo.isResumed = true
					DownloadInfo.save(downloadInfo)
				}
			}
			
			if DownloadInfo.downloads.count > 0 {
				GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownload, action: "Resuming download of \(DownloadInfo.downloads.map {"Id: \($0.bookId), \($0.isSanskrit)"}) books")
				
				GitaRequestManager.getBooks(context: nil, success: { (books: [Book]) in
					for book in books {
						if let _ = DownloadInfo.downloads.index(where: { $0.bookId == book.id && $0.isSanskrit }) {
							DownloadManager.shared.downloadAudio(book: book, isSanskrit: true)
						}
						if let _ = DownloadInfo.downloads.index(where: { $0.bookId == book.id && !$0.isSanskrit }) {
							DownloadManager.shared.downloadAudio(book: book, isSanskrit: false)
						}
					}
				}, error: { (err) in
					print(err)
//					GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryDownloadError, action: "Failed Data/Books request", details: err.description)
				})
			}
		}
	}
	
	//MARK: - Methods
	func showGuide() {
		window?.rootViewController = GuideViewController()
	}
	
    func showMainViewController() {
        let contentsVC = ContentsViewController()
        var mainNavVC: UINavigationController
        
        // Fixing troubles with PopVC on different iOS versions
        if #available(iOS 10.0, *) {
            mainNavVC = CustomNavigationController(rootViewController: contentsVC)
        } else {
            mainNavVC = UINavigationController(rootViewController: contentsVC)
        }
		
        Style.applyRedBarDesign()
        
        if UIDevice.isIPad {
            let detailNavVC = UINavigationController()
            let rootVC = UISplitViewController()
            rootVC.viewControllers = [mainNavVC, detailNavVC]
            rootVC.presentsWithGesture = true
            rootVC.preferredDisplayMode = .allVisible
			
            window?.rootViewController = rootVC
        } else {
            window?.rootViewController = mainNavVC
        }
    }
}

