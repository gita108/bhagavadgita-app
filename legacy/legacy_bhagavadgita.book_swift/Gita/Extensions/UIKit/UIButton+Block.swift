//
//  UIButton+Block.swift
//  SecurityApp
//
//  Created by Mikhail Kulichkov on 26/06/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

private var kButtonEventAction: Int = 0
typealias ButtonAction = () -> ()

extension UIButton {
    
    var action: ButtonAction? {
        get {
            let action = objc_getAssociatedObject(self, &kButtonEventAction) as? ButtonAction
            return action
        }
        set {
            objc_setAssociatedObject(self, &kButtonEventAction, newValue as AnyObject, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    // MARK: - UIButton + Closure
    
    @objc
    private func callButtonAction(_ sender: Any) {
        action?()
    }

    // MARK: - Experimental
    
    /**
     - Warning:
     If using UIButton as property in this case property must by *lazy*
     */
    func action(_ action: @escaping () -> ()) -> UIButton {
        self.action = action
        self.addTarget(self, action: #selector(callButtonAction), for: .touchUpInside)
        return self
    }
}
