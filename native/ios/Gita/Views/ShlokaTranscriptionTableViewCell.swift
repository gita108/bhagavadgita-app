//
//  ShlokaTranscriptionTableViewCell.swift
//  Gita
//
//  Created by mikhail.kulichkov on 30/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

fileprivate let transcriptionFont = UIFont(type: .italic, size: 18.0)

final class ShlokaTranscriptionTableViewCell: ReusableTableViewCell {
	
	private let lblTranscription: UILabel = {
		let lblTranscription = UILabel()
		
		lblTranscription.font = transcriptionFont
		lblTranscription.numberOfLines = 0
		lblTranscription.textColor = .gray1
		lblTranscription.textAlignment = .center
		
		return lblTranscription
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		selectionStyle = .none
		separatorInset = UIEdgeInsets.zero
		layoutMargins = UIEdgeInsets.zero
		
		contentView.addSubview(lblTranscription)
		
		activateConstraints(
			lblTranscription.topItem == contentView.topItem + 8.0,
			lblTranscription.leadingItem == contentView.leadingItem + 16.0,
			lblTranscription.trailingItem == contentView.trailingItem - 16.0
		)
	}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	func fill(transcription: String) {
		lblTranscription.text = transcription
	}
	
    // MARK: - Helpers
    
    static func height(transcription: String, width: CGFloat) -> CGFloat {
        let transcriptionHeight = Style.heightOfText(transcription, font: transcriptionFont, width: width - 32.0)
        return transcriptionHeight + 16.0
    }
}
