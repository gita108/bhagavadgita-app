//
//  QuoteTableViewCell.swift
//  Gita
//
//  Created by Olga Zhegulo  on 01/03/2018.
//  Copyright © 2018 Iron Water Studio. All rights reserved.
//

import UIKit

protocol QuoteViewShareDelegate: class {
	func share(_ view: QuoteTableViewCell, quote: Quote)
	func open(_ view: QuoteTableViewCell, quote: Quote)
}

class QuoteTableViewCell: ReusableTableViewCell {

	var quote: Quote {
		didSet {
			self.lblText.text = quote.text
		}
	}
	
	weak var delegate: QuoteViewShareDelegate?
	
	private let lblTitle: UILabel = {
		let lbl = UILabel()
		lbl.font = UIFont(type: .regular, size: 18.0)
		lbl.textColor = .red1
		lbl.textAlignment = .center
		
		lbl.numberOfLines = 0
		lbl.lineBreakMode = .byWordWrapping
		
		lbl.text = Local("Contents.Quote.Title")
		
		return lbl
	}()
	
	let imgTitleSeparator = UIImageView(image: UIImage(named: "divider"))
	
	private let lblText: UILabel = {
		let lbl = UILabel()
		lbl.font = UIFont(type: .regular, size: 16.0)
		lbl.textColor = .gray1
		lbl.numberOfLines = 4
		
		return lbl
	}()
	
	private lazy var btnShare: UIButton = {
		let btn = UIButton(type: .custom)
		btn.setImage(UIImage(named: "ic_share"), for: .normal)
		
		btn.addTarget(self, action: #selector(btnShare_Click(_:)), for: .touchUpInside)
		
		return btn
	}()
	
	private lazy var btnOpen: UIButton = {
		let btn = UIButton(type: .custom)
		btn.backgroundColor = .clear
		btn.addTarget(self, action: #selector(btnOpen_Click(_:)), for: .touchUpInside)
		
		return btn
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		self.quote = Quote()
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.backgroundColor = .gray5
		
		self.addSubview(self.btnOpen)
		self.addSubview(self.lblTitle)
		self.addSubview(self.imgTitleSeparator)
		self.addSubview(self.lblText)
		self.addSubview(self.btnShare)
		
		activateConstraints(
			self.btnOpen.topItem == self.topItem,
			self.btnOpen.leadingItem == self.leadingItem,
			self.btnOpen.trailingItem == self.trailingItem,
			self.btnOpen.bottomItem == self.bottomItem,

			self.lblTitle.topItem == self.topItem + 20,
			self.lblTitle.leadingItem == self.leadingItem + 16,
			self.lblTitle.trailingItem == self.trailingItem - 16,
			
			self.imgTitleSeparator.topItem == self.lblTitle.bottomItem + 5,
			self.imgTitleSeparator.centerXItem == self.centerXItem,
			
			//Image is 24*24, top 10, right 17
			self.btnShare.topItem == self.topItem,
			self.btnShare.widthItem == 44,
			self.btnShare.heightItem == 44,
			self.btnShare.trailingItem == self.trailingItem - 7,
			
			self.lblText.topItem == self.imgTitleSeparator.bottomItem + 8,
			self.lblText.leadingItem == self.leadingItem + 16,
			self.lblText.trailingItem == self.trailingItem - 40,
			self.lblText.bottomItem == self.bottomItem - 16 ~ 750
		)
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.quote = Quote()
		super.init(coder: aDecoder)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		lblText.text = nil
	}
	
	func btnShare_Click(_ sender: UIButton) {
		self.delegate?.share(self, quote: self.quote)
	}
	
	func btnOpen_Click(_ sender: UIButton) {
		self.delegate?.open(self, quote: self.quote)
	}
	
	static func height(quote: Quote, width: CGFloat) -> CGFloat {
		let titleSize = Local("Contents.Quote.Title").size(width: width - 32.0, height: 9999, font: UIFont(type: .regular, size: 18.0))
		let textHeight = UIFont(type: .regular, size: 16.0).lineHeight * 4 + 0.5
		
		//10 is separator height
//		return 20.0 + titleSize.height + 5.0 + (UIImage(named: "ic_share")?.size.height ?? 0.0) + 8.0 + textHeight + 16.0
		return 20.0 + titleSize.height + 5.0 + 10.0 + 8.0 + textHeight + 16.0
	}

}
