//
//  BookmarksViewController.swift
//  Gita
//
//  Created by Olga Zhegulo  on 15/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

class BookmarksViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate, ShlokaDelegate {

	var bookmarks = [BookmarkModel]()
	var filteredBookmarks = [BookmarkModel]()
	var filter : String? = nil
	
	var delegate: ShlokaDelegate
	
	init(delegate: ShlokaDelegate) {
		self.delegate = delegate
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private lazy var searchBar : UISearchBar = {
		let searchBar = UISearchBar()
		
		//No capitalization
		searchBar.autocapitalizationType = .none

		//Outer part color
		searchBar.barTintColor = .gray5
		
		//Remove line below
		searchBar.backgroundImage = UIImage()
		
		//Cursor color
		searchBar.tintColor = .gray1
		
		//Custom icon
		// TODO: probably not needed
		searchBar.setImage(UIImage(named: "icon-search"), for: .search, state: .normal)
		
		for view : UIView in (searchBar.subviews[0]).subviews {
			
			if let textField = view as? UITextField {
				//Text font
				// TODO: probably not needed
				textField.font = UIFont(name: UIFont.PTSans.regular.fontName, size: 14.0)
				textField.textColor = .gray1
				
				//Search text background
				textField.backgroundColor = .gray4
				
				//Placeholder with same color as search icon
				// TODO: probably not needed
				let attributes: [String: Any] = [
					NSForegroundColorAttributeName: UIColor.gray6,
					NSFontAttributeName : UIFont(name: UIFont.PTSans.regular.fontName, size: 14.0) as Any
				]
				
				textField.attributedPlaceholder = NSAttributedString(string: Local("Bookmarks.Placeholder"), attributes:attributes)
			}
		}
		//TODO: remove if do not customize placeholder
		//searchBar.placeholder = "Поиск"
		
		searchBar.delegate = self
		
		return searchBar
	}()
	
	private lazy var tblBookmarks: UITableView = {
		let table = UITableView()
		table.dataSource = self
		table.delegate = self
		
		table.rowHeight = UITableViewAutomaticDimension
		table.estimatedRowHeight = 66
		
		BookmarkTableViewCell.register(for: table)
		
		table.tableFooterView = UIView()
		
		return table
	}()
	
	private let emptyView = EmptyBookmarksView()
	
	override func loadView() {
		self.view = UIView()
		
		view.backgroundColor = .gray5
		
		view.addSubview(searchBar)
		view.addSubview(emptyView)
		
		//Hide keyboard button; above empty view, but below table
		let btnLostFocus = UIButton(type: .custom)
		btnLostFocus.addTarget(self, action: #selector(btnLostFocus_Click), for: .touchUpInside)
		view.addSubview(btnLostFocus)
		
		view.addSubview(tblBookmarks)
		
		activateConstraints(
			searchBar.topItem == view.topItem,
			searchBar.leadingItem == view.leadingItem,
			searchBar.trailingItem == view.trailingItem,
			
			btnLostFocus.topItem == searchBar.bottomItem,
			btnLostFocus.leadingItem == view.leadingItem,
			btnLostFocus.trailingItem == view.trailingItem,
			btnLostFocus.bottomItem == view.bottomItem,

			tblBookmarks.topItem == searchBar.bottomItem,
			tblBookmarks.leadingItem == view.leadingItem,
			tblBookmarks.widthItem == view.widthItem,
			tblBookmarks.bottomItem == view.bottomItem,
			
			emptyView.topItem == searchBar.bottomItem,
			emptyView.leadingItem == view.leadingItem,
			emptyView.widthItem == view.widthItem,
			emptyView.bottomItem == view.bottomItem
		)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(btnBack_Click))
		navigationItem.title = Local("Bookmarks.Navigation.Title")
		
		loadData()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		GAHelper.logScreen(String(describing: type(of: self)))
	}
	
    // MARK: - Actions
	func btnBack_Click() {
		_ = self.navigationController?.popViewController(animated: true)
	}

	func btnLostFocus_Click(sender: UIButton) {
		searchBar.endEditing(true)
	}

	//MARK: - UITableViewDelegate, UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredBookmarks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: BookmarkTableViewCell = tableView.dequeue(for: indexPath)
		cell.fill(filteredBookmarks[indexPath.row])
		
		//For custom delete button (by SwipeTableViewCell)
		cell.delegate = self
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//Hide keyboard
		searchBar.resignFirstResponder()
		
		//Open selected shloka
		let item = filteredBookmarks[indexPath.row]
		self.delegate.openShloka(from: self, chapterOrder: item.chapterOrder, shlokaOrder: item.shlokaOrder)
	}

//	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//		if editingStyle == .delete {
//			
//			let deletedItem = filteredBookmarks[indexPath.row]
//			self.filteredBookmarks.remove(at: indexPath.row)
//			
//			if let index = bookmarks.index(where: { (bookmark) -> Bool in
//				return bookmark.shlokaOrder == deletedItem.shlokaOrder && bookmark.chapterOrder == deletedItem.chapterOrder
//			}) {
//				bookmarks.remove(at: index)
//			}
//			
//			//Make shloka not bookmarked in DB
//			Bookmark.updateBookmarked(chapterOrder: deletedItem.chapterOrder, shlokaOrder: deletedItem.shlokaOrder, bookmarked: false)
//			
//			// and in parent screen
//			self.delegate.deleteBookmark(self, chapterOrder: deletedItem.chapterOrder, shlokaOrder: deletedItem.shlokaOrder)
//			
//			tableView.deleteRows(at: [indexPath], with: .automatic)
//		}
//	}
	
	// MARK: - SwipeTableViewCellDelegate
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		guard orientation == .right else { return nil }
		
		let deleteAction = SwipeAction(style: .default, title: nil) { [unowned self] action, indexPath in
			let deletedItem = self.filteredBookmarks[indexPath.row]
			self.filteredBookmarks.remove(at: indexPath.row)
			
			if let index = self.bookmarks.index(where: { (bookmark) -> Bool in
				return bookmark.shlokaOrder == deletedItem.shlokaOrder && bookmark.chapterOrder == deletedItem.chapterOrder
			}) {
				self.bookmarks.remove(at: index)
			}
			
			//Make shloka not bookmarked in DB
			Bookmark.updateBookmarked(chapterOrder: deletedItem.chapterOrder, shlokaOrder: deletedItem.shlokaOrder, bookmarked: false)
			
			// and in parent screen
			self.delegate.toggledBookmark(from: self, chapterOrder: deletedItem.chapterOrder, shlokaOrder: deletedItem.shlokaOrder, bookmarked: false)
			
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
		
		// customize the action appearance
		deleteAction.image = UIImage(named: "ic_delete")
		deleteAction.backgroundColor = UIColor.red1
		
		return [deleteAction]
	}
	
	//MARK: - UISearchBarDelegate
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		//Apply query
		filterData(searchBar.text)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.count == 0 {
			//Deleted all symbols or pressed Clear button, Search button is disabled
			filterData(searchText)
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		//Reset query
		filterData(nil)
	}
	
	//MARK: - ShlokaDelegate
	
	func toggledBookmark(from controller: UIViewController, chapterOrder: Int, shlokaOrder: Int, bookmarked: Bool) {
		//TODO: to keep visual effect on delete same as for swipe delete, delete row
		self.loadData()
		
		self.delegate.toggledBookmark(from: controller, chapterOrder: chapterOrder, shlokaOrder: shlokaOrder, bookmarked: bookmarked)
	}
	
	func shlokaViewControllerDidSelectNext(_ shlokaVC: ShlokaViewController) {
		self.delegate.shlokaViewControllerDidSelectNext(shlokaVC)
	}
	
	func shlokaViewControllerDidSelectPrevious(_ shlokaVC: ShlokaViewController) {
		self.delegate.shlokaViewControllerDidSelectPrevious(shlokaVC)
	}
	
	//MARK: - Methods
	func loadData() {
		self.bookmarks = BookmarkModel.loadAll()
		filterData(filter, reload: true)
	}
	
	func filterData(_ filter: String?, reload: Bool = false) {
		
		let oldFilter = self.filter
		self.filter = filter
		
		if String.isNilOrWhiteSpace(filter) {
			filteredBookmarks = bookmarks
		} else {
			filteredBookmarks = bookmarks.filter({ (bookmark: BookmarkModel) -> Bool in
				bookmark.chapterName.contains(filter!) || bookmark.comment.contains(filter!)
			})
		}
		
		if reload || (oldFilter ?? String()).trim() != (filter ?? String()).trim() {
			let areDataEmpty = filteredBookmarks.count == 0
			emptyView.isHidden = !areDataEmpty
			tblBookmarks.isHidden = areDataEmpty
			tblBookmarks.reloadData()
		}
	}
}
