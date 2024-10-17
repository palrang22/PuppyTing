//
//  TingCollectionViewCell.swift
//  PuppyTing
//
//  Created by 김승희 on 8/27/24.
//
import UIKit

import FirebaseAuth
import RxSwift

class TingCollectionViewCell: UICollectionViewCell {
    static let id = "tingCollectionViewCell"
    
    private let disposeBag = DisposeBag()
    
    var viewController: UIViewController?
    let calendar = Calendar.current
    let currentDate = Date()
    
    //MARK: 컴포넌트 선언
    private let shadowContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false
        return view
    }()
    
    private let profilePic: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultProfileImage")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
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
        label.text = "n분 전"
        label.textColor = .puppyPurple
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let footPrintLabel: UILabel = {
        let label = UILabel()
        label.text = "알 수 없음"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 13, weight: .medium)
        return label
    }()
    
    private let infoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    private let content: UILabel = {
        let label = UILabel()
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        let styleText = NSAttributedString(string:
                                            "오늘 어디어디에서 산책하실 분 있나요? 경로는 아직 구체적으로 정해지지 않았지만 대략적인 방향은 잡아두었습니다. 산책시간은 오후 늦게쯤을 생각하고 있어요. 함께 산책하면 더욱 즐거운 시간이 될 것 같아요! 강아지와 함께 가볍게 산책하며 좋은 시간을 보내고 싶다면 꼭 함께해 주세요. 이따가 만나서 즐거운 시간을 보내면 좋겠습니다! 날씨도 좋으니, 산책 후에는 근처 카페에서 차 한 잔 하며 쉬어가도 좋을 것 같아요."
                                           , attributes: [
                                            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                                            .paragraphStyle: style])
        label.attributedText = styleText
        label.numberOfLines = 3
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
//        label.setContentCompressionResistancePriority(.required, for: .vertical)
//        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
//    private let mapView: UIImageView = {
//        let map = UIImageView()
//        map.image = UIImage(named: "mapPhoto")
//        return map
//    }()
    
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
    
    private let hidableStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 20
        stack.axis = .vertical
        return stack
    }()
    
    //MARK: View 생명주기
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConstraints()
        setLayout()
        addButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: config 메서드
    func configure(with model: TingFeedModel, currentUserID: String) {
        self.nameLabel.text = "알 수 없는 사용자"
        self.profilePic.image = UIImage(named: "defaultProfileImage")
        self.content.text = model.content
        self.footPrintLabel.text = "알 수 없음"
        messageSendButton.isHidden = model.userid == currentUserID
        
        changeDateFormat(time: model.time)
        
        self.footPrintLabel.text = "발도장 \(model.postid)개 🐾"
        
        FireStoreDatabaseManager.shared.findMemeber(uuid: model.userid)
            .subscribe(onSuccess: { [weak self] member in
                
                self?.nameLabel.text = member.nickname
                self?.footPrintLabel.text = "발도장 \(member.footPrint)개 🐾"
                
                if member.profileImage == "defaultProfileImage" {
                            self?.profilePic.image = UIImage(named: "defaultProfileImage")
                } else {
                    if let profilePic = self?.profilePic {
                        KingFisherManager.shared.loadProfileImage(urlString: member.profileImage, into: profilePic, placeholder: UIImage(named: "defaultProfileImage"))
                    }
                }
            }, onFailure: { error in
                print("멤버 찾기 실패: \(error)")
            }).disposed(by: disposeBag)
        writerId = model.userid
        settingData()
    }
    
    var writerId: String? = nil
    let userid = Auth.auth().currentUser?.uid
    var users:[String] = []
    private func settingData() {
        guard let writerId = writerId, let userId = userid else { return }
        users = [userId, writerId]
    }
    
    private func addButtonAction() {
        messageSendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    }
    
    @objc
    private func createRoom() {
        guard let name = nameLabel.text else { return }
        createChatRoom(chatRoomName: name, users: users)
    }
    
    private func changeDateFormat(time: Date) {
        let dateFormatter = DateFormatter()
        let timeDifference = calendar.dateComponents([.minute, .hour, .day], from: time, to: currentDate)
            
        if let minute = timeDifference.minute, let hour = timeDifference.hour, let day = timeDifference.day {
            if day > 0 {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                self.timeLabel.text = dateFormatter.string(from: time)
            } else if hour > 0 {
                self.timeLabel.text = "\(hour)시간 전"
            } else if minute > 0 {
                self.timeLabel.text = "\(minute)분 전"
            } else {
                self.timeLabel.text = "방금 전"
            }
        }
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
                guard let vc = self.viewController else { return }
                vc.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }
    
    //MARK: UI 및 제약조건
    private func setLayout() {
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
    }
    
    private func setConstraints() {
        [nameLabel,
         timeLabel,
        footPrintLabel].forEach { infoStack.addArrangedSubview($0) }
        
        [content,
         messageSendButton].forEach { hidableStack.addArrangedSubview($0) }
        
        [shadowContainerView, profilePic,
         infoStack,
         hidableStack].forEach { contentView.addSubview($0) }
        
        shadowContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
        
        profilePic.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(50)
        }
        
        infoStack.snp.makeConstraints {
            $0.leading.equalTo(profilePic.snp.trailing).offset(20)
            $0.centerY.equalTo(profilePic)
        }
        
//        footPrintLabel.snp.makeConstraints {
//            $0.trailing.equalToSuperview().offset(-20)
//            $0.centerY.equalTo(profilePic)
//        }
        
        hidableStack.snp.makeConstraints {
            $0.top.equalTo(infoStack.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
//        content.snp.makeConstraints {
//            $0.leading.trailing.equalToSuperview().inset(20)
//        }
        
        messageSendButton.snp.makeConstraints {
            // $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
    }
}
