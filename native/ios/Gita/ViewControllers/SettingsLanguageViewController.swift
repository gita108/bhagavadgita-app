//
//  SettingsLanguageViewController.swift
//  Gita
//
//  Created by mikhail.kulichkov on 04/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

protocol SettingsLanguageViewControllerDelegate {
	func didSelectedlanguages(languages: [Language])
}

final class SettingsLanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var delegate: SettingsLanguageViewControllerDelegate
    var languages = [Language]()
    
    let tableView = UITableView()
	
	init(delegate: SettingsLanguageViewControllerDelegate) {
		self.delegate = delegate
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
        self.view = UIView()
        let tableViewSideOffset: CGFloat = UIDevice.isIPad ? 128.0 : 0.0
        
        view.backgroundColor = .gray5
        
        view.addSubview(tableView)
                
        activateConstraints(
            tableView.leadingItem == view.leadingItem + tableViewSideOffset,
            tableView.trailingItem == view.trailingItem - tableViewSideOffset,
            tableView.topItem == view.topItem,
            tableView.bottomItem == view.bottomItem
        )
    }
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.delegate = self
        tableView.dataSource = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(leftBarButtonItemPressed))
        navigationItem.title = Local("Settings.Language.Navigation.Title")
        
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.tableFooterView = UIView()
        LanguageSettingsTableViewCell.register(for: tableView)
    }
    	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//Analytics.logEvent(AnalyticsEventViewItem, parameters: [AnalyticsParameterItemName : String(describing: type(of: self))])
		GAHelper.logScreen(String(describing: type(of: self)))
	}

	func leftBarButtonItemPressed() {
		delegate.didSelectedlanguages(languages: languages.filter { $0.isSelected } )
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		let language = languages[indexPath.row]
		return language.id != Settings.shared.defaultLanguageId ? indexPath : nil
	}
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let language = languages[indexPath.row]
		language.isSelected = !language.isSelected
		//Save selected language to DB
		language.updateSelected()
		
		tableView.deselectRow(at: indexPath, animated: true)
		tableView.reloadRows(at: [indexPath], with: .automatic)
    }
	
    // Return the row for the corresponding section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LanguageSettingsTableViewCell = tableView.dequeue(for: indexPath)
        cell.fill(language: languages[indexPath.row].name, checked: languages[indexPath.row].isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
