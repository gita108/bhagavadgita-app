//
//  ShlokasChapterContentsTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 05/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

protocol ShlokasChapterContentsTableViewCellDelegate {
	func didSelectCell(_ cell: ShlokasChapterContentsTableViewCell, itemIndex: Int)
}

final class ShlokasChapterContentsTableViewCell: ReusableTableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
    private var shlokas: [ShlokaEntryModel] = [ShlokaEntryModel]()
    private var selectedShloka: Int?
	
	var delegate: ShlokasChapterContentsTableViewCellDelegate?
	
    private let cvShlokas: UICollectionView = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0)
        collectionViewFlowLayout.minimumLineSpacing = 1.0
        collectionViewFlowLayout.minimumInteritemSpacing = 1.0
        
        let cvShlokas = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        cvShlokas.backgroundColor = .gray5
        cvShlokas.alwaysBounceVertical = false
        cvShlokas.allowsMultipleSelection = false
        
        ShlokaNumberCollectionViewCell.register(for: cvShlokas)
        
        return cvShlokas
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.clipsToBounds = true
		
        cvShlokas.dataSource = self
        cvShlokas.delegate = self
        
        contentView.addSubview(cvShlokas)

        activateConstraints(
            cvShlokas.edges()//.width(of: self)
        )
    }
	
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        cvShlokas.isHidden = true
		cvShlokas.alpha = 0
        selectedShloka = nil
    }
	
    func setBookmark(shlokaOrder: Int, bookmarked: Bool) {
		if let index = shlokas.index(where: { $0.order == shlokaOrder}) {
			shlokas[index].isBookmarked = bookmarked
		
		    cvShlokas.reloadItems(at: [IndexPath(item: index, section: 0)])
		}
    }
    
    func setSelection(shlokaNumber: Int) {
        cvShlokas.selectItem(at: IndexPath(item: shlokaNumber, section: 0), animated: false, scrollPosition: .centeredVertically)
        var items = [IndexPath(item: shlokaNumber, section: 0)]
        
        if let oldSelectionNumber = selectedShloka, oldSelectionNumber != shlokaNumber {
            items.append(IndexPath(item: oldSelectionNumber, section: 0))
        }
        selectedShloka = shlokaNumber

        cvShlokas.reloadItems(at: items)
    }
    
    func fill(shlokas: [ShlokaEntryModel], selectedShloka: Int?) {
//		cvShlokas.isHidden = false
		cvShlokas.alpha = 1

//		print("reload: \(shlokas.count)")
        self.shlokas = shlokas
        self.selectedShloka = selectedShloka
		
        cvShlokas.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shlokas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let collectionCell: ShlokaNumberCollectionViewCell = collectionView.dequeue(for: indexPath) as ShlokaNumberCollectionViewCell
		
		let shloka = shlokas[indexPath.row]
		
        var selected = false
        if let selectedShlokaInChapter = selectedShloka {
            selected = selectedShlokaInChapter == indexPath.row
        }
		
		let shlokaNumberParts = shloka.name.split(["."], removeSeparators: true, removeEmptyEntries: true)
		let shlokaNumber = shlokaNumberParts.last ?? shloka.name
        collectionCell.fill(title: shlokaNumber, bookmarked: shloka.isBookmarked, selected: selected)
        return collectionCell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ShlokasChapterContentsTableViewCell.sizeOfItem(for: collectionView.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selected = selectedShloka {
            let cell = cvShlokas.cellForItem(at: IndexPath(item: selected, section: 0))
            cell?.isHighlighted = false
        }
        
        selectedShloka = indexPath.row
        let cell = cvShlokas.cellForItem(at: IndexPath(item: selectedShloka!, section: 0))
        cell?.isHighlighted = true
        
        // Scroll to selected item
//        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
		
		delegate?.didSelectCell(self, itemIndex: selectedShloka!)
    }
	
	func invalidateLayout() {
		cvShlokas.collectionViewLayout.invalidateLayout()
	}
	
    // MARK: - Helpers
    private static func sizeOfItem(for width: CGFloat) -> CGSize {
        let widthPerItem = width / 7 - 2
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    static func height(for shlokasNumber: Int, width: CGFloat) -> CGFloat {
		var rows = shlokasNumber / 7 + (shlokasNumber % 7 != 0 ? 1 : 0)
        rows = min(rows, 4)
		
		//NOTE: cell spacing is 1 and section insets are 3.0 for all edges
        return CGFloat(rows) * (width / 7 - 1) + 6.0
    }
}
