//
//  UnitSettingsTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 28/04/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

class UnitSettingsTableViewCell: ReusableTableViewCell {
	
	enum SettingsCellType: Int {
		case other = 0, audioTranslation, audioSanskrit
	}
	
	var type: SettingsCellType = .other
	
    private let lblTitle: UILabel = Style.settingLabel()
    private let swchInclude: UISwitch = Style.redSwitch()
    private var switchAction: ((_ enabled: Bool) -> ())?
	
	private var vProgressDownload: CircularProgressView?
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		        
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        
        swchInclude.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        contentView.addSubviews(lblTitle, swchInclude)
        
        activateConstraints(
            lblTitle.centerYItem == contentView.centerYItem,
            lblTitle.leadingItem == contentView.leadingItem + 16.0,
            
            swchInclude.leadingItem >= lblTitle.trailingItem + 10.0,
            swchInclude.centerYItem == contentView.centerYItem,
            swchInclude.trailingItem == contentView.trailingItem - 20.0
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	func fill(title: String, enabled: Bool, type: SettingsCellType, switchAction: ((_ enabled: Bool) -> ())?) {
		lblTitle.text = title
		swchInclude.isOn = enabled
		self.type = type
		self.switchAction = switchAction
	}
	
	func setEnabled(_ enabled: Bool) {
		self.swchInclude.isEnabled = enabled
	}
	
	func setOn(_ on: Bool) {
		self.swchInclude.setOn(on, animated: true)
	}
	
	func addProgress() {
		self.vProgressDownload = {
			let view = CircularProgressView(radius: 11.0, trackWidth: 2.0)
			view.backgroundColor = .clear
			view.trackColor = .gray4
			view.progressColor = .red1
			
			return view
		}()
		
		self.contentView.addSubview(self.vProgressDownload!)
		self.vProgressDownload!.clearsContextBeforeDrawing = false
		
		activateConstraints(
			self.vProgressDownload!.widthItem == 22,
			self.vProgressDownload!.heightItem == 22,
			self.vProgressDownload!.centerYItem == self.contentView.centerYItem,
			self.vProgressDownload!.trailingItem == self.swchInclude.leadingItem - 16
		)
	}
	
	func removeProgress() {
		self.vProgressDownload?.removeFromSuperview()
		self.vProgressDownload = nil
	}
	
	func showProgress(_ progress: Float, isDownloading: Bool) {
		print("progress:\(progress)")
		if self.vProgressDownload == nil && isDownloading {
			self.addProgress()
		} else if let vProgressDownload = self.vProgressDownload {
			if isDownloading {
				vProgressDownload.progress = Double(progress)
			} else {
				self.removeProgress()
			}
		}
	}

    @objc
    private func switchChanged() {
        switchAction?(swchInclude.isOn)
    }
}
