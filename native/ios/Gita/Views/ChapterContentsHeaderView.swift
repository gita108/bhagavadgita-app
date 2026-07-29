//
//  ChapterContentsHeaderView.swift
//  Gita
//
//  Created by mikhail.kulichkov on 04/05/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

protocol ChapterContentsHeaderViewDelegate {
	func didSelected(_ view: ChapterContentsHeaderView)
}

final class ChapterContentsHeaderView: UITableViewHeaderFooterView {
	
	//Fix for constraint error when cell width is 0
	//https://stackoverflow.com/a/35053234
	override var frame: CGRect {
		get { return super.frame }
		set {
			if newValue.width == 0 {
				return
			}
			
			super.frame = newValue
		}
	}
	
    var isExpanded = false
	var delegate: ChapterContentsHeaderViewDelegate?
	var section: Int = -1

    private let imgDisclosure: UIImageView = UIImageView(image: UIImage(named: "ic_disclosure"))
    private let imgSeparator = UIImageView(image: ImageManager.solid(color: UIColor.gray5, size: CGSize(width: 1, height: 1)))
    private let btnShowShlokas = UIButton()
	
    private let lblChapterNumber: UILabel = {
        let lblChapterNumber = UILabel()
        
        lblChapterNumber.font = UIFont(type: .regular, size: 14.0)
        lblChapterNumber.textColor = .gray2
        lblChapterNumber.textAlignment = .left
        
        return lblChapterNumber
    }()
    
    private let lblChapterTitle: UILabel = {
        let lblChapterTitle = UILabel()
        
        lblChapterTitle.font = UIFont(type: .regular, size: 18.0)
        lblChapterTitle.textColor = .gray1
        lblChapterTitle.textAlignment = .left
        lblChapterTitle.numberOfLines = 0
		lblChapterTitle.lineBreakMode = .byWordWrapping
        
        return lblChapterTitle
    }()
    
    private let lblShlokaQuantity: UILabel = {
        let lblShlokaQuantity = UILabel()
        
        lblShlokaQuantity.font = UIFont(type: .italic, size: 14.0)
        lblShlokaQuantity.textColor = .gray2
        lblShlokaQuantity.textAlignment = .left
        
        return lblShlokaQuantity
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
		
		self.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubviews(lblChapterNumber, lblChapterTitle, lblShlokaQuantity, imgDisclosure, imgSeparator, btnShowShlokas)

		btnShowShlokas.addTarget(self, action: #selector(btnShowShlokasPressed), for: .touchUpInside)
		
		lblChapterTitle.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
		imgDisclosure.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)

		lblChapterTitle.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)

        activateConstraints(
			lblChapterNumber.top(11).leading(16),
			lblChapterTitle.pinTop(3, to: lblChapterNumber).leading(16),
			
			lblShlokaQuantity.pinTop(6, to: lblChapterTitle).leading(16),
			//Flexible bottom due to height could be calculated incorrectly
			[lblShlokaQuantity.bottomItem == contentView.bottomItem - 16.0 ~ 750],
            
            //NOTE: width and heigth are exchanged, because disclosure is rotated by +- 90 degrees
            imgDisclosure.width(8).height(13).pinLeft(16, to: lblChapterTitle).centerY().trailing(16),
            
            imgSeparator.dockBottom(),
            
            btnShowShlokas.edges()
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
		
		section = -1
        lblChapterTitle.text = ""
        lblChapterNumber.text = ""
        lblShlokaQuantity.text = ""
        
        imgDisclosure.transform = .identity
        isExpanded = false
    }
	
	func fill(expanded: Bool, section: Int, chapterNumber: String, chapterTitle: String, shlokasCount: Int) {
		self.section = section
		
		let localizedShlokaQuantityFormatString = Local("Contents.Shloka.Quantity")
		let shlokasQuantityString = String.localizedStringWithFormat(localizedShlokaQuantityFormatString, shlokasCount)

        lblChapterTitle.text = chapterTitle
        lblChapterNumber.text = chapterNumber
        lblShlokaQuantity.text = shlokasQuantityString
        
        isExpanded = expanded
        let angle = ImageManager.angle(degrees: isExpanded ? -90 : 90)
        imgDisclosure.transform = imgDisclosure.transform.rotated(by: angle)
    }

    func animateDisclosure() {
        
        let transformC = imgDisclosure.transform.c
        let angle = transformC * ImageManager.angle(degrees: 90)
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                self.imgDisclosure.transform = .identity
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.imgDisclosure.transform = CGAffineTransform(rotationAngle: angle)
            }
        })
        
        isExpanded = !isExpanded
    }
	
	static func height(chapterNumber: String, chapterTitle: String, width: CGFloat, shlokasCount: Int) -> CGFloat {
		let numberSize = chapterNumber.size(width: width - 32, height: 9999, font: UIFont(type: .regular, size: 14.0))
		let titleSize = chapterTitle.size(width: width - 56, height: 9999, font: UIFont(type: .regular, size: 18.0))
		let counterSize = String.localizedStringWithFormat(Local("Contents.Shloka.Quantity"), shlokasCount)
			.size(width: width - 32, height: 9999, font: UIFont(type: .italic, size: 14.0))
		
		return 11 + numberSize.height.rounded() + 3 + titleSize.height.rounded() + 6 + counterSize.height.rounded() + 16
	}
	
    @objc
    private func btnShowShlokasPressed() {
        delegate?.didSelected(self)
    }
    
}
