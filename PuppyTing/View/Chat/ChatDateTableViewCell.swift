//
//  ChatDateTableViewCell.swift
//  PuppyTing
//
//  Created by 박승환 on 9/9/24.
//

import Foundation
import UIKit

class ChatDateTableViewCell: UITableViewCell {
    static let identifier = "ChatDateTableViewCell"
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(dateText: String) {
        dateLabel.text = dateText
    }
}
