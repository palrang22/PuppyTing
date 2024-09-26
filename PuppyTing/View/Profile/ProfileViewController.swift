//
//  ProfileViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/6/24.
//

import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class ProfileViewController: UIViewController {
    
    var viewModel = ProfileViewModel()
    var member: Member?
    var petId: String? // 강아지 정보 찾기
    var memberId: String?
    var userId: String?
    private let disposeBag = DisposeBag()
    
    //MARK: UI Components - ksh
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
    
    private let footStampLabel: UILabel = {
        let label = UILabel()
        label.text = "🐾 받은 발도장 0개"
        return label
    }()
    
    private let myInfoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    private let footButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🐾", for: .normal)
        button.backgroundColor = UIColor.puppyPurple
        button.layer.cornerRadius = 20
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("★", for: .normal)
        button.backgroundColor = UIColor.puppyPurple
        button.layer.cornerRadius = 20
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "등록된 강아지 정보가 없습니다."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.isHidden = true // 기본적으로는 숨김 처리
        return label
    }()
    
    private let profilePuppyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 200)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ProfilePuppyCollectionViewCell.self, forCellWithReuseIdentifier: ProfilePuppyCollectionViewCell.identifier)
        collectionView.layer.borderColor = UIColor.lightPuppyPurple.cgColor
        collectionView.layer.cornerRadius = 10
        collectionView.layer.borderWidth = 1.0
        collectionView.layer.masksToBounds = false
        collectionView.backgroundColor = UIColor.lightPuppyPurple
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private let blockButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("차단하기", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .clear
        
        let attributedString = NSMutableAttributedString(string: "차단하기")
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    
    
    //MARK: View 생애주기 - ksh
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8) // 배경 투명도 설정
        // loadData()
        setConstraints()
        loadData()
        bindCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionViewWidth = profilePuppyCollectionView.bounds.width
        let layout = profilePuppyCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = CGSize(width: collectionViewWidth, height: 200)
    }
    
    private func loadData() {
        guard let userId = self.userId else { return }
        FireStoreDatabaseManager.shared.findMemeber(uuid: userId)
            .subscribe(onSuccess: { [weak self] member in
                guard let self = self else { return }
                self.member = member
                self.configure(with: member)
                self.memberId = member.uuid
                self.viewModel.fetchPetsForUser(userId: member.uuid)
            }, onFailure: { error in
                print("멤버 찾기 실패: \(error)")
            }).disposed(by: disposeBag)
    }
    
    //MARK: Button 메서드
    private func buttonActionSetting() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        blockButton.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
        footButton.addTarget(self, action: #selector(footButtonTapped), for: .touchUpInside)
    }
    
    // 즐겨찾기 버튼 , 얼럿추가 - jgh
    @objc private func favoriteButtonTapped() {
        print(1)
        guard let bookmarkId = userId else { return }
        print(2)
        viewModel.addBookmark(bookmarkId: bookmarkId)
        guard let parentVC = parent as? ProfileViewController else { return }
        print(3)
        parentVC.autoDismissAlertWithTimer(title: "알림", message: "즐겨찾기에 추가되었습니다.", duration: 1.0) // 시간 변경 가능
    }
    
    // 유저 차단 버튼 - psh
    @objc
    private func blockButtonTapped() {
        guard let userId = userId else { return }
        
        // 차단 얼럿 띄우기 위한 코드 추가 - jgh
        guard let parentVC = parent as? ProfileViewController else { return }
        // 차단 확인 얼럿 띄우기
        parentVC.okAlertWithCancel(
            title: "사용자 차단",
            message: "사용자를 차단하시겠습니까? 차단 이후 사용자의 게시물이 보이지 않습니다.",
            okActionTitle: "차단",
            cancelActionTitle: "취소",
            okActionHandler: { [weak self] (action: UIAlertAction) in
                self?.viewModel.blockedUser(uuid: userId)
                parentVC.okAlert(
                    title: "차단 완료",
                    message: "사용자가 성공적으로 차단되었습니다.",
                    okActionTitle: "확인",
                    okActionHandler: nil
                )
            },
            cancelActionHandler: { (action: UIAlertAction) in
                print("차단 취소됨")
            }
        )
    }
    
    //ksh
    @objc private func footButtonTapped() {
        guard let memberId = memberId else { return }
        viewModel.addFootPrint(footPrintId: memberId)
        
        if let text = footStampLabel.text {
            let pattern = "\\d+"
            
            if let range = text.range(of: pattern, options: .regularExpression),
               let currentFootPrintCount = Int(text[range]) {
                footStampLabel.text = "🐾 받은 발도장 \(currentFootPrintCount + 1)개"
            } else {
                footStampLabel.text = "🐾 받은 발도장 0개"
            }
        }
    }
    
    //MARK: 유저 정보 bind
    func configure(with member: Member) {
        nicknameLabel.text = member.nickname
        footStampLabel.text = "🐾 받은 발도장 \(member.footPrint)개"
        buttonActionSetting()
        
        // 프로필 이미지 로드 - 킹피셔매니저 코드 사용
        if !member.profileImage.isEmpty {
            KingFisherManager.shared.loadProfileImage(urlString: member.profileImage, into: profileImageView)
        } else {
            profileImageView.image = UIImage(named: "defaultProfileImage")
        }
        
        // ksh
        if userId == Auth.auth().currentUser?.uid {
            footButton.isHidden = true
            favoriteButton.isHidden = true
            blockButton.isHidden = true
        } else {
            footButton.isHidden = false
            favoriteButton.isHidden = false
            blockButton.isHidden = false
        }
    }
    
    // psh
    private func bindCollectionView() {
        viewModel.puppySubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] pets in
                if pets.isEmpty {
                    self?.profilePuppyCollectionView.isHidden = true
                    self?.noDataLabel.isHidden = false
                } else {
                    self?.profilePuppyCollectionView.isHidden = false
                    self?.noDataLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.puppySubject
            .bind(to: profilePuppyCollectionView
                .rx
                .items(cellIdentifier: ProfilePuppyCollectionViewCell.identifier,
                       cellType: ProfilePuppyCollectionViewCell.self)) { index, data, cell in
            cell.configure(with: data)
        }.disposed(by: disposeBag)
        
        profilePuppyCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    //MARK: 레이아웃
    private func setConstraints() {
        [nicknameLabel,
         footStampLabel
        ].forEach{ myInfoStack.addArrangedSubview($0) }
        
        [footButton,
         favoriteButton
        ].forEach{ buttonStack.addArrangedSubview($0) }
        
        [profileImageView,
         myInfoStack,
         buttonStack,
         profilePuppyCollectionView,
         blockButton,
         noDataLabel
        ].forEach{ view.addSubview($0) }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.width.height.equalTo(60)
        }
        
        myInfoStack.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
        footButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
        }

        favoriteButton.snp.makeConstraints {
            $0.width.height.equalTo(footButton)
        }
        
        buttonStack.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        profilePuppyCollectionView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        blockButton.snp.makeConstraints {
            $0.top.equalTo(profilePuppyCollectionView.snp.bottom).offset(20)
            $0.trailing.equalTo(profilePuppyCollectionView.snp.trailing)
            $0.width.equalTo(80)
            $0.height.equalTo(30)
        }
        
        noDataLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

}

extension ProfileViewController: UICollectionViewDelegate {
    
}
