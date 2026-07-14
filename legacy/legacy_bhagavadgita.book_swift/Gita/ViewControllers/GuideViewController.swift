//
//  GuideViewController.swift
//  Gita
//
//  Created by Olga Zhegulo  on 07/06/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

protocol GuideDelegate {
	func guideIndex() -> Int
}

class GuideViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

	private let btnPrev: UIButton = {
		let button = Style.whiteTextButton(text: Local("Guide.Back"))
		button.addTarget(self, action: #selector(btnPrev_Click(sender:)), for: .touchUpInside)
		
		return button
	}()
	
	private let btnNext: UIButton = {
		let button = Style.whiteTextButton(text: Local("Guide.Forward"))
		button.addTarget(self, action: #selector(btnNext_Click(sender:)), for: .touchUpInside)
		
		return button
	}()
	
	init() {
		super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		//Because super is not UViewcontroller, but UIPageViewController
		super.loadView()
		
		//Add background same as steps to prevent black stripes scrolling first/last page
		let backgroundImage = UIImageView(image: ImageManager.gradient(from: .red2, to: .red1, size: UIScreen.main.bounds.size))

		//'Skip' button
		let btnSkip = Style.whiteTextButton(text: Local("Guide.Skip"))
		btnSkip.addTarget(self, action: #selector(btnSkip_Click(sender:)), for: .touchUpInside)
		
		view.addSubview(backgroundImage)
		view.sendSubview(toBack: backgroundImage)
		
		view.addSubview(btnSkip)
		view.addSubview(btnPrev)
		view.addSubview(btnNext)
		
		activateConstraints(
			backgroundImage.topItem == view.topItem,
			backgroundImage.leadingItem == view.leadingItem,
			backgroundImage.trailingItem == view.trailingItem,
			backgroundImage.bottomItem == view.bottomItem,
			
			btnSkip.topItem == view.topItem + 33,
			btnSkip.trailingItem == view.trailingItem - 16,
			
			btnPrev.leadingItem == view.leadingItem + 16,
			btnPrev.bottomItem == view.bottomItem - 19,
			
			btnNext.trailingItem == view.trailingItem - 16,
			btnNext.bottomItem == view.bottomItem - 19
		)
		
		let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [GuideViewController.self])
		pageControl.backgroundColor = .clear
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // [GuideVC(0), GuideVC(1), GuideNotesVC]
		self.dataSource = self
		self.delegate = self
		
		if let firstViewController = viewControllerAtIndex(index: 0) {
			setViewControllers([firstViewController],
			                   direction: .forward,
			                   animated: true,
			                   completion: nil)
		}
		btnPrev.isHidden = true
		btnNext.isHidden = false
		
		GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryGuideBegin, action: String())
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	//MARK: - UIPageViewControllerDataSource
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if let currentPageViewController = viewController as? GuideDelegate {
			let index = currentPageViewController.guideIndex()
			if index >= 0 && index < presentationCount(for: self) - 1 {
				return viewControllerAtIndex(index: index + 1)
			} else {
				return nil
			}
		}
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		if let currentPageViewController = viewController as? GuideDelegate {
			let index = currentPageViewController.guideIndex()
			if index > 0 {
				return viewControllerAtIndex(index: index - 1)
			} else {
				return nil
			}
		}
		return nil
	}
	
	//MARK: UIPageViewControllerDelegate
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return 3
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		if let currentPageViewController = viewControllers?.first as? GuideDelegate {
			return currentPageViewController.guideIndex()
		}
		return -1
	}
	
	//Duplicate code; sometimes it is not called
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		print("didFinishAnimating")
		if completed {
			self.showHideButtons()
		}
	}
	
	func viewControllerAtIndex(index: Int) -> UIViewController? {
		switch index {
		case 0:
			return GuideItemViewController(0, imageName: "icn_guide1", header: Local("Guide1.Title"), text: Local("Guide1.Text"))
		case 1:
			return GuideItemViewController(1, imageName: "icn_guide2", header: Local("Guide2.Title"), text: Local("Guide2.Text"))
		case 2:
			Settings.shared.hasDisplayedGuide = true
			return GuideNotesViewController(2, imageName: "icn_guide3", text: Local("Guide3.Text"))
		default:
			return nil
		}
	}
	
	//MARK: - Method
	func showHideButtons() {
		let index = presentationIndex(for: self)
//		print("transitionCompleted to \(index), presentationCount(for: self): \(presentationCount(for: self))")
		btnPrev.isHidden = index == 0
		btnNext.isHidden = index >= presentationCount(for: self) - 1
	}
	
	//MARK: - Actions
	
	func btnSkip_Click(sender: UIButton) {
		Settings.shared.hasDisplayedGuide = true
		AppDelegate.sharedInstance.showMainViewController()
				
		GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryGuideSkip, action: String())
	}

	//NOTE: do not use func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) because it is not called in iOS 11 after setViewControllers
	func btnPrev_Click(sender: UIButton) {
		if let currentPageController = viewControllers?.first,
			let vc = pageViewController(self, viewControllerBefore: currentPageController) {
			setViewControllers([vc],
			                   direction: .reverse,
			                   animated: true,
							   completion: {(finished) in
								//Duplicate code; sometimes it is not called
								if finished {
									self.showHideButtons()
								}
			})
		}
	}

	func btnNext_Click(sender: UIButton) {
		if let currentPageController = viewControllers?.first,
			let vc = pageViewController(self, viewControllerAfter: currentPageController) {
			setViewControllers([vc],
							   direction: .forward,
							   animated: true,
							   completion: {(finished) in
								//Duplicate code; sometimes it is not called
								if finished {
									self.showHideButtons()
								}
			})
		}
	}
}
