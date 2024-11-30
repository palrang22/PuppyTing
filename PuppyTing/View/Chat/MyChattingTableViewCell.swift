//
//  MyChattingTableViewCell.swift
//  PuppyTing
//
//  Created by 내꺼다 on 8/29/24.
//

import UIKit

import SnapKit

class MyChattingTableViewCell: UITableViewCell {
    
    static let identifier = "MyChattingViewCell"
    
    let messageBox: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true // 클릭가능하도록 - jgh
        textView.dataDetectorTypes = .link // 자동으로 링크를 감지하도록 설정 - jgh
        textView.backgroundColor = UIColor.puppyPurple
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textView.layer.cornerRadius = 10
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.sizeToFit()
        return textView
    }()
    
    let date: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        [messageBox, date].forEach {
            contentView.addSubview($0)
        }
        
        messageBox.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview().inset(10)
            $0.height.greaterThanOrEqualTo(30)
            $0.width.lessThanOrEqualTo(255)
            $0.centerY.equalToSuperview()
        }
        
        date.snp.makeConstraints {
            $0.trailing.equalTo(messageBox.snp.leading).offset(-5)
            $0.bottom.equalTo(messageBox.snp.bottom)
        }
        
    }
    
    func config(message: String, time: String) {
        messageBox.text = message
        date.text = time
    }
}
