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
    var petId: String? // 강아지 정보 찾기
    private let userId = Auth.auth().currentUser?.uid
    weak var parentViewController: UIViewController?
    
    private let disposeBag = DisposeBag()
    
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
    
    private let puppyContainerView: UIView = { // - kkh 강아지 정보가 담길 컨테이너뷰
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
    
    private let puppyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "defaultProfileImage")
        imageView.layer.cornerRadius = 30
        return imageView
    }()
    
    private let puppyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "강아지 이름"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let puppyAgeLabel: UILabel = {
        let label = UILabel()
        label.text = "나이"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()

    private let puppyTagLabel: UILabel = {
        let label = UILabel()
        label.text = "태그"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .gray
        return label
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
    
    private func buttonActionSetting() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        blockButton.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
        footButton.addTarget(self, action: #selector(footButtonTapped), for: .touchUpInside)
//        myinfoEditButton.addTarget(self, action: #selector(myinfoEditButtonTapped), for: .touchUpInside)
    }
    
    // 즐겨찾기 버튼 , 얼럿추가 - jgh
    @objc private func favoriteButtonTapped() {
        guard let bookmarkId = memberId else { return }
        viewModel?.addBookmark(bookmarkId: bookmarkId)
        guard let parentVC = parentViewController as? ProfileViewController else { return }
        parentVC.autoDismissAlertWithTimer(title: "알림", message: "즐겨찾기에 추가되었습니다.", duration: 1.0) // 시간 변경 가능
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
    
//    @objc private func myinfoEditButtonTapped() {
//        guard let parentVC = parentViewController else { return }
//
//        parentVC.dismiss(animated: true) {
//            NotificationCenter.default.post(name: NSNotification.Name("SwitchToMyPage"), object: nil)
//        }
//    }
    
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
//            myinfoEditButton.isHidden = false
        } else {
            footButton.isHidden = false
            favoriteButton.isHidden = false
            blockButton.isHidden = false
//            myinfoEditButton.isHidden = true
        }
        
//        self.petId = pet.userid
            print("Configuring ProfileCell with memberId: \(self.memberId)")

        if let userId = memberId {
            print("memberId: \(memberId)") // memberId 값 확인
            print("Calling fetchPetsForUser with userId: \(userId)")
            viewModel?.fetchPetsForUser(userId: userId)
        }
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel?.petName
            .bind(to: puppyNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.petAge
            .bind(to: puppyAgeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.petTags
            .bind(to: puppyTagLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.petImage
            .subscribe(onNext: { [weak self] image in
                self?.puppyImageView.image = image
            }).disposed(by: disposeBag)
    }
            
    override init(frame: CGRect) { // - kkh 하프모달 UI 수정
        super.init(frame: frame)
        
        print("ProfileCell initialized")
        self.viewModel = ProfileViewModel()
        
        [profileImageView, nicknameLabel, footStampLabel, footNumberLabel, footButton, favoriteButton, puppyContainerView ,blockButton].forEach { contentView.addSubview($0) }
        
        contentView.addSubview(puppyContainerView)
        [puppyImageView, puppyNameLabel, puppyAgeLabel, puppyTagLabel].forEach { puppyContainerView.addSubview($0) }
        
        profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(60)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
        footStampLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(15)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(15)
        }
        
        footNumberLabel.snp.makeConstraints {
            $0.centerY.equalTo(footStampLabel)
            $0.leading.equalTo(footStampLabel.snp.trailing).offset(5)
        }
        
        footButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalTo(footNumberLabel.snp.trailing).offset(20)
            $0.width.height.equalTo(40)
        }
        
        favoriteButton.snp.makeConstraints {
            $0.top.equalTo(footButton)
            $0.left.equalTo(footButton.snp.right).offset(10)
            $0.width.height.equalTo(footButton)
        }
        
        puppyContainerView.snp.makeConstraints {
            $0.top.equalTo(footNumberLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(blockButton.snp.top).offset(-10)
        }
        
        puppyImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        puppyNameLabel.snp.makeConstraints {
            $0.top.equalTo(puppyImageView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        puppyAgeLabel.snp.makeConstraints {
            $0.top.equalTo(puppyNameLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        puppyTagLabel.snp.makeConstraints {
            $0.top.equalTo(puppyAgeLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        blockButton.snp.makeConstraints {
            $0.top.equalTo(puppyContainerView.snp.bottom).offset(10)
            $0.trailing.equalTo(puppyContainerView.snp.trailing)
            $0.width.equalTo(80)
            $0.height.equalTo(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
