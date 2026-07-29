//
//  BookmarkTableViewCell.swift
//  Gita
//
//  Created by Olga Zhegulo  on 16/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

class BookmarkTableViewCell: SwipeTableViewCell, ReusableTableViewCellProtocol {

	private var cTitleBottom: NSLayoutConstraint?
	
	private let lblTitle : UILabel = {
		let lbl = Style.settingsTitleLabel()
		lbl.numberOfLines = 0
		lbl.lineBreakMode = .byTruncatingTail
		lbl.textAlignment = .left
		return lbl
	}()
	
	private let vComment = UIView()
	
    private let lblComment : UILabel = {
        let lbl = UILabel()
        
        lbl.font = UIFont(type: .italic, size: 14.0)
        lbl.textColor = .gray2
        lbl.textAlignment = .left
        lbl.numberOfLines = 3
        
        return lbl
    }()

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.backgroundColor = .white
		
		self.selectionStyle = .none
		self.separatorInset = UIEdgeInsets.zero
		
		contentView.addSubview(lblTitle)
		contentView.addSubview(vComment)
		
		let imgComment = UIImageView(image: UIImage(named: "ic_commented_small"))
		vComment.addSubview(imgComment)
		
		vComment.addSubview(lblComment)
		
		cTitleBottom = (vComment.topItem == lblTitle.bottomItem + 8)
		
		activateConstraints(
			lblTitle.topItem == contentView.topItem + 12,
			lblTitle.leadingItem == contentView.leadingItem + 16,
			lblTitle.trailingItem == contentView.trailingItem - 16,
			
			cTitleBottom!,
			vComment.leadingItem == contentView.leadingItem,
			vComment.trailingItem == contentView.trailingItem,
			vComment.bottomItem == contentView.bottomItem - 16,
			
			lblComment.topItem == vComment.topItem,
			lblComment.leadingItem == vComment.leadingItem + 47,
			lblComment.trailingItem == vComment.trailingItem - 16,
			lblComment.bottomItem == vComment.bottomItem,
			
			imgComment.leadingItem == vComment.leadingItem + 16,
			imgComment.topItem == lblComment.topItem + 4,
			imgComment.widthItem == 18,
			imgComment.heightItem == 18
		)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func fill(_ bookmark: BookmarkModel) {
		//NOTE: name could be 1.32-34
		lblTitle.text = "\(bookmark.name) \(bookmark.chapterName)"
		
		if bookmark.comment.count > 0 {
			vComment.isHidden = false
			
			//Set text with custom linespacing
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 8.0
			
			let attrString = NSMutableAttributedString(string: bookmark.comment)
			attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))

			lblComment.attributedText = attrString
			cTitleBottom?.constant = 8
		} else {
			vComment.isHidden = true

			lblComment.attributedText = nil
			cTitleBottom?.constant = -4
		}
	}
	
	func fill(_ shloka: ShlokaModel) {
		//NOTE: name could be 1.32-34
		lblTitle.text = "\(shloka.name) \(shloka.title)"
		
		vComment.isHidden = true
		
		lblComment.attributedText = nil
		cTitleBottom?.constant = -4
	}
}
