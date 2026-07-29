//
//  ShlokaSeparatorTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 30/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

final class ShlokaSeparatorTableViewCell: ReusableTableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: nil)
        
        let imgTitleSeparator = UIImageView(image: UIImage(named: "divider"))
        
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        
        contentView.addSubview(imgTitleSeparator)
        
        activateConstraints(
            imgTitleSeparator.centerXItem == contentView.centerXItem,
            imgTitleSeparator.centerYItem == contentView.centerYItem
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Helpers
    
    static func height() -> CGFloat {
        return (UIImage(named: "divider")?.size.height)! + 16.0
    }
    
}
