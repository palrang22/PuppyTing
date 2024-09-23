//
//  ProfileCell.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/6/24.
//

import UIKit

import FirebaseAuth
import RxSwift
import SnapKit

class ProfileCell: UICollectionViewCell {
    
    var viewModel: ProfileViewModel?
    var memberId: String? // 즐겨찾기 할 유저 Id
    private let userId = Auth.auth().currentUser?.uid
    weak var parentViewController: UIViewController?
    
    private let disposeBag = DisposeBag()
    
    private let profileContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.puppyPurple.withAlphaComponent(0.1).cgColor
        view.layer.masksToBounds = false
        view.backgroundColor = UIColor(red: 247/255, green: 245/255, blue: 255/255, alpha: 1)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .black
        imageView.image = UIImage(named: "defaultProfileImage")
        imageView.layer.cornerRadius = 30
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
        label.text = "0개"
        return label
    }()
    
    private let footButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("발도장 꾹 🐾", for: .normal)
        button.backgroundColor = UIColor.puppyPurple
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
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
    
    private let myinfoEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("마이페이지", for: .normal)
        button.backgroundColor = UIColor.puppyPurple
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.alignment = .fill
        return stackView
    }()
    
    private func buttonActionSetting() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        blockButton.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
        footButton.addTarget(self, action: #selector(footButtonTapped), for: .touchUpInside)
        myinfoEditButton.addTarget(self, action: #selector(myinfoEditButtonTapped), for: .touchUpInside)
    }
    
    // 즐겨찾기 버튼
    @objc private func favoriteButtonTapped() {
        guard let bookmarkId = memberId else { return }
        viewModel?.addBookmark(bookmarkId: bookmarkId)
    }
    
    // 유저 차단 버튼 - psh
    @objc
    private func blockButtonTapped() {
        guard let userId = memberId else { return }
        
        // 차단 얼럿 띄우기 위한 코드 추가 - jgh
        guard let parentVC = parentViewController as? ProfileViewController else { return }
        // 차단 확인 얼럿 띄우기
        parentVC.okAlertWithCancel(
            title: "사용자 차단",
            message: "사용자를 차단하시겠습니까? 차단 이후 사용자의 게시물이 보이지 않습니다.",
            okActionTitle: "차단",
            cancelActionTitle: "취소",
            okActionHandler: { [weak self] (action: UIAlertAction) in
                self?.viewModel?.blockedUser(uuid: userId)
                parentVC.okAlert(
                    title: "차단 완료",
                    message: "사용자가 성공적으로 차단되었습니다.",
                    okActionTitle: "확인",
                    okActionHandler: nil
                )
            },
            cancelActionHandler: { (action: UIAlertAction) in
                // 취소버튼일때는 다른 작업 없어서 로그만 출력
                print("차단 취소됨")
            }
        )
    }
    
    //ksh
    @objc private func footButtonTapped() {
        guard let memberId = memberId else { return }
        viewModel?.addFootPrint(footPrintId: memberId)
        
        if let currentFootPrintCount = Int(footNumberLabel.text?.components(separatedBy: "개").first ?? "0") {
            footNumberLabel.text = "\(currentFootPrintCount + 1)개"
        }
    }
    
    @objc private func myinfoEditButtonTapped() {
        guard let parentVC = parentViewController else { return }

        parentVC.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name("SwitchToMyPage"), object: nil)
        }
    }

    
    func configure(with member: Member) {
        nicknameLabel.text = member.nickname
        footNumberLabel.text = "\(member.footPrint)개"
        buttonActionSetting()
        // 프로필 이미지 로드 - 킹피셔매니저 코드 사용
        if !member.profileImage.isEmpty {
            KingFisherManager.shared.loadProfileImage(urlString: member.profileImage, into: profileImageView)
        } else {
            profileImageView.image = UIImage(named: "defaultProfileImage")
        }
        
        // ksh
        if userId == member.uuid {
            footButton.isHidden = true
            favoriteButton.isHidden = true
            blockButton.isHidden = true
            myinfoEditButton.isHidden = false
        } else {
            footButton.isHidden = false
            favoriteButton.isHidden = false
            blockButton.isHidden = false
            myinfoEditButton.isHidden = true
        }
    }
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(profileContainerView)
        
        [profileImageView, nicknameLabel, footView, buttonStackView].forEach {
            profileContainerView.addSubview($0)
        }
        
        [footStampLabel, footNumberLabel].forEach {
            footView.addSubview($0)
        }
        
        [footButton, favoriteButton, blockButton, myinfoEditButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        profileContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().offset(15)
            $0.width.height.equalTo(60)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.left.equalTo(profileImageView.snp.right).offset(15)
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
            $0.leading.equalToSuperview().offset(15)
        }
        
        footNumberLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(footStampLabel.snp.trailing).offset(20)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(footView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(44)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    } 
}
