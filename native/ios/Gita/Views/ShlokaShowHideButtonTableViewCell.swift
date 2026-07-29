//
//  ShlokaShowHideButtonTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 23/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

final class ShlokaShowHideButtonTableViewCell: UITableViewCell {
    
    private let btnShowHide: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "btn")?.resizableImage(withCapInsets: UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0))
        button.setBackgroundImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 3.0, bottom: 0.0, right: 3.0)
        return button
    }()
    
    private let action: () -> ()
    
    init(title: String, action: @escaping () -> ()) {
        
        self.action = action
        
        super.init(style: .default, reuseIdentifier: nil)
        
        btnShowHide.addTarget(self, action: #selector(btnShowHidePressed), for: .touchUpInside)
        
        setButtonTitle(title)
        
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        
        contentView.addSubview(btnShowHide)
        
        activateConstraints(
            btnShowHide.centerYItem == contentView.centerYItem,
            btnShowHide.heightItem == 44.0,
            btnShowHide.leadingItem == contentView.leadingItem + 30.0,
            btnShowHide.trailingItem == contentView.trailingItem - 30.0
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setButtonTitle(_ title: String) {
        let attributes: [String: Any] = [
            NSFontAttributeName : UIFont(type: .regular, size: 18.0),
            NSForegroundColorAttributeName : UIColor.red1
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        btnShowHide.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    @objc
    private func btnShowHidePressed() {
        action()
    }
}
