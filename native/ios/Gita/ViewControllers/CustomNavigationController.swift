//
//  CustomNavigationController.swift
//  Gita
//
//  Created by mikhail.kulichkov on 27/04/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

// http://stackoverflow.com/questions/39511088/navigationbar-coloring-in-viewwillappear-happens-too-late-in-ios-10
class CustomNavigationController: UINavigationController {

    override func popViewController(animated: Bool) -> UIViewController? {
        let poppedViewController = super.popViewController(animated: animated)
        
        let transition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        navigationController?.navigationBar.layer.add(transition, forKey: nil)
		
		//Change navigation bar color if pop to root
		if self.viewControllers[0] == poppedViewController {
			UIApplication.shared.statusBarStyle = .lightContent
			navigationBar.tintColor = .white
			navigationBar.barTintColor = .red1
			
			UIView.animate(withDuration: 0.25) {[unowned self] in
				self.navigationController?.navigationBar.backgroundColor = .red1
			}
            
            navigationBar.titleTextAttributes = [
                NSFontAttributeName: Style.navBarFont,
                NSForegroundColorAttributeName: UIColor.white
            ]
        }

        return poppedViewController
    }


}
