//
//  LanguageSettingsTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 04/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

final class LanguageSettingsTableViewCell: ReusableTableViewCell {
    
    private let lblTitle: UILabel = Style.settingLabel()
    private let imgCheck: UIImageView = UIImageView(image: UIImage(named: "ic_check"))
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(imgCheck)
        addSubview(lblTitle)
        
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        imgCheck.translatesAutoresizingMaskIntoConstraints = false
        
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        
        activateConstraints(
            lblTitle.centerYItem == self.centerYItem,
            lblTitle.leadingItem == self.leadingItem + 16.0,
            
            imgCheck.centerYItem == self.centerYItem,
            imgCheck.trailingItem == self.trailingItem - 20.0
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblTitle.text = ""
        imgCheck.isHidden = true
    }
    
    
    func fill(language: String, checked: Bool) {
        lblTitle.text = language
        imgCheck.isHidden = !checked
    }
}
