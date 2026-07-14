//
//  SplashViewController.swift
//  Gita
//
//  Created by Olga Zhegulo  on 31/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

	private let progressView = UIProgressView()
	private let lblProgress = Style.splashProgressLabel()
	
	private var cLogoTop: NSLayoutConstraint?

	override func loadView() {
		self.view = UIView()
		
		view.backgroundColor = .red1
		
		let backgroundImage = UIImageView(image: ImageManager.gradient(from: .red2, to: .red1, size: UIScreen.main.bounds.size))
		
		let imgLogo = UIImageView(image: UIImage(named: "splash.png"))
		let lblAppName = Style.splashLabel()
		lblAppName.text = UIApplication.shared.localizedName
		
		progressView.tintColor = .white
		progressView.trackTintColor = .red2
		
		view.addSubview(backgroundImage)
		view.addSubview(imgLogo)
		view.addSubview(lblAppName)
		view.addSubview(lblProgress)
		view.addSubview(progressView)
		
		self.progress = 0.0
		
		cLogoTop = UIDevice.isIPad ?
			(imgLogo.topItem == view.topItem + (UIScreen.main.bounds.size.height * 0.33)) :
			(imgLogo.topItem == view.topItem + 144)

		activateConstraints(
			backgroundImage.topItem == view.topItem,
			backgroundImage.leadingItem == view.leadingItem,
			backgroundImage.trailingItem == view.trailingItem,
			backgroundImage.bottomItem == view.bottomItem,

			cLogoTop!,
			imgLogo.centerXItem == view.centerXItem,
			
			lblAppName.topItem == imgLogo.bottomItem + 28,
			lblAppName.centerXItem == view.centerXItem,
			
			lblProgress.topItem == lblAppName.bottomItem + 41,
			lblProgress.centerXItem == view.centerXItem,

			progressView.topItem == lblProgress.bottomItem + 36,
			progressView.centerXItem == view.centerXItem,
			progressView.leadingItem == view.leadingItem + 57,
			progressView.trailingItem == view.trailingItem - 57
		)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//Analytics.logEvent(AnalyticsEventViewItem, parameters: [AnalyticsParameterItemName : String(describing: type(of: self))])
		GAHelper.logScreen(String(describing: type(of: self)))
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		self.cLogoTop!.constant = size.height * 0.33
	}
	
	//MARK: Dynamic property
	var progress: Float {
		get { return progressView.progress }
		set {
//			print("progress: \(newValue)")
			progressView.progress = newValue
			lblProgress.text = String(format: "%d%%", newValue * 100)
		}
	}
	
	func setProgress(progress: Float, animated: Bool) {
		lblProgress.text = String(format: "%2.f%%", progress * 100.0)
		
		if animated {
			UIView.animate(withDuration: 0.25) {
				self.progressView.progress = progress
			}
		} else {
			progressView.progress = progress
		}
	}
}
