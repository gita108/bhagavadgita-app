//
//  InterpretationSettingsTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 28/04/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

protocol InterpretationSettingsTableViewCellDelegate {
	func interpretationDidSelectedDownload(_ cell: InterpretationSettingsTableViewCell)
}

final class InterpretationSettingsTableViewCell: SwipeTableViewCell, ReusableTableViewCellProtocol {
    
	var downloadDelegate: InterpretationSettingsTableViewCellDelegate?

    private let lblTitle: UILabel = Style.settingLabel()
//    private let btnDownload = ProgressButton(text: Local("Settings.Interpretations.Download.Title"), completedImageName: "ic_check")
	private let btnDownload : UIButton = {
		let btn = UIButton()
		Style.applyBorderedButtonStyle(button: btn, text: Local("Settings.Interpretations.Download.Title"))
		return btn
	}()

	private let imgCheck = UIImageView(image: UIImage(named: "ic_check"))
	
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        lblTitle.numberOfLines = 0
        btnDownload.addTarget(self, action: #selector(btnDownloadPressed), for: .touchUpInside)

        contentView.addSubviews(lblTitle, btnDownload, imgCheck)
		
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        
		imgCheck.isUserInteractionEnabled = false
		
        activateConstraints(
            
            lblTitle.centerYItem == contentView.centerYItem,
            lblTitle.leadingItem == contentView.leadingItem + 16.0,
			lblTitle.topItem == contentView.topItem + 8.0,
            
            btnDownload.centerYItem == contentView.centerYItem,
            btnDownload.trailingItem == contentView.trailingItem - 20.0,
            btnDownload.heightItem == 30.0,
            btnDownload.widthItem == 100.0,
            btnDownload.leadingItem >= (lblTitle.trailingItem + 18.0),
			
			imgCheck.trailingItem == btnDownload.trailingItem,
			imgCheck.centerYItem == contentView.centerYItem
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblTitle.attributedText = NSAttributedString()
		//Delegate for swipe
        delegate = nil
		
		//Reset download button
		btnDownload.isHidden = true
		imgCheck.isHidden = true
		btnDownload.isUserInteractionEnabled = true
    }
    
	func fill(title: String, isDownloaded: Bool, isDownloading: Bool) {
        lblTitle.text = title

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
			self.btnDownload.isHidden = isDownloaded
			self.imgCheck.isHidden = !isDownloaded || isDownloading
		
			Style.applyBorderedButtonStyle(button: self.btnDownload, text: isDownloading ? Local("Settings.Downloading") : Local("Settings.Interpretations.Download.Title"))
//			self.btnDownload.configure(isDownloaded: isDownloaded, downloadDetails: downloadInfo)
		})
    }
	
	func showProgress() {
		Style.applyBorderedButtonStyle(button: btnDownload, text: Local("Settings.Downloading"))
		btnDownload.isUserInteractionEnabled = false
		imgCheck.isHidden = true
//		btnDownload.setTitle(Local("Settings.Downloading"), for: .normal)
	}
	
//	func setProgress(_ progress: Float) {
//		btnDownload.setProgress(progress: progress, color: .red1)
//	}
	
	func hideProgress(success: Bool) {
		if success {
//			btnDownload.configure(isDownloaded: success, downloadDetails: nil)
		} else {
			Style.applyBorderedButtonStyle(button: btnDownload, text: Local("Settings.Interpretations.Download.Title"))
		}
		btnDownload.isUserInteractionEnabled = true
	}
	
//	func configure(isDownloaded: Bool, downloadDetails downloadInfo: DownloadInfo?) {
//		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//			self.btnDownload.isHidden = isDownloaded
//			self.imgCheck.isHidden = !isDownloaded || downloadInfo != nil
//			Style.applyBorderedButtonStyle(button: self.btnDownload, text: downloadInfo == nil ? Local("Settings.Interpretations.Download.Title") : Local("Settings.Downloading"))
////			self.btnDownload.configure(isDownloaded: isDownloaded, downloadDetails: downloadInfo)
//		})
//	}
	
	//MARK: - UIGestureRecognizerDelegate
//	override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//		if let btn = touch.view as? UIButton, (btn.gestureRecognizers?.contains(gestureRecognizer) ?? false) {
//			return false
//		}
//
//		return true // super.gestureRecognizer(gestureRecognizer, shouldReceive: touch)
//	}

//	override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//		let point = convert(point, to: superview!)
//		
//		if !UIAccessibilityIsVoiceOverRunning() {
//			for cell in tableView?.swipeCells ?? [] {
//				if (cell.state == .left || cell.state == .right) && !cell.contains(point: point) {
//					tableView?.hideSwipeCell()
//					return false
//				}
//			}
//		}
//		
//		return self.contains(point: point) && !btnDownload.frame.contains(point)
//	}
	
	// MARK: - Actions
    
    @objc
    private func btnDownloadPressed() {
		print("btnDownloadPressed")
        downloadDelegate?.interpretationDidSelectedDownload(self)
    }
}

