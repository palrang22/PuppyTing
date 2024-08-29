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
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [outerStackView, chatRoomLabel, chatingLogLabel].forEach {
            contentView.addSubview($0)
        }
        
        outerStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
            $0.height.equalTo(60)
            $0.leading.equalToSuperview().offset(10)
        }
        
        chatRoomLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalTo(outerStackView.snp.trailing).offset(10)
        }
        
        chatingLogLabel.snp.makeConstraints {
            $0.top.equalTo(chatRoomLabel.snp.bottom).offset(10)
            $0.leading.equalTo(outerStackView.snp.trailing).offset(10)
        }
        
    }
    
    func configure(with images: [UIImage], title: String, content: String) {
        // 이미지 컨테이너 초기화
        outerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        chatRoomLabel.text = title
        chatingLogLabel.text = content
        
        switch images.count {
        case 1:
            let imageView = createImageView(with: images[0])
            outerStackView.addArrangedSubview(imageView)
            
        case 2:
            // 이미지가 2개일 때 대각선 배치
            let imageView1 = createImageView(with: images[0])
            let imageView2 = createImageView(with: images[1])
            
            let topStackView = UIStackView(arrangedSubviews: [imageView1, UIView()])
            topStackView.axis = .horizontal
            topStackView.alignment = .center
            topStackView.distribution = .fillEqually
            topStackView.spacing = 2
            
            let bottomStackView = UIStackView(arrangedSubviews: [UIView(), imageView2])
            bottomStackView.axis = .horizontal
            bottomStackView.alignment = .center
            bottomStackView.distribution = .fillEqually
            bottomStackView.spacing = 2
            
            outerStackView.addArrangedSubview(topStackView)
            outerStackView.addArrangedSubview(bottomStackView)
            
        case 3:
            // 이미지가 3개일 때 중앙에 하나, 아래에 두 개 배치
            let imageView1 = createImageView(with: images[0])
            let imageView2 = createImageView(with: images[1])
            let imageView3 = createImageView(with: images[2])
            
            let topStackView = UIStackView(arrangedSubviews: [UIView(), imageView1, UIView()])
            topStackView.axis = .horizontal
            topStackView.alignment = .center
            topStackView.distribution = .equalSpacing
            
            let bottomStackView = UIStackView(arrangedSubviews: [imageView2, imageView3])
            bottomStackView.axis = .horizontal
            bottomStackView.alignment = .center
            bottomStackView.distribution = .fillEqually
            bottomStackView.spacing = 2
            
            outerStackView.addArrangedSubview(topStackView)
            outerStackView.addArrangedSubview(bottomStackView)
            
        default:
            // 이미지가 4개 이상일 때 2x2 그리드 배치
            let imageView1 = createImageView(with: images[0])
            let imageView2 = createImageView(with: images[1])
            let imageView3 = createImageView(with: images[2])
            let imageView4 = createImageView(with: images[3])
            
            let topStackView = UIStackView(arrangedSubviews: [imageView1, imageView2])
            topStackView.axis = .horizontal
            topStackView.alignment = .center
            topStackView.distribution = .fillEqually
            topStackView.spacing = 2
            
            let bottomStackView = UIStackView(arrangedSubviews: [imageView3, imageView4])
            bottomStackView.axis = .horizontal
            bottomStackView.alignment = .center
            bottomStackView.distribution = .fillEqually
            bottomStackView.spacing = 2
            
            outerStackView.addArrangedSubview(topStackView)
            outerStackView.addArrangedSubview(bottomStackView)
        }
    }
    
    private func createImageView(with image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8 // 각진 모서리
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        return imageView
    }
    
    
}
