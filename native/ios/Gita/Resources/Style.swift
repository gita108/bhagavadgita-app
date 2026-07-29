//
//  Style.swift
//  Gita
//
//  Created by mikhail.kulichkov on 25/04/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

class Style {
    
    open class var navBarFont: UIFont {
        return UIFont(type: .regular, size: 18.0)
    }

    open class func settingsTitleLabel(text: String = "") -> UILabel {
        return label(text: text, fontSize: 18.0, fontType: .regular, textColor: .gray1, textAlignment: .center)
    }
    
    open class func nameLabel(text: String = "") -> UILabel {
        return label(text: text, fontSize: 20.0, fontType: .bold, textColor: .gray1, textAlignment: .center)
    }
    
    open class func audioNameLabel(text: String = "") -> UILabel {
        return label(text: text, fontSize: 16.0, fontType: .bold, textColor: .gray1, textAlignment: .left)
    }
    
    open class func commentLabel(text: String = "") -> UILabel {
        return label(text: text, fontSize: 16.0, fontType: .regular, textColor: .gray1, textAlignment: .left)
    }
    
    open class func settingLabel(text: String = "") -> UILabel {
        return label(text: text, fontSize: 16.0, fontType: .regular, textColor: .gray1, textAlignment: .left)
    }
    
    open class func settingsSubtitleLabel(text: String = "") -> UILabel {
        return label(text: text.uppercased(), fontSize: 14.0, fontType: .regular, textColor: .gray2, textAlignment: .left)
    }
    
    open class func authorLabel(text: String = "") -> UILabel {
        let lblAuthor = label(text: text, fontSize: 16.0, fontType: .regular, textColor: .gray2, textAlignment: .left)
        lblAuthor.numberOfLines = 0
        return lblAuthor
    }
    
	open class func emptyDataLabel(text: String = "") -> UILabel {
		return label(text: text, fontSize: 15.0, fontType: .regular, textColor: .gray1, textAlignment: .center)
	}

	open class func splashLabel(text: String = "") -> UILabel {
		return label(text: text, fontSize: 30.0, fontType: .regular, textColor: .white, textAlignment: .center)
	}
	
	open class func splashProgressLabel(text: String = "") -> UILabel {
		return label(text: text, fontSize: 24.0, fontType: .regular, textColor: .white, textAlignment: .center)
	}
	
	open class func guideTitleLabel(text: String = "") -> UILabel {
		return label(text: text, fontSize: 20.0, fontType: .regular, textColor: .white, textAlignment: .center)
	}
	
	open class func guideTextLabel(text: String = "") -> UILabel {
		return label(text: text, fontSize: 15.0, fontType: .regular, textColor: .white, textAlignment: .center)
	}

	open class func guideNoteLabel(text: String = "") -> UILabel {
		return label(text: text, fontSize: 15.0, fontType: .regular, textColor: .white, textAlignment: .left)
	}

	open class func whiteTextButton(text: String) -> UIButton {
		let button = UIButton()
		let attributes: [String: Any] = [
			NSFontAttributeName : UIFont(type: .regular, size: 15.0),
			NSForegroundColorAttributeName : UIColor.white
		]
		let attributedTitle = NSAttributedString(string: text, attributes: attributes)
		button.setAttributedTitle(attributedTitle, for: .normal)
		
		return button
	}
	
	open class func redSwitch() -> UISwitch {
        let redSwitch = UISwitch()
        redSwitch.onTintColor = .red1
        return redSwitch
    }

    open class func languageSeparatorImage(text: String = "") -> UIImageView {
        let imgLanguage = UIImageView(image: UIImage(named: "divider_language"))
        
        let attributes: [String: Any] = [
            NSFontAttributeName : UIFont(type: .bold, size: 12.0),
            NSForegroundColorAttributeName : UIColor.red1
        ]
        let attributedTitle = NSAttributedString(string: text, attributes: attributes)
        
        let lblLanguage = UILabel()
        lblLanguage.attributedText = attributedTitle
        
        imgLanguage.addSubview(lblLanguage)
        
        activateConstraints(
            lblLanguage.centerXItem == imgLanguage.centerXItem,
            lblLanguage.centerYItem == imgLanguage.centerYItem
        )
        
        return imgLanguage
    }
    
    open class func cellAttributedText(_ text: String) -> NSAttributedString {
        let attributes: [String: Any] = [
            NSFontAttributeName : UIFont(type: .regular, size: 16.0),
            NSForegroundColorAttributeName : UIColor.gray1
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    open class func initialsImage(text: String = "") -> UIImageView {
        let lblInitials = UILabel()
        let attributes: [String: Any] = [
            NSFontAttributeName : UIFont(type: .boldItalic, size: 12.0),
            NSForegroundColorAttributeName : UIColor.red1
        ]
        let attributedInitials = NSAttributedString(string: text, attributes: attributes)
        lblInitials.attributedText = attributedInitials
        
        let image = UIImage(named: "circle_initials")?.resizableImage(withCapInsets: UIEdgeInsets(top: 9.0, left: 11.0, bottom: 9.0, right: 11.0))
        let imgInitials = UIImageView(image: image)
        
        imgInitials.addSubview(lblInitials)
        
        activateConstraints(
            lblInitials.centerYItem == imgInitials.centerYItem,
            imgInitials.leadingItem == lblInitials.leadingItem - 3.0,
            imgInitials.trailingItem == lblInitials.trailingItem + 3.0
        )
        
        return imgInitials
    }
	
    //TODO: review
	open class func applyBorderedButtonStyle(button: UIButton, text: String) {
		let attributes: [String: Any] = [
			NSFontAttributeName : UIFont(type: .regular, size: 16.0),
			NSForegroundColorAttributeName : UIColor.red1
		]
		let attributedTitle = NSAttributedString(string: text, attributes: attributes)
		button.setAttributedTitle(attributedTitle, for: .normal)
		
		button.layer.borderColor = UIColor.red1.cgColor
		button.layer.borderWidth = 1.0
		button.layer.cornerRadius = 7.0
		button.layer.masksToBounds = true
		button.clipsToBounds = true
		
		button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 3.0, bottom: 0.0, right: 3.0)
	}
	
    private class func label(text: String, fontSize: CGFloat, fontType: UIFont.PTSans, textColor: UIColor, textAlignment: NSTextAlignment) -> UILabel {
        let label = UILabel()

        label.font = UIFont(type: fontType, size: fontSize)
        label.textColor = textColor
        label.textAlignment = textAlignment
        label.text = text
        
        return label
    }
    
    //MARK: - Helpers
    class func heightOfText(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        let rect = attributedText.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        return  rect.integral.size.height
    }
    
    class func size(for text: NSAttributedString, font: UIFont, width: CGFloat, height: CGFloat) -> CGSize {
        return text.boundingRect(with: CGSize(width: width, height: height), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
    }
    
    open class func applyRedBarDesign() {
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().barTintColor = .red1
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().clipsToBounds = false
        UINavigationBar.appearance().backgroundColor = .red1
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(type: .regular, size: 18.0),
            NSForegroundColorAttributeName: UIColor.white
        ]
    }
    
}

extension UIFont {
    
    enum PTSans {
        case italic, regular, bold, boldItalic
        
        var fontName: String {
            switch self {
            case .italic: return "PTSans-Italic"
            case .regular: return "PTSans-Regular"
            case .bold: return "PTSans-Bold"
            case .boldItalic: return "PTSans-BoldItalic"
            }
        }
    }
    
    enum Kohinoor {
        case regular, light, semibold
        
        var fontName: String {
            switch self {
            case .regular: return "KohinoorDevanagari-Regular"
            case .light: return "KohinoorDevanagari-Light"
            case .semibold: return "KohinoorDevanagari-Semibold"
            }
        }
    }
    
    convenience init(type: PTSans, size: CGFloat) {
        self.init(name: type.fontName, size: size)!
    }
    
}

// http://stackoverflow.com/questions/24263007/
extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    class var gray1: UIColor {
        return UIColor(rgb: 0x4A4A4A)
    }
    
    class var gray2: UIColor {
        return UIColor(rgb: 0x9B9B9B)
    }
    
    class var gray3: UIColor {
        return UIColor(rgb: 0xC7C7CC)
    }
    
    class var gray4: UIColor {
        return UIColor(rgb: 0xE8E8E8)
    }
    
    class var gray5: UIColor {
        return UIColor(rgb: 0xF9F9F9)
    }
	
	class var gray6: UIColor {
		return UIColor(rgb: 0x7A797B)
	}
	
    class var red1: UIColor {
        return UIColor(rgb: 0xFF5252)
    }
	
	class var red2: UIColor {
		return UIColor(rgb: 0xFB9A6A)
	}
    
}

extension UINavigationBar {
    
    func applyRedDesign() {
        UIApplication.shared.statusBarStyle = .lightContent
        setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        shadowImage = UIImage()
        tintColor = .white
        barTintColor = .red1
        isTranslucent = false
        clipsToBounds = false
        backgroundColor = .red1
        titleTextAttributes = [
            NSFontAttributeName: UIFont(type: .regular, size: 18.0),
            NSForegroundColorAttributeName: UIColor.white
        ]
    }
    
    func applyWhiteDesign() {
        UIApplication.shared.statusBarStyle = .default
        setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        shadowImage = UIImage()
        tintColor = .red1
        barTintColor = .white
        isTranslucent = false
        clipsToBounds = false
        backgroundColor = .white
        titleTextAttributes = [
            NSFontAttributeName: UIFont(type: .regular, size: 18.0),
            NSForegroundColorAttributeName: UIColor.gray1
        ]
    }
}
