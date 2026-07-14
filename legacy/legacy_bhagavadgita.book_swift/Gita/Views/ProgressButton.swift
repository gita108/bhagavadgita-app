//
//  ProgressButton.swift
//  Gita
//
//  Created by Olga Zhegulo  on 14/06/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

class ProgressButton: UIButton {

	private var vProgress: UIView?
	private var cProgressWidth: NSLayoutConstraint?
	private var imgCheck: UIImageView?
	
	private let _completedImageName: String
	private let _text: String

	required init(text: String, completedImageName: String) {
		_completedImageName = completedImageName
		_text = text
		super.init(frame: .zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(isDownloaded: Bool, downloadDetails downloadInfo: DownloadInfo?) {
		//Enable/prevent click
		isUserInteractionEnabled = !isDownloaded
		
		if isDownloaded {
			//print("Show downloaded")
			//Clear title
			setTitle(nil, for: .normal)
			setAttributedTitle(nil, for: .normal)
			
			//Remove border
			layer.borderWidth = 0.0
			
			//Remove progress bar
			if vProgress != nil {
				vProgress!.removeFromSuperview()
				vProgress = nil
			}
			
			//Show 'ready' image
			imgCheck = UIImageView(image: UIImage(named: "ic_check"))
			imgCheck?.isUserInteractionEnabled = false
			insertSubview(imgCheck!, at: 0)
			activateConstraints(
				imgCheck!.trailingItem == trailingItem,
				imgCheck!.centerYItem == centerYItem
			)
		} else {
			if downloadInfo != nil && downloadInfo!.isDownloading {
				//Show progress
				
				//Remove 'ready' image
				if imgCheck != nil {
					imgCheck!.removeFromSuperview()
					imgCheck = nil
				}

				//Red border for progress, same as Style.applyBorderedButtonStyle
				layer.borderColor = UIColor.red1.cgColor
				layer.borderWidth = 1.0
				layer.cornerRadius = 7.0
				layer.masksToBounds = true
				clipsToBounds = true
				
				setProgress(progress: downloadInfo!.progress, color: .red1)
			} else {
				//Show Download button
				//print("Show Download button")
				//Remove 'ready' image
				if imgCheck != nil {
					imgCheck!.removeFromSuperview()
					imgCheck = nil
				}
				
				//Remove progress bar
				if vProgress != nil {
					vProgress!.removeFromSuperview()
					vProgress = nil
				}
				
				//Show 'Download' button with red border
				Style.applyBorderedButtonStyle(button: self, text: _text)
			}
		}
	}
	
	func setProgress(progress: Float, color: UIColor) {
		if progress >= 0 && progress <= 1 {
			//print("-- Progress bar: \(progress)")
			
			setTitle(nil, for: .normal)
			setAttributedTitle(nil, for: .normal)
			
			if vProgress == nil {
				//Prevent click
				isUserInteractionEnabled = false
				
				vProgress = UIView()
				
				vProgress!.backgroundColor = color
				vProgress!.layer.borderColor = color.cgColor
				vProgress!.layer.borderWidth = 1.0
				vProgress!.clipsToBounds = true

				vProgress!.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width * CGFloat(progress), height: self.frame.size.height)
				insertSubview(vProgress!, at: 0)
			} else {
				vProgress!.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width * CGFloat(progress), height: self.frame.size.height)
			}
			self.setNeedsDisplay()
//			print("Progress width: \(self.frame.size.width * CGFloat(progress)), frame: \(vProgress!.frame)")
		}
	}
}
