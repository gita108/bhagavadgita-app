//
//  ShlokaInterpretationTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 23/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

fileprivate let interpretationFont = UIFont(type: .regular, size: 16.0)

final class ShlokaInterpretationTableViewCell: ReusableTableViewCell {
    
    private let lblAuthor: UILabel = {
        let lblAuthor = UILabel()
        
        lblAuthor.font = UIFont(type: .boldItalic, size: 12.0)
        lblAuthor.numberOfLines = 1
        lblAuthor.textColor = .red1
        lblAuthor.textAlignment = .center
		lblAuthor.adjustsFontSizeToFitWidth = true
		lblAuthor.minimumScaleFactor = 0.75
        
        return lblAuthor
    }()
    
    private let imgAuthorBackground = UIImageView(image: UIImage(named: "circle_initials")?.resizableImage(withCapInsets: UIEdgeInsets(top: 9.0, left: 11.0, bottom: 9.0, right: 11.0)))
    
    private let lblTitle: UILabel = {
        let lblTitle = UILabel()
        
        lblTitle.font = UIFont(type: .regular, size: 16.0)
        lblTitle.numberOfLines = 2
        lblTitle.textColor = .gray2
        lblTitle.textAlignment = .left
        
        return lblTitle
    }()
    
    private let lblInterpretation: UILabel = {
        let lblInterpretation = UILabel()
        
        lblInterpretation.font = interpretationFont
        lblInterpretation.numberOfLines = 0
        lblInterpretation.textColor = .gray1
        lblInterpretation.textAlignment = .left
        
        return lblInterpretation
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        
        contentView.clipsToBounds = true
        contentView.addSubviews(imgAuthorBackground, lblTitle, lblAuthor, lblInterpretation)
        
        activateConstraints(
            lblTitle.topItem == contentView.topItem + 8.0,
            lblTitle.trailingItem == contentView.trailingItem - 16.0,
            lblTitle.leadingItem == imgAuthorBackground.trailingItem + 8.0,
            
            imgAuthorBackground.leadingItem == contentView.leadingItem + 16.0,
            imgAuthorBackground.centerYItem == lblTitle.centerYItem,
            
            lblAuthor.centerYItem == imgAuthorBackground.centerYItem,
            imgAuthorBackground.leadingItem == lblAuthor.leadingItem - 3.0,
            imgAuthorBackground.trailingItem == lblAuthor.trailingItem + 3.0,
            
            lblInterpretation.topItem == lblTitle.bottomItem + 8.0,
            lblInterpretation.leadingItem == contentView.leadingItem + 16.0,
            lblInterpretation.trailingItem == contentView.trailingItem - 16.0
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblTitle.text = ""
        lblAuthor.text = ""
        lblInterpretation.text = ""
    }
    
    func fill(title: String, author: String, interpretation: String) {
        lblTitle.text = title
        lblAuthor.text = author
        lblInterpretation.text = interpretation
    }
    
	static func height(title: String, interpretation: String, width: CGFloat) -> CGFloat {
        let interpretationHeight = Style.heightOfText(interpretation, font: interpretationFont, width: width - 32.0)
		let titleHeight = Style.heightOfText(title, font: interpretationFont, width: width - 63.0)
        return titleHeight + interpretationHeight + 32.0
    }
    
}
