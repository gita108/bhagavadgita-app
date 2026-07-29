//
//  ShlokaWordsTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 30/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

final class ShlokaWordsTableViewCell: ReusableTableViewCell {
    
	private let lblWords: UILabel = {
		
		let lblWords = UILabel()
		lblWords.textAlignment = .center
		lblWords.numberOfLines = 0

		return lblWords
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        
        contentView.addSubview(lblWords)
        
        activateConstraints(
            lblWords.topItem == contentView.topItem + 8.0,
            lblWords.leadingItem == contentView.leadingItem + 16.0,
            lblWords.trailingItem == contentView.trailingItem - 16.0
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	func fill(words: [Vocabulary]) {
		lblWords.attributedText = ShlokaWordsTableViewCell.attributedString(with: words)
	}

    // MARK: - Helpers
    private static func attributedString(with words: [Vocabulary]) -> NSAttributedString {
        let boldItalicAttributes: [String: Any] = [
            NSFontAttributeName : UIFont(type: .boldItalic, size: 18.0),
            NSForegroundColorAttributeName : UIColor.gray1
        ]
        
        let regularAttributes: [String: Any] = [
            NSFontAttributeName : UIFont(type: .regular, size: 18.0),
            NSForegroundColorAttributeName : UIColor.gray1
        ]
        
        let attributedText = NSMutableAttributedString()
        
        for element in words {
            let sign = (words.last != element) ? "; " : "."
            let word = NSAttributedString(string: element.text, attributes: boldItalicAttributes)
            let translation = NSAttributedString(string: " — \(element.translation)\(sign)", attributes: regularAttributes)
            attributedText.append(word)
            attributedText.append(translation)
        }
        
        return attributedText
    }
    
    static func height(words: [Vocabulary], width: CGFloat) -> CGFloat {
        let wordsHeight = attributedString(with: words).boundingRect(with: CGSize(width: width - 32.0, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
        
        return wordsHeight + 16.0
    }
}
