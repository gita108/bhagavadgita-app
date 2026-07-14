//
//  QuoteViewController.swift
//  Gita
//
//  Created by Olga Zhegulo  on 07/03/2018.
//  Copyright © 2018 Iron Water Studio. All rights reserved.
//

import UIKit

class QuoteViewController: UIViewController {

	var quote: Quote {
		didSet {
			self.fill(quote)
		}
	}
	
	private let svContent = UIScrollView()
	private let contentView = UIView()
	
	private let lblText: UILabel = {
		let lbl = UILabel()
		lbl.font = UIFont(type: .regular, size: 16.0)
		lbl.textColor = .gray1
		lbl.numberOfLines = 0
		
		return lbl
	}()
	
	private let lblAuthor: UILabel = {
		let lbl = UILabel()
		lbl.font = UIFont(type: .italic, size: 14.0)
		lbl.textColor = .gray2
		lbl.numberOfLines = 0
		
		return lbl
	}()
	
	required init(quote: Quote) {
		self.quote = quote
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		self.view = UIView()
		
		self.view.backgroundColor = .white
		
		self.view.addSubview(self.svContent)
		self.svContent.addSubview(self.contentView)
		
		self.contentView.addSubview(self.lblText)
		self.contentView.addSubview(self.lblAuthor)
		
		activateConstraints(
			self.svContent.edges(),

			self.contentView.top(),
			self.contentView.leading(),
			self.contentView.width(of: self.svContent),
			self.contentView.bottom(),

			self.lblText.top(16),
			self.lblText.leading(16),
			self.lblText.trailing(16),
			
			self.lblAuthor.pinTop(16, to: self.lblText),
			self.lblAuthor.leading(16),
			self.lblAuthor.trailing(16),
			self.lblText.bottom(16)
		)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

        self.title = Local("Contents.Quote.Title")
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(btnBack_Click))
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_share"), style: .plain, target: self, action: #selector(btnShare_Click))
		
		self.fill(self.quote)
    }

	//MARK: - Method
	func fill(_ quote: Quote) {
		self.lblText.text = quote.text
		self.lblAuthor.text = quote.author
	}
	
	//MARK: - Action
	func btnBack_Click() {
		_ = self.navigationController?.popViewController(animated: true)
	}

	func btnShare_Click(_ sender: UIButton) {
		let activityVC = UIActivityViewController(activityItems: [quote.text + "\n" + quote.author], applicationActivities: nil)
		
		if UIDevice.isIPad, let popover = activityVC.popoverPresentationController {
			popover.sourceRect = self.view.bounds
			popover.sourceView = self.view
			popover.permittedArrowDirections = [.left]
		}
		self.present(activityVC, animated: true)
	}
 }
