//
//  DetailTingViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/28/24.
//
import CoreLocation
import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import Kingfisher

protocol DetailTingViewControllerDelegate: AnyObject {
    func didDeleteFeed()
}

class DetailTingViewController: UIViewController {
    
    var tingFeedModels: TingFeedModel?
    weak var delegate: DetailTingViewControllerDelegate? // Delegate 프로퍼티
    let fireStoreDatabase = FireStoreDatabaseManager.shared
    let updateSubject = PublishSubject<TingFeedModel>()
    
    var writerId: String? = nil
    let userid = Auth.auth().currentUser?.uid
    var users: [String] = []
    var images: [String] = []
    
    private let disposeBag = DisposeBag()
    
    private let kakaoMapViewController = KakaoMapViewController()

    // MARK: Component 선언
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let profilePic: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultProfileImage")
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "알 수 없는 사용자"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.textColor = .puppyPurple
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let footPrintLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let infoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 3
        return stack
    }()
    
    private let content: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.id)
        // collectionView.isHidden = true
        return collectionView
    }()
    
    private let mapContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private let hidableStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var blockButton: UIButton = {
        let button = UIButton()
        button.setTitle("차단하기", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("신고하기", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("삭제하기", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정하기", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .white
        return button
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()
    
    private let messageSendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("퍼피팅 메시지 보내기 🐾", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .heavy)
        button.backgroundColor = .puppyPurple
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()

    // MARK: View 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        showLoadingIndicator()
        setData()
        bind()
        tapProfile()
        setDelegate()
        addButtonAction()
        observeData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kakaoMapViewController.activateEngine()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kakaoMapViewController.pauseEngine()
    }
    
    //MARK: @objc 메서드
    
    @objc private func didTapProfile() {
        let profileVC = ProfileViewController()
        profileVC.modalPresentationStyle = .pageSheet
        
        // 선택된 사용자의 uuid 전달
        if let userid = tingFeedModels?.userid {
            profileVC.userId = userid
        }
        
        // 하프모달로 띄우기
        if let sheet = profileVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(profileVC, animated: true)
    }
    
    @objc
    private func createRoom() {
        guard let name = nameLabel.text else { return }
        createChatRoom(chatRoomName: name, users: users)
    }
    
    // MARK: bind
    
    private func observeData() {
        updateSubject
            .subscribe(onNext: { [weak self] updatedModel in
                self?.tingFeedModels = updatedModel
                self?.setData()
            }).disposed(by: disposeBag)
    }
    
    private func setData() {
        if let model = tingFeedModels {
            content.text = model.content
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            timeLabel.text = dateFormatter.string(from: model.time)
            
            let coordinate = model.location
            if coordinate.latitude != 0.0 || coordinate.longitude != 0.0 {
                configMap(with: coordinate)
                mapContainerView.isHidden = false
            } else {
                mapContainerView.isHidden = true
            }
            
            self.images = model.photoUrl
            self.imageCollectionView.isHidden = images.isEmpty
            self.imageCollectionView.reloadData()
            
            FireStoreDatabaseManager.shared.findMemeber(uuid: model.userid)
                .subscribe(onSuccess: { [weak self] member in
                    guard let self else { return }
                    self.hideLoadingIndicator()
                    self.nameLabel.text = member.nickname
                    self.footPrintLabel.text = "🐾 발도장 \(member.footPrint)개"
                    
                    if member.profileImage == "defaultProfileImage" {
                        self.profilePic.image = UIImage(named: "defaultProfileImage")
                    } else {
                        KingFisherManager.shared.loadProfileImage(urlString: member.profileImage, into: profilePic, placeholder: UIImage(named: "defaultProfileImage"))
                    }
                }, onFailure: { error in
                    print("멤버 찾기 실패: \(error)")
                }).disposed(by: disposeBag)
            writerId = model.userid
            settingData()
            setButton(model: model)
        }
    }
    
    private func bind() {
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.okAlertWithCancel(
                    title: "게시물 삭제",
                    message: "게시물을 삭제하시겠습니까?",
                    okActionTitle: "삭제",
                    cancelActionTitle: "취소",
                    okActionHandler: { _ in
                        guard let postid = self?.tingFeedModels?.postid else { return }
                        self?.fireStoreDatabase.deleteDocument(from: "tingFeeds", documentId: postid)
                            .subscribe(onSuccess: { [weak self] in
                                self?.delegate?.didDeleteFeed() // Delegate 호출
                                self?.okAlert(
                                    title: "삭제 완료",
                                    message: "게시물이 성공적으로 삭제되었습니다.",
                                    okActionHandler: { _ in
                                        self?.navigationController?.popViewController(animated: true)
                                    }
                                )
                            }, onFailure: { error in
                                self?.okAlert(
                                    title: "삭제 실패",
                                    message: "게시물 삭제에 실패했습니다. 다시 시도해주세요."
                                )
                            }).disposed(by: self?.disposeBag ?? DisposeBag())
                    }
                )
            }).disposed(by: disposeBag)
        
        // 차단 버튼 수정 - jgh
        blockButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let userid = self?.tingFeedModels?.userid else { return }
                // 얼럿 창을 먼저 띄우기
                self?.okAlertWithCancel(
                    title: "사용자 차단",
                    message: "사용자를 차단하시겠습니까? 차단 이후 사용자의 게시물이 보이지 않습니다.",
                    okActionTitle: "차단",
                    okActionHandler: { [weak self] _ in
                        // 차단 버튼을 눌렀을 때 차단 로직을 실행
                        self?.fireStoreDatabase.blockUser(userId: userid)
                            .subscribe(onSuccess: { [weak self] in
                                self?.okAlert(title: "차단 완료", message: "사용자가 성공적으로 차단되었습니다.", okActionHandler: { _ in
                                    self?.navigationController?.popViewController(animated: true)
                                })
                            }, onFailure: { error in
                                self?.okAlert(title: "차단 실패", message: "사용자 차단에 실패했습니다. 다시 시도해주세요.")
                            }).disposed(by: self!.disposeBag)
                    })
            }).disposed(by: disposeBag)
        
        reportButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let postid = self?.tingFeedModels?.postid else { return }
                let reportAlert = UIAlertController(title: "신고 사유 선택", message: nil, preferredStyle: .actionSheet)
                let reasons = [
                    "부적절한 내용",
                    "부적절한 닉네임 또는 프로필사진",
                    "스팸 또는 오해의 소지가 있는 정보",
                    "혐오 발언",
                    "지적 재산권 침해",
                    "개인정보 침해",
                    "불법 활동",
                    "괴롭힘, 폭력 또는 위협"
                ]
                
                reasons.forEach { reason in
                    let action = UIAlertAction(title: reason, style: .default) { [weak self] _ in
                        let report = Report(postId: postid, reason: reason, timeStamp: Date())
                        
                        self?.fireStoreDatabase.reportPost(report: report)
                            .subscribe(onSuccess: {
                                self!.okAlert(title: "신고 접수", message: "신고가 접수되었습니다. 관리자가 24시간 이내로 검토할 예정이며, 추가 신고/문의는 nnn@naver.com 으로 보내주세요.", okActionHandler: { _ in
                                    self?.navigationController?.popViewController(animated: true)
                                })
                            }, onFailure: { error in
                                self?.okAlert(title: "신고 실패", message: "게시글 신고에 실패했습니다. 다시 시도해주세요.")
                            }).disposed(by: self!.disposeBag)
                    }
                    reportAlert.addAction(action)
                }
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                reportAlert.addAction(cancelAction)
                
                self!.present(reportAlert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        editButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self, let tingFeedModel = self.tingFeedModels else { return }
                let postTingVC = PostTingViewController()
                postTingVC.mode = .edit(documentId: tingFeedModel.postid, model: tingFeedModel)
                postTingVC.updateSubject = self.updateSubject
                self.navigationController?.pushViewController(postTingVC, animated: true)
            }).disposed(by: disposeBag)
    }
    
    //MARK: 프로필 메서드 - jgh
    // profilePic에 탭 Gesture 추가 -> ProfileViewController 연결
    private func tapProfile() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(tapGesture)
        
        // 닉네임에도 탭 추가
        let nameTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(nameTapGesture)
    }
    
    //MARK: Delegate 설정
    private func setDelegate() {
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
    }
    
    //MARK: 채팅방 메서드

    private func settingData() {
        guard let writerId = writerId, let userId = userid else { return }
        users = [userId, writerId]
    }
    
    private func findUserId() -> String {
        guard let user = Auth.auth().currentUser else { return "" }
        return user.uid
    }
    
    private func createChatRoom(chatRoomName: String, users: [String]) {
        FirebaseRealtimeDatabaseManager.shared.checkIfChatRoomExists(userIds: users) { exists, chatId in
            if exists {
                if let roomId = chatId {
                    self.moveChatRoom(roomId: roomId, users: users)
                }
            } else {
                FirebaseRealtimeDatabaseManager.shared.createChatRoom(name: chatRoomName, users: users)
                    .observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] roomId in
                    self?.moveChatRoom(roomId: roomId, users: users)
                }).disposed(by: self.disposeBag)
            }
        }
    }
    
    private func moveChatRoom(roomId: String, users: [String]) {
        let chatVC = ChatViewController()
        chatVC.roomId = roomId
        let userId = findUserId()
        let otherUser = users.first == userId ? users.last : users.first
        if let otherUser = otherUser {
            FireStoreDatabaseManager.shared.findMemberNickname(uuid: otherUser) { nickname in
                chatVC.titleText = nickname
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }
    
    private func addButtonAction() {
        messageSendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    }
    
    //MARK: 카카오맵 메서드
    private func configMap(with coordinate: CLLocationCoordinate2D) {
        addChild(kakaoMapViewController)
        mapContainerView.addSubview(kakaoMapViewController.view)
        kakaoMapViewController.didMove(toParent: self)
        kakaoMapViewController.setCoordinate(coordinate)
        kakaoMapViewController.addPoi(at: coordinate)
        
        kakaoMapViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        view.layoutIfNeeded()
    }
    
    private func setButton(model: TingFeedModel) {
        if Auth.auth().currentUser?.uid == model.userid {
            self.messageSendButton.isHidden = true
            self.editButton.isHidden = false
            self.deleteButton.isHidden = false
            self.blockButton.isHidden = true
            self.reportButton.isHidden = true
        } else {
            self.messageSendButton.isHidden = false
            self.editButton.isHidden = true
            self.deleteButton.isHidden = true
            self.blockButton.isHidden = false
            self.reportButton.isHidden = false
        }
    }
    
    // MARK: UI 설정 및 제약조건 등
    private func setUI() {
        view.backgroundColor = .white
    }
    
    private func setConstraints() {
        // scrollView 설정
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        // 나머지 뷰 설정
        [nameLabel, timeLabel]
            .forEach { infoStack.addArrangedSubview($0) }
        [editButton, deleteButton, reportButton, blockButton]
            .forEach { buttonStack.addArrangedSubview($0) }
        [content, imageCollectionView, mapContainerView]
            .forEach { hidableStack.addArrangedSubview($0) }
        [profilePic,
         infoStack,
         footPrintLabel,
         hidableStack,
         buttonStack,
         messageSendButton]
            .forEach { contentView.addSubview($0) }
        
        profilePic.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(60)
        }
        
        infoStack.snp.makeConstraints {
            $0.leading.equalTo(profilePic.snp.trailing).offset(20)
            $0.centerY.equalTo(profilePic)
        }
        
        footPrintLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(profilePic)
        }
        
        imageCollectionView.snp.makeConstraints {
            $0.height.equalTo(view.frame.width - 70)
        }
        
        mapContainerView.snp.makeConstraints {
            $0.height.equalTo(120)
        }
        
        hidableStack.snp.makeConstraints {
            $0.top.equalTo(profilePic.snp.bottom).offset(40)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(hidableStack.snp.bottom).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        messageSendButton.snp.makeConstraints {
            $0.top.equalTo(buttonStack.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

}

//MARK: Extension
extension DetailTingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let imageSize = view.frame.width - 80
        return CGSize(width: imageSize, height: imageSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageUrl = images[indexPath.item]
        showImageFullscreen(imageUrl: imageUrl)
    }
    
    // 이미지 선택시 전체화면 - 사진 클릭시 닫힘
    // 관련 설명 추가 또는 닫히는 로직 변경예정
    private func showImageFullscreen(imageUrl: String) {
        let fullScreenImageView = UIImageView()
        fullScreenImageView.contentMode = .scaleAspectFit
        fullScreenImageView.backgroundColor = .black
        fullScreenImageView.isUserInteractionEnabled = true
        
        KingFisherManager.shared.loadAnyImage(urlString: imageUrl, into: fullScreenImageView)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(fullScreenImageView)
        fullScreenImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        fullScreenImageView.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension DetailTingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.id, for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        
        let imageUrl = images[indexPath.item]
        cell.configure(with: imageUrl)
        return cell
    }
    
}
