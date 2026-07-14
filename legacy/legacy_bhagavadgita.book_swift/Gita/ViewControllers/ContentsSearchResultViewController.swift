//
//  RomanSearchResultViewController.swift
//  SearchViewController
//
//  Created by Stanislav.Grinberg on 22/03/2018.
//  Copyright © 2018 Stanislav.Grinberg. All rights reserved.
//

import UIKit

protocol SearchResultsDelegate: class {
	func searchResults(_ searchResultViewController: ContentsSearchResultViewController, didSelectValue value: Any?)
}

class ContentsSearchResultViewController: UIViewController, /*UISearchResultsUpdating,*/ UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

	private var filteredItems: [ShlokaModel] = []
	
	private lazy var tblSearch: UITableView = {
		let tblView = UITableView().background(.white)
		
		BookmarkTableViewCell.register(for: tblView)
		tblView.rowHeight = UITableViewAutomaticDimension
		
		tblView.dataSource = self
		tblView.delegate = self
		
		tblView.tableFooterView = UIView()
		
		return tblView
	}()

	private let emptyView = EmptyBookmarksView().background(.white)

	var searchController: UISearchController?

	weak var delegate: SearchResultsDelegate?
	
	// MARK: - Life cycle
	
	init(delegate: SearchResultsDelegate?) {
		self.delegate = delegate
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		self.view = UIView().background(.clear)
	}
	
	override func viewDidLoad() {
		title = "Results"
		
		definesPresentationContext = true
		
		view.addSubviews(tblSearch)
		view.addSubview(emptyView)
		
		emptyView.isHidden = true
		
		if #available(iOS 11, *) {
			tblSearch.contentInsetAdjustmentBehavior = .never
			NSLayoutConstraint.activate([
				tblSearch.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
				emptyView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
				])
			
			activateConstraints(
				tblSearch.dockBottom(),
				emptyView.dockBottom()
			)
		} else {
			activateConstraints(
				tblSearch.edges(),
				emptyView.edges()
			)
		}
	}
	
	override func viewDidLayoutSubviews() {
		//Fix extra padding (table content inset) in the top of results table
		if #available(iOS 11.0, *) {
			
			if UIDevice.deviceName == .iPhoneX {
				//Make inset same as search bar
				tblSearch.contentInset = UIEdgeInsetsMake(searchController?.searchBar.frame.size.height ?? 0, 0, 0, 0)
			} else {
				//NOTE: if presenting controller is UINavigationVC (fullcsreen), make inset same as navigation bar
				tblSearch.contentInset = UIEdgeInsetsMake(self.presentingViewController?.navigationController?.navigationBar.frame.size.height ?? ((self.presentingViewController as? UINavigationController)?.navigationBar.frame.size.height ?? 0), 0, 0, 0)
			}
			
//			print("tblSearch.contentInset:", tblSearch.contentInset,
//				  "search bar:", searchController?.searchBar.frame.size.height ?? 0,
//					"nav bar", (self.presentingViewController as? UINavigationController)?.navigationBar.frame.size.height ?? 0 )
		}
	}

	// MARK: - Private
	
	func isFiltering() -> Bool {
		return searchController?.isActive ?? false && !searchBarIsEmpty()
	}
	
	func searchBarIsEmpty() -> Bool {
		// Returns true if the text is empty or nil
		return searchController?.searchBar.text?.isEmpty ?? true
	}
	
	func filterData(_ filter: String?) {
		
		if String.isNilOrWhiteSpace(filter) {
			filteredItems = [ShlokaModel]()
		} else {
			filteredItems = ShlokaModel.search(query: filter!, bookId: Settings.shared.defaultBookId)
		}
		
		/*
		let oldFilter = self.filter
		self.filter = filter
		
		if String.isNilOrWhiteSpace(filter) {
			filteredItems = items
		} else {
			filteredItems = items.filter({ (shloka: ShlokaModel) -> Bool in
				bookmark.chapterName.contains(filter!) || bookmark.comment.contains(filter!)
			})
		}
		
//		if (oldFilter ?? String()).trim() != (filter ?? String()).trim(){*/
			let areDataEmpty = filteredItems.count == 0
			emptyView.isHidden = !areDataEmpty
			tblSearch.isHidden = areDataEmpty
			tblSearch.reloadData()
//		}
	}
	
	// MARK: - UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: BookmarkTableViewCell = tableView.dequeue(for: indexPath)
		
		let item: ShlokaModel = filteredItems[indexPath.row]
		cell.fill(item)
		
		return cell
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let item: ShlokaModel = filteredItems[indexPath.row]
		delegate?.searchResults(self, didSelectValue: item)
	}
	
	// MARK: - UISearchResultsUpdating
	/*
	func updateSearchResults(for searchController: UISearchController) {
		guard let searchText = searchController.searchBar.text,
			searchText.count > 2 else { return }

		print("updateSearchResults: \(searchText)")

		filterData(searchText)
	}*/
	
	// MARK: - UISearchBarDelegate

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		//Apply query
//		print("searchBarSearchButtonClicked")
		filterData(searchBar.text)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.count == 0 {
			//Deleted all symbols or pressed Clear button, Search button is disabled
//			print("cleared search")
			filterData(searchText)
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//		print("searchBarCancelButtonClicked")
		//Reset query
		filterData(nil)
	}
	
	// MARK: - Static
	
	static func create(with delegate: SearchResultsDelegate?) -> UISearchController {
		let searchResultsViewController = ContentsSearchResultViewController(delegate: delegate)
		
		let searchController = UISearchController(searchResultsController: searchResultsViewController)
		//NOTE: search results ar updated only after Search button clicked, not when query changed
//		searchController.searchResultsUpdater = searchResultsViewController
		
		if #available(iOS 9.1, *) {
			searchController.obscuresBackgroundDuringPresentation = true
		} else {
			// Fallback on earlier versions
		}
		searchController.dimsBackgroundDuringPresentation = true
		searchController.hidesNavigationBarDuringPresentation = false
		
		searchController.searchBar.delegate = searchResultsViewController
		//No capitalization
		searchController.searchBar.autocapitalizationType = .none
		//Appearance
		searchController.searchBar.barTintColor = .red1
		//White cancel button
		searchController.searchBar.tintColor = .white
		//Blue cursor for search text
		UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .blue
		searchController.searchBar.placeholder = Local("Contents.Search.Placeholder")
		searchController.searchBar.sizeToFit()

		searchResultsViewController.searchController = searchController
		return searchController
	}
	
}
