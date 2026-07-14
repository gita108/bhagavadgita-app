//
//  EmptyBookmarksView.swift
//  Gita
//
//  Created by Olga Zhegulo  on 16/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

class EmptyBookmarksView: UIView {

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let imgLogo = UIImageView(image: UIImage(named: "icn_empty"))

		addSubview(imgLogo)
		
		let label = Style.emptyDataLabel()
		label.text = Local("Bookmarks.Search.NotFound")
		addSubview(label)
		
		activateConstraints(
			imgLogo.widthItem == 121,
			imgLogo.heightItem == 120,
			imgLogo.topItem == topItem + 98,
			imgLogo.centerXItem == centerXItem,
			
			label.topItem == imgLogo.bottomItem + 23,
			label.centerXItem == centerXItem
		)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
