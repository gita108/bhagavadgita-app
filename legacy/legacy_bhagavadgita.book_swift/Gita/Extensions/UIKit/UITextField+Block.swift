//
//  UITextField+Block.swift
//  SecurityApp
//
//  Created by Mikhail Kulichkov on 28/06/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

private var kTextFieldEventAction: Int = 0
typealias TextFieldAction = () -> ()

extension UITextField {
    
    var action: TextFieldAction? {
        get {
            let action = objc_getAssociatedObject(self, &kTextFieldEventAction) as? TextFieldAction
            return action
        }
        set {
            objc_setAssociatedObject(self, &kTextFieldEventAction, newValue as AnyObject, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    // MARK: - UIButton + Closure
    
    @objc
    private func callTextFieldAction(_ sender: Any) {
        action?()
    }
    
    // MARK: - Experimental
    
    /**
     - Note: *Action* can be possibly renamed to *Changed*
     - Warning:
     If using UITextField as property in this case property must by *lazy*
     */
    func action(_ action: @escaping () -> ()) -> UITextField {
        self.action = action
        self.addTarget(self, action: #selector(callTextFieldAction), for: .editingChanged)
        return self
    }
}
