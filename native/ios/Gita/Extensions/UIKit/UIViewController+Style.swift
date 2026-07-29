//
//  UIViewController+CustomDraw.swift
//  Tomato
//
//  Created by Konstantin Oznobikhin on 11/04/16.
//  Copyright © 2016 ironwaterstudio. All rights reserved.
//

import UIKit

extension UIViewController {
	
	//MARK: UIBarButtonItem
	
	public func barButton(withImage imageName: String, disabledAlpha: CGFloat = 1, isMultiple: Bool = false, isLeft: Bool = true, action selector: Selector) -> UIBarButtonItem {
		
		let image = UIImage(named: imageName)
		let imagePressed = UIImage(named: imageName.appending("_pressed"))
		
		let button = UIButton(type: .custom)
		
		//NOTE: set minimum bar button height to 44px by Apple interface guidelines
		if #available(iOS 11.0, *) {
			let extraTouchWidth: CGFloat = isMultiple ? 4 : (isLeft ? 20 : 10)
			button.frame = CGRect(x: 0.0, y: 0.0, width: (image?.size.width)! + extraTouchWidth, height: max((image?.size.height)!, 44))
		} else {
			button.frame = CGRect(x: 0.0, y: 0.0, width: (image?.size.width)!, height: (image?.size.height)!)
		}
		
		// creating disabled image
		if let image = image, disabledAlpha < 1, disabledAlpha >= 0 {
			UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
			image.draw(at: .zero, blendMode: .normal, alpha: disabledAlpha)
			let imageDisabled = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			button.setImage(imageDisabled, for: .disabled)
		} else {
			button.setImage(image, for: .disabled)
		}
		
		button.setImage(image, for: .normal)
		button.setImage(imagePressed, for: .selected)
		button.setImage(imagePressed, for: .highlighted)
		
		if #available(iOS 11.0, *) {
			button.contentHorizontalAlignment = isLeft ? .left : .right
		}
		
		button.addTarget(self, action: selector, for: .touchUpInside)
		
		let buttonItem = UIBarButtonItem(customView: button)
		
		return buttonItem
	}
	
	public func barButton(withText text: String, font: UIFont, color: UIColor, action selector:Selector) -> UIBarButtonItem {
		
		let button = UIButton(type: .custom)
		
		let textSize = text.size(width: 200, font: font)
		button.frame = CGRect(x: 0.0, y: 0.0, width: textSize.width, height: 40.0)

		button.titleLabel?.font = font
		button.setTitleColor(color, for: .normal)
		button.setTitle(text, for: .normal)
		button.setTitleColor(.darkText, for: .disabled)
		
		button.addTarget(self, action: selector, for: .touchUpInside)
		
		let buttonItem = UIBarButtonItem(customView: button)
		
		return buttonItem
	}
	
	public func setNavigationMenuButton(withImage imageName: String, action selector: Selector) {
		let buttonItem = self.barButton(withImage: imageName, action: selector)
		
		let spaceFix = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
		spaceFix.width = -6.0
		self.navigationItem.leftBarButtonItems = [spaceFix, buttonItem]
	}
	
	public func setNavigationMenuButton(withSelector selector: Selector) {
		self.setNavigationMenuButton(withImage: "navbar_icon_menu", action: selector)
	}
}
