//
//  FavoriteListTableViewCell.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/9/24.
//

import UIKit

import SnapKit

class FavoriteListTableViewCell: UITableViewCell {
    
    static let identifier = "FavoriteListTableViewCell"
    
    var onViewPostsButtonTapped: (() -> Void)? // "작성글 보기" 버튼 클릭 시 호출될 클로저
    var onChatActionButtonTapped: (() -> Void)? // psh - 채팅 버튼 클릭 시 호출될 클로저
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    // UIMenu로 여러 아이템 선택할 수 있는 버튼 생성
    private lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        let menuIcon = UIImage(systemName: "ellipsis.circle")
        button.tintColor = .darkPuppyPurple
        button.setImage(menuIcon, for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.menu = createMenu()
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(listButton)
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(10)
            $0.leading.equalTo(contentView).offset(20)
            $0.width.height.equalTo(60)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(15)
            $0.centerY.equalTo(profileImageView)
            $0.trailing.lessThanOrEqualTo(listButton.snp.leading).offset(-10)
        }
        
        listButton.snp.makeConstraints {
                        $0.trailing.equalTo(contentView).offset(-20)
                        $0.centerY.equalTo(profileImageView)
                        $0.width.equalTo(44)
                        $0.height.equalTo(44)
        }
        
        contentView.snp.makeConstraints {
            $0.bottom.equalTo(profileImageView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 메뉴 생성 메서드
    private func createMenu() -> UIMenu {
        // 각 메뉴 항목 생성
        let viewPostsAction = UIAction(title: "작성글 보기", image: UIImage(systemName: "doc.text")) { [weak self] _ in
            self?.onViewPostsButtonTapped?() // 클로저 호출
        }
        
        let chatAction = UIAction(title: "채팅 바로가기", image: UIImage(systemName: "message")) { [weak self] _ in
            // 로직 연결 해야함
            self?.onChatActionButtonTapped?()
        }
        
        // 여러 메뉴를 담는 UIMenu 생성
        return UIMenu(title: "옵션", children: [viewPostsAction, chatAction])
    }
    
    func configure(with favorite: Favorite) {
        nicknameLabel.text = favorite.nickname
        // 프로필 이미지 불러오기 - 킹피셔 코드 사용
        if let profileImageURL = favorite.profileImageURL, !profileImageURL.isEmpty {
            KingFisherManager.shared.loadProfileImage(urlString: profileImageURL, into: profileImageView)
        } else {
            profileImageView.image = UIImage(named: "defaultProfileImage")
        }
    }
}
