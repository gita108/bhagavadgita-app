//
//  GuideNotesViewController.swift
//  Gita
//
//  Created by Olga Zhegulo  on 07/06/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

class GuideNotesViewController: UIViewController, GuideDelegate {

	var index: Int
	var imageName: String
	var text: String
	
	private let imgLogo = UIImageView()
	private var cLogoTop: NSLayoutConstraint?

	init(_ index: Int, imageName: String, text: String) {
		self.index = index
		self.imageName = imageName
		self.text = text
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		self.view = UIView()
		
		//NOTE: moved background (same for all steps) to guide pager
		
		let imgLogo = UIImageView(image: UIImage(named: imageName))
		
		view.addSubview(imgLogo)
		
		let vList = UIView()
		vList.backgroundColor = .clear
		
		view.addSubview(vList)
		
		//Set top and text width for iPad
		let isIPad = UIDevice.isIPad
		
		cLogoTop = isIPad ?
			(imgLogo.topItem == view.topItem + (UIScreen.main.bounds.size.height * 0.33)) :
			(imgLogo.topItem == view.topItem + 144)

		activateConstraints(
			cLogoTop!,
			imgLogo.widthItem == 118,
			imgLogo.heightItem == 118,
			imgLogo.centerXItem == view.centerXItem,
			
			vList.topItem == imgLogo.bottomItem + 16,
			vList.topItem == imgLogo.bottomItem + 16,
			vList.centerXItem == view.centerXItem + 17,
			vList.leadingItem >= view.leadingItem + 16,
			vList.trailingItem <= view.trailingItem - 16,
			vList.bottomItem <= view.bottomItem - 16
		)
		
		var lines = text.split(["\n"], removeSeparators: true, removeEmptyEntries: true)

		var textConstraints = [NSLayoutConstraint]()
		var vItems = [UIView]()

		for i in 0..<lines.count {
			//Create list item container
			let vItem = UIView()
			
			vList.addSubview(vItem)
			
			//Check image
			let imgCheck = UIImageView(image: UIImage(named: "ic_check_white"))
			vItem.addSubview(imgCheck)
			
			//Text
			let lblText = Style.guideNoteLabel()
			lblText.numberOfLines = 0
			lblText.lineBreakMode = .byWordWrapping
			
			//Set text
			lblText.text = lines[i]
			
			vItem.addSubview(lblText)
			
			//List item constraints
			if i == 0 {
				textConstraints.append(vItem.topItem == vList.topItem)
			} else {
				textConstraints.append(vItem.topItem == vItems[i-1].bottomItem + 4)
			}
			
			if i == lines.count - 1 {
				textConstraints.append(vItem.bottomItem == vList.bottomItem)
			}
			
			textConstraints.append(vItem.leadingItem == vList.leadingItem)
			textConstraints.append(vItem.trailingItem <= vList.trailingItem)
			
			textConstraints.append(imgCheck.leadingItem == vItem.leadingItem)
			textConstraints.append(imgCheck.topItem == lblText.topItem + 6)
			textConstraints.append(imgCheck.trailingItem == lblText.leadingItem - 4)
			
			textConstraints.append(lblText.centerYItem == vItem.centerYItem)
			textConstraints.append(lblText.trailingItem == vItem.trailingItem)
			
			textConstraints.append(lblText.topItem >= vItem.topItem)
			textConstraints.append(lblText.bottomItem >= vItem.bottomItem)
			textConstraints.append(imgCheck.topItem >= vItem.topItem)
			textConstraints.append(imgCheck.bottomItem <= vItem.bottomItem)
			
			vItems.append(vItem)
		}
		
		NSLayoutConstraint.activate(textConstraints)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//Analytics.logEvent(AnalyticsEventViewItem, parameters: [AnalyticsParameterItemName : String(describing: type(of: self))])
		GAHelper.logScreen("Guide.3")
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
