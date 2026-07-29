//
//  ShlokaTranslationTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 23/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//
fileprivate let translationFont = UIFont(type: .bold, size: 18.0)

final class ShlokaTranslationTableViewCell: ReusableTableViewCell {
    
    private let imgLanguageSeparator: UIImageView = {
        let imgLanguageSeparator = UIImageView(image: UIImage(named: "divider_language"))
        imgLanguageSeparator.contentMode = .center
        return imgLanguageSeparator
    }()
    
    private let lblLanguage: UILabel = {
        let lblLanguage = UILabel()
        
        lblLanguage.font = UIFont(type: .bold, size: 12.0)
        lblLanguage.numberOfLines = 1
        lblLanguage.textColor = .red1
        lblLanguage.textAlignment = .center
        
        return lblLanguage
    }()
    
    private let lblTranslation: UILabel = {
        let lblTranslation = UILabel()
        
        lblTranslation.font = translationFont
        lblTranslation.numberOfLines = 0
        lblTranslation.textColor = .gray1
        lblTranslation.textAlignment = .center
        
        return lblTranslation
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: nil)

        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        
        contentView.addSubviews(imgLanguageSeparator, lblLanguage, lblTranslation)
        
        activateConstraints(
            imgLanguageSeparator.topItem == contentView.topItem,
            imgLanguageSeparator.centerXItem == contentView.centerXItem,
            imgLanguageSeparator.heightItem == imgLanguageSeparator.widthItem,
            
            lblLanguage.centerXItem == imgLanguageSeparator.centerXItem,
            lblLanguage.centerYItem == imgLanguageSeparator.centerYItem,
            
            lblTranslation.topItem == imgLanguageSeparator.bottomItem,
            lblTranslation.leadingItem == contentView.leadingItem + 16.0,
            lblTranslation.trailingItem == contentView.trailingItem - 16.0
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblLanguage.text = ""
        lblTranslation.text = ""
    }
    
    func fill(language: String, translation: String) {
        lblLanguage.text = language.capitalized
        lblTranslation.text = translation
    }

    static func height(translation: String, width: CGFloat) -> CGFloat {
        let translationHeight = Style.heightOfText(translation, font: translationFont, width: width - 32.0)
        return translationHeight + (UIImage(named: "divider_language")?.size.height)! + 32.0
    }
}
