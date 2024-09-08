//
//  ProfileCell.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/6/24.
//

import UIKit

import RxSwift
import SnapKit

class ProfileCell: UICollectionViewCell {
    
    private let disposeBag = DisposeBag()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        return stackView
    }()
    
    private let profileContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.puppyPurple.withAlphaComponent(0.1).cgColor
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.puppyPurple.withAlphaComponent(0.1)
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .black
        imageView.image = UIImage(named: "defaultProfileImage")
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let footView = UIView()
    
    private let footStampLabel: UILabel = {
        let label = UILabel()
        label.text = "🐾 받은 발도장"
        return label
    }()
    
    private let footNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "nn개"
        return label
    }()
    
    private let evaluateView = UIView()
    
    private let footButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("발도장 꾹 🐾", for: .normal)
        button.backgroundColor = UIColor.puppyPurple
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(footButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let blockButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("차단하기", for: .normal)
        button.backgroundColor = UIColor.puppyPurple
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("즐겨찾기", for: .normal)
        button.backgroundColor = UIColor.puppyPurple
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // 작동되는지 확인
    @objc private func footButtonTapped() {
        print("발도장 남기기 버튼 눌림")
    }
    
    func configure(with member: Member) {
           nicknameLabel.text = member.nickname
           footNumberLabel.text = "\(member.footPrint)개"
           
           // 프로필 이미지가 있으면 가져오고 없으면 기본프로필로 설정
           if !member.profileImage.isEmpty {
               loadImage(from: member.profileImage)
           } else {
               profileImageView.image = UIImage(named: "defaultProfileImage") // 기본 이미지
           }
       }
        
    // 프로필 이미지가 있을 때 이미지를 불러옴
       private func loadImage(from urlString: String) {
           guard let url = URL(string: urlString) else { return }
           
           URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
               if let error = error {
                   print("이미지 로딩 실패: \(error)")
                   return
               }
               
               guard let data = data, let image = UIImage(data: data) else { return }
               
               // UI는 메인 스레드에서 업데이트
               DispatchQueue.main.async {
                   self?.profileImageView.image = image
               }
           }.resume()
       }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(profileContainerView)
        
        [profileImageView, nicknameLabel, footView, evaluateView].forEach {
            profileContainerView.addSubview($0)
        }
        
        [footStampLabel, footNumberLabel].forEach {
            footView.addSubview($0)
        }
        
        [footButton, favoriteButton, blockButton].forEach {
            evaluateView.addSubview($0)
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        
        profileContainerView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.equalTo(stackView.snp.top)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(10)
            $0.width.height.equalTo(60)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.left.equalTo(profileImageView.snp.right).offset(10)
            $0.centerY.equalTo(profileImageView.snp.centerY)
        }
        
        footView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        footStampLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        }
        
        footNumberLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(footStampLabel.snp.trailing).offset(20)
        }
        
        evaluateView.snp.makeConstraints {
            $0.top.equalTo(footView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        footButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalTo(favoriteButton.snp.leading).offset(-5)
            $0.height.equalTo(44)
            $0.width.equalTo(110)
        }
        
        favoriteButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(44)
            $0.width.equalTo(110)
        }
        
        blockButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(favoriteButton.snp.trailing).offset(5)
            $0.height.equalTo(44)
            $0.width.equalTo(110)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
