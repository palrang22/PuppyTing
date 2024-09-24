//
//  FeedTableViewCell.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/23/24.
//

import UIKit

import SnapKit

class FeedTableViewCell: UITableViewCell {
    
    static let identifier = "FeedTableViewCell"
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [dateLabel, descriptionLabel].forEach {
            contentView.addSubview($0)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-5)
            $0.width.equalTo(100)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalTo(dateLabel.snp.leading).offset(-10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.height.lessThanOrEqualTo(80)
                
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with feed: TingFeedModel) {
        descriptionLabel.text = feed.content
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateLabel.text = dateFormatter.string(from: feed.time)
    }
}
