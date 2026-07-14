//
//  UITextField+Style.swift
//  SecurityApp
//
//  Created by Mikhail Kulichkov on 26/06/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

extension UITextField {

	static let kDefaultTextColor: UIColor = .black
	static let kDefaultTextSize: CGFloat = 16.0
	static let kDefaultPlaceholder: String = ""
	static let kDefaultAlphaComponent: CGFloat = 0.5

    convenience init(placeholder: String?,
                     size: CGFloat = kDefaultTextSize,
                     color: UIColor = kDefaultTextColor) {
        self.init()
		
		let foregroundColor = color.withAlphaComponent(UITextField.kDefaultAlphaComponent)
		#if swift(>=4.0)
			let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: foregroundColor]
		#else
			let attributes: [String: Any] = [NSForegroundColorAttributeName: foregroundColor]
		#endif
		
		self.attributedPlaceholder = NSAttributedString(string: placeholder ?? UITextField.kDefaultPlaceholder, attributes: attributes)
        self.borderStyle = .none
        self.font = UIFont.systemFont(ofSize: size)
        self.textColor = color
    }
    
    // MARK: - Experimental
	
	@discardableResult
    func color(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }
	
	@discardableResult
    func keyboard(_ keyboardType: UIKeyboardType) -> Self {
        self.keyboardType = keyboardType
        return self
    }
	
	@discardableResult
    func secured(_ secured: Bool) -> UITextField {
        self.isSecureTextEntry = secured
        return self
    }
	
    @discardableResult
    func boarderStyle( _ borderStyle: UITextBorderStyle) -> Self {
        self.borderStyle = borderStyle
        return self
    }
	
	@discardableResult
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
	
	@discardableResult
    func placeholder(_ text: String) -> Self {
		let foregroundColor = self.textColor ?? UITextField.kDefaultTextColor
		#if swift(>=4.0)
			self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor: foregroundColor])
		#else
			self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: foregroundColor])
		#endif
		
        return self
    }
	
	@discardableResult
    func capitalization(_ capitalization: UITextAutocapitalizationType) -> Self {
        self.autocapitalizationType = capitalization
        return self
    }
	
	@discardableResult
	func clearButton(_ mode: UITextFieldViewMode) -> Self {
		self.clearButtonMode = mode
		return self
	}
	
	@discardableResult
	func apply(_ styleActions: (UITextField) -> ()...) -> UITextField {
		let actionsArray = Array(styleActions)
		self.apply(actionsArray)
		return self
	}

}
