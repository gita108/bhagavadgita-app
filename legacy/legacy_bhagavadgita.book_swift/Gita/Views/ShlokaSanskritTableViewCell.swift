//
//  ShlokaSanskritTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 30/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

fileprivate let originalTextFont = UIFont(name: UIFont.Kohinoor.semibold.fontName, size: 18.0)!

final class ShlokaSanskritTableViewCell: ReusableTableViewCell {
    
	private let lblOriginalText: UILabel = {
		let lblOriginalText = UILabel()
		
		lblOriginalText.font = originalTextFont
		lblOriginalText.numberOfLines = 0
		lblOriginalText.textColor = .gray1
		lblOriginalText.textAlignment = .center

		return lblOriginalText
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		selectionStyle = .none
		separatorInset = UIEdgeInsets.zero
		layoutMargins = UIEdgeInsets.zero
		
		contentView.addSubview(lblOriginalText)
		
		activateConstraints(
			lblOriginalText.topItem == contentView.topItem + 8.0,
			lblOriginalText.leadingItem == contentView.leadingItem + 58.0,
			lblOriginalText.trailingItem == contentView.trailingItem - 58.0
		)
	}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	func fill(text: String) {
		lblOriginalText.text = text
	}
	
    // MARK: - Helpers
    
    static func height(text: String, width: CGFloat) -> CGFloat {
        let textHeight = Style.heightOfText(text, font: originalTextFont, width: width - 116.0)
        return textHeight + 16.0
    }
}

