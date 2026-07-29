//
//  QuoteView.swift
//  Gita
//
//  Created by Olga Zhegulo  on 01/03/2018.
//  Copyright © 2018 Iron Water Studio. All rights reserved.
//

import UIKit

protocol QuoteViewShareDelegate: class {
	func share(_ view: QuoteView, quote: Quote)
	func open(_ view: QuoteView, quote: Quote)
}

class QuoteView: UIView {

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
		btn.addTarget(self, action: #selector(btnOpen_Click(_:)), for: .touchUpInside)
		
		return btn
	}()
	
	override init(frame: CGRect) {
		self.quote = Quote()
		
		super.init(frame: frame)
		
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
		fatalError("init(coder:) has not been implemented")
	}
	
	func btnShare_Click(_ sender: UIButton) {
		self.delegate?.share(self, quote: self.quote)
	}
	
	func btnOpen_Click(_ sender: UIButton) {
		self.delegate?.open(self, quote: self.quote)
	}
}
