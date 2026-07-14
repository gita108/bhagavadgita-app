//
//  ShlokaDelegate.swift
//  Gita
//
//  Created by Olga Zhegulo  on 13/06/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

protocol ShlokaDelegate: class {
	func openShloka(from controller: UIViewController, chapterOrder: Int, shlokaOrder: Int)
	func shlokaViewControllerDidSelectNext(_ shlokaVC: ShlokaViewController)
	func shlokaViewControllerDidSelectPrevious(_ shlokaVC: ShlokaViewController)
	func toggledBookmark(from controller: UIViewController, chapterOrder: Int, shlokaOrder: Int, bookmarked: Bool)
	func didCompletedTrack(_ vc: ShlokaViewController)
}

extension ShlokaDelegate {
	func openShloka(from controller: UIViewController, chapterOrder: Int, shlokaOrder: Int) {
	}
	
	func shlokaViewControllerDidSelectNext(_ shlokaVC: ShlokaViewController) {
	}
	
	func shlokaViewControllerDidSelectPrevious(_ shlokaVC: ShlokaViewController) {
	}
	
	func toggledBookmark(from controller: UIViewController, chapterOrder: Int, shlokaOrder: Int, bookmarked: Bool) {
	}
	
	func didCompletedTrack(_ vc: ShlokaViewController) {
	}
}
