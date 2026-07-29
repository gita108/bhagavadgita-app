//
//  ShlokaNumberCollectionViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 05/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

final class ShlokaNumberCollectionViewCell: ReusableCollectionViewCell {
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            imgSelected.isHidden = !newValue
            super.isHighlighted = newValue
        }
    }
    
    private let imgBookmarked = UIImageView(image: UIImage(named: "ic_bookmark_small"))
    
    private let imgSelected: UIImageView = {
        let solidColor = ImageManager.solid(color: .gray4, size: CGSize(width: 47.0, height: 47.0))
        let imgColor = UIImageView(image: solidColor)
        imgColor.layer.cornerRadius = 23.5
        imgColor.clipsToBounds = true
        return imgColor
    }()
    
    private let lblTitle: UILabel = {
        let lblTitle = UILabel()

		lblTitle.font = UIFont(type: .regular, size: 16.0)
		lblTitle.adjustsFontSizeToFitWidth = true
		lblTitle.minimumScaleFactor = 0.5
		
        lblTitle.textColor = .gray1
		
        lblTitle.textAlignment = .center
		lblTitle.baselineAdjustment = UIBaselineAdjustment.alignCenters
		
        return lblTitle
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubviews(imgSelected, imgBookmarked, lblTitle)
		
        activateConstraints(
            lblTitle.centerXItem == contentView.centerXItem,
            lblTitle.centerYItem == contentView.centerYItem,
            lblTitle.widthItem <= 39,
            lblTitle.heightItem == 39,
            
            imgSelected.centerXItem == contentView.centerXItem,
            imgSelected.centerYItem == contentView.centerYItem,
            
            imgBookmarked.topItem == imgSelected.topItem,
            imgBookmarked.trailingItem == imgSelected.trailingItem
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblTitle.text = ""
        imgBookmarked.isHidden = true
        imgSelected.isHidden = true
    }
    
    func fill(title: String, bookmarked: Bool, selected: Bool) {
        lblTitle.text = title
        imgBookmarked.isHidden = !bookmarked
        imgSelected.isHidden = !selected
    }

}
