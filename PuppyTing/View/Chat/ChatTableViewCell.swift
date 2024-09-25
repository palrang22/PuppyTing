//
//  ChatTableViewCell.swift
//  PuppyTing
//
//  Created by 박승환 on 8/28/24.
//

import Foundation
import UIKit

import SnapKit

class ChatTableViewCell: UITableViewCell {
    
    static let identifier = "ChatTableViewCell"
    
    // 최대 4개의 사진까지 보여줄 구역
    private let outerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // 채팅방 이름 구역
    private let chatRoomLabel: UILabel = {
        let label = UILabel()
        label.text = "채팅방 이름"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    // 마지막 채팅 내용 구역
    private let chatingLogLabel: UILabel = {
        let label = UILabel()
        label.text = "마지막 채팅 내용"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let messageStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [chatRoomLabel, chatingLogLabel].forEach {
            messageStack.addArrangedSubview($0)
        }
        
        [outerStackView, messageStack].forEach {
            contentView.addSubview($0)
        }
        
        outerStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
            $0.height.equalTo(60)
            $0.leading.equalToSuperview().offset(10)
        }
        
        messageStack.snp.makeConstraints {
            $0.centerY.equalTo(outerStackView)
            $0.leading.equalTo(outerStackView.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().offset(20)
        }
        
    }
    
    func config(image: String, title: String, content: String) {
        outerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        chatRoomLabel.text = title
        chatingLogLabel.text = content
        fetchImage(image: image)
    }
    
    private func fetchImage(image: String) {
        outerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30 // 각진 모서리
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        KingFisherManager.shared.loadProfileImage(urlString: image, into: imageView)
        outerStackView.addArrangedSubview(imageView)
    }
    
}
