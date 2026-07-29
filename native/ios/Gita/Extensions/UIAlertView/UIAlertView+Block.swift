//
//  UIAlertView+Block.swift
//  AlertManager
//
//  Created by mikhail.kulichkov on 20/04/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

private var kDismissBlock = 0
typealias AlertViewDismissBlock = (Int) -> ()

extension UIAlertView: UIAlertViewDelegate {
    
    var dismissBlock: AlertViewDismissBlock? {
        get {
            let block = objc_getAssociatedObject(self, &kDismissBlock) as? AlertViewDismissBlock
            return block
        }
        set {
            objc_setAssociatedObject(self, &kDismissBlock, newValue as AnyObject, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    static func alertView(title: String,
                          message: String,
                          buttons: [String],
                          dismissBlock: @escaping AlertViewDismissBlock) -> UIAlertView {
        let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: buttons.first ?? "Cancel")
        if buttons.count > 1 {
            for i in 1..<buttons.count {
                alertView.addButton(withTitle: buttons[i])
            }
        }
        
        alertView.dismissBlock = dismissBlock
        return alertView
    }
    
    private static func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if let block = alertView.dismissBlock {
            block(buttonIndex)
        }
    }
}
