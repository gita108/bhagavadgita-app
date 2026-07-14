//
//  ShlokaHeaderTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 30/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

fileprivate let shlokaNumberFont = UIFont.boldSystemFont(ofSize: 24.0)
fileprivate let shlokaTitleFont = UIFont(type: .bold, size: 20.0)
typealias ShlokaNavAction = () -> ()

protocol ShlokaHeaderTableViewCellDelegate: class {
	func didSelectNextShloka(_ cell: ShlokaHeaderTableViewCell)
	func didSelectPreviousShloka(_ cell: ShlokaHeaderTableViewCell)
}

final class ShlokaHeaderTableViewCell: ReusableTableViewCell {
	
	var previousIsEnabled: Bool = true
	var nextIsEnabled: Bool = true
	weak var delegate: ShlokaHeaderTableViewCellDelegate?
	
	private lazy var btnPrevious: UIButton = {
		let btnPrevious = UIButton()
		btnPrevious.setBackgroundImage(UIImage(named: "left"), for: .normal)
		btnPrevious.addTarget(self, action: #selector(btnPreviousPressed), for: .touchUpInside)
		return btnPrevious
	}()
	
	private lazy var btnNext: UIButton = {
		let btnPrevious = UIButton()
		btnPrevious.setBackgroundImage(UIImage(named: "right"), for: .normal)
		btnPrevious.addTarget(self, action: #selector(btnNextPressed), for: .touchUpInside)
		return btnPrevious
	}()
	
	private let lblShlokaNumber: UILabel = {
		let lblShlokaNumber = UILabel()
		
		lblShlokaNumber.font = shlokaNumberFont
		lblShlokaNumber.textColor = .gray1
		lblShlokaNumber.textAlignment = .center
		
		return lblShlokaNumber
	}()
	
	private let lblShlokaTitle: UILabel = {
		let lblShlokaTitle = UILabel()
		
		lblShlokaTitle.font = shlokaTitleFont
		lblShlokaTitle.textColor = .gray1
		lblShlokaTitle.textAlignment = .center
		lblShlokaTitle.numberOfLines = 0
		
		return lblShlokaTitle
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        
        contentView.addSubviews(btnPrevious,
                                btnNext,
                                lblShlokaNumber,
                                lblShlokaTitle)

        activateConstraints(
            lblShlokaNumber.centerXItem == contentView.centerXItem,
            lblShlokaNumber.topItem == contentView.topItem + 14.0,
            
            btnPrevious.centerYItem == lblShlokaNumber.centerYItem,
            btnPrevious.leadingItem == contentView.leadingItem + 16.0,
            
            btnNext.centerYItem == lblShlokaNumber.centerYItem,
            btnNext.trailingItem == contentView.trailingItem - 16.0,
            
            lblShlokaTitle.topItem == lblShlokaNumber.bottomItem,
            lblShlokaTitle.leadingItem == contentView.leadingItem + 56.0,
            lblShlokaTitle.trailingItem == contentView.trailingItem - 56.0
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	func fill(number: String, title: String, delegate: ShlokaHeaderTableViewCellDelegate, previousIsEnabled: Bool, nextIsEnabled: Bool) {
		
		self.nextIsEnabled = nextIsEnabled
		self.previousIsEnabled = previousIsEnabled
		self.delegate = delegate
		
		btnPrevious.isHidden = !previousIsEnabled
		btnNext.isHidden = !nextIsEnabled

		lblShlokaNumber.text = number
		lblShlokaTitle.text = title
	}

    // MARK: - Actions
    @objc private func btnPreviousPressed() {
		if previousIsEnabled {
			delegate?.didSelectPreviousShloka(self)
		}
    }
    
    @objc private func btnNextPressed() {
		if nextIsEnabled {
			delegate?.didSelectNextShloka(self)
		}
    }
    
    // MARK: - Helpers
    static func height(title: String, width: CGFloat) -> CGFloat {
        let titleHeight = Style.heightOfText(title, font: shlokaTitleFont, width: width - 112.0)
        
        return titleHeight + 50.0
    }
}

