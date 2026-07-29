//
//  CommentViewController.swift
//  Gita
//
//  Created by mikhail.kulichkov on 25/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

protocol CommentViewControllerDelegate {
	func didChangedComment(controller: CommentViewController, comment: String)
}

final class CommentViewController: UIViewController {
	
	var comment: String? {
		get	{ return self.txtComment.text?.trim() }
		set { self.txtComment.text = newValue }
	}
	
	var delegate: CommentViewControllerDelegate
	let chapterOrder: Int
	let shlokaOrder: Int
	
	lazy var txtComment: UITextView = {
		let textView = UITextView()
		
		textView.font = UIFont(type: .regular, size: 16.0)
		textView.backgroundColor = .clear
		textView.textColor = .gray1
		textView.tintColor = .gray1
		
		textView.showsHorizontalScrollIndicator = false
		textView.isDirectionalLockEnabled = true
		textView.textContainerInset = UIEdgeInsets(top: 8, left: 13, bottom: 16, right: 13)
		
		return textView
	}()
	
	init(comment: String, delegate: CommentViewControllerDelegate, chapterOrder: Int, shlokaOrder: Int) {

		self.delegate = delegate
		self.shlokaOrder = shlokaOrder
		self.chapterOrder = chapterOrder
		
		super.init(nibName: nil, bundle: nil)
		
		self.comment = comment
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		self.view = UIView()
		
		view.backgroundColor = .gray5
		
		view.addSubview(txtComment)
		
		activateConstraints(
			txtComment.topItem == view.topItem,
			txtComment.leadingItem == view.leadingItem,
			txtComment.trailingItem == view.trailingItem,
			txtComment.bottomItem == view.bottomItem
		)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(btnBack_Click))
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: Local("Comment.Save"), style: .plain, target: self, action: #selector(btnSave_Click))

		navigationItem.title = Local("Comment.Title")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//Shift screen when keyboard displayed
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
		
		GAHelper.logScreen(String(describing: type(of: self)))
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		//Show keyboard in this event because in viewDidLoad or viewWillAppear causes flickering
		self.txtComment.becomeFirstResponder()
		
		//Put cursor at the beginning of text
		txtComment.selectedRange = NSMakeRange(0, 0)
	}

	// MARK: - Keyboard notifications
	@objc public func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
			self.txtComment.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: keyboardSize.height, right: 16)
			self.txtComment.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
		}
	}
	
	@objc public func keyboardWillHide(notification: NSNotification) {
		self.txtComment.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		self.txtComment.scrollIndicatorInsets = .zero
	}
	
	// MARK: - Actions
	func btnBack_Click() {
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	func btnSave_Click() {
		
		GAHelper.logEventWithCategory(GAHelper.GoogleAnaliticsCategoryUI, action: "Edited user comment")
		
		UserComment.updateUserComment(chapterOrder: chapterOrder, shlokaOrder: shlokaOrder, text: comment ?? String())
		
		delegate.didChangedComment(controller: self, comment: comment ?? String())
		_ = self.navigationController?.popViewController(animated: true)
	}
}
