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
    
    private let unfavoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("해제", for: .normal)
        button.backgroundColor = UIColor.puppyPurple
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(unfavoriteButton)
        
        profileImageView.snp.makeConstraints {
            $0.top.leading.equalTo(contentView).offset(10)
            $0.width.height.equalTo(60)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
            $0.centerY.equalTo(profileImageView)
            $0.trailing.lessThanOrEqualTo(unfavoriteButton.snp.leading).offset(-10)
        }
        
        unfavoriteButton.snp.makeConstraints {
            $0.trailing.equalTo(contentView).offset(-10)
            $0.centerY.equalTo(profileImageView)
            $0.width.equalTo(80)
            $0.height.equalTo(30)
        }
        
        contentView.snp.makeConstraints {
            $0.bottom.equalTo(profileImageView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with favorite: Favorite) {
        nicknameLabel.text = favorite.nickname
        // 프로필 이미지 불러오기
        if let profileImageURL = favorite.profileImageURL, !profileImageURL.isEmpty {
            loadImage(from: profileImageURL)
        } else {
            profileImageView.image = UIImage(named: "defaultProfileImage") // 기본 이미지
        }
    }
    
    // URL로부터 이미지를 비동기적으로 불러오는 함수 
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("이미지 로딩 실패: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else { return }
            
            // UI 업데이트는 메인 스레드에서 수행
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }
}
