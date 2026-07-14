//
//  GuideItemViewController.swift
//  Gita
//
//  Created by Olga Zhegulo  on 06/06/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

class GuideItemViewController: UIViewController, GuideDelegate {

	var imageName: String
	var header: String
	var text: String
	
	var index: Int
	
	private let imgLogo = UIImageView()
	private var cLogoTop: NSLayoutConstraint?
	
	init(_ index: Int, imageName: String, header: String, text: String) {
		self.index = index
		self.imageName = imageName
		self.header = header
		self.text = text
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		self.view = UIView()
		
		//NOTE: moved background (same for all steps) to guide pager
		
		imgLogo.image = UIImage(named: imageName)
		
		let lblHeader = Style.guideTitleLabel()
		lblHeader.numberOfLines = 0
		lblHeader.lineBreakMode = .byWordWrapping
		lblHeader.text = header.uppercased()
		
		let lblText = Style.guideTextLabel()
		lblText.numberOfLines = 0
		lblText.lineBreakMode = .byWordWrapping
		lblText.text = text
		
		view.addSubview(imgLogo)
		view.addSubview(lblHeader)
		view.addSubview(lblText)
		
		//Set top and text width for iPad
		let isIPad = UIDevice.isIPad
		
		let topPadding = isIPad ? (UIScreen.main.bounds.size.height * 0.33) : 144

		if #available(iOS 11, *) {
			cLogoTop = self.imgLogo.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: topPadding)
		} else {
			cLogoTop = imgLogo.topItem == view.topItem + topPadding
		}

		let cTextWidth = isIPad ?
			(lblText.widthItem <= view.widthItem * 0.5) :
			(lblText.widthItem <= view.widthItem - 2*38)
		
		activateConstraints(
			cLogoTop!,
			imgLogo.widthItem == 118,
			imgLogo.heightItem == 118,
			imgLogo.centerXItem == view.centerXItem,
			
			lblHeader.topItem == imgLogo.bottomItem + 16,
			lblHeader.centerXItem == view.centerXItem,
			lblHeader.leadingItem >= view.leadingItem + 16,
			lblHeader.trailingItem <= view.trailingItem - 16,
			
			lblText.topItem == lblHeader.bottomItem + 16,
			lblText.centerXItem == view.centerXItem,
			cTextWidth,
			lblText.bottomItem <= view.bottomItem - 16
		)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		GAHelper.logScreen("Guide.\(index + 1)")
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		self.cLogoTop!.constant = size.height * 0.33
	}
	
	// MARK: - GuideDelegate
	func guideIndex() -> Int {
		return index
	}
}
