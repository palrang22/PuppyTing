//
//  ChatViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class ChatViewController: UIViewController {
    
    let viewModel = ChatViewModel()
    let disposeBag = DisposeBag()
    
    var titleText: String? // 타이틀 저장 변수 ChatListVC에서 가져와야함..
    var roomId: String!
    
    var cachedOtherMember: Member?
    
    let userId = Auth.auth().currentUser?.uid
    
    let chattingTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MyChattingTableViewCell.self, forCellReuseIdentifier: MyChattingTableViewCell.identifier)
        tableView.register(ChattingTableViewCell.self, forCellReuseIdentifier: ChattingTableViewCell.identifier)
        tableView.register(ChatDateTableViewCell.self, forCellReuseIdentifier: ChatDateTableViewCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let messageInputView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false // 기본적으로 스크롤 비활성화
        textView.layer.borderColor = UIColor.darkGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainer.lineBreakMode = .byWordWrapping // 줄바꿈 설정
        textView.showsVerticalScrollIndicator = true // 스크롤 인디케이터 활성화
        return textView
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.puppyPurple
        button.layer.cornerRadius = 22
        button.setTitle("🐾", for: .normal)
        return button
    }()
    
    // messageTextView 기본 높이
    let messageTextViewDefaultHeight: CGFloat = 35.0
    
    var messageInputViewBottomConstraint: Constraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Large Title 해제
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = .white
        
        // 키보드 알림 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowInChatting), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideInChatting), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        [chattingTableView, messageInputView].forEach {
            view.addSubview($0)
        }
        
        [messageTextView, sendButton].forEach {
            messageInputView.addSubview($0)
        }
        
        messageTextView.delegate = self
        
        setupKeyboardDismissRecognizer()
        setupConstraints()
        setupBindings()
        
    }
    
    // 키보드가 나타날 때 호출되는 메서드
    @objc func keyboardWillShowInChatting(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            messageInputViewBottomConstraint.update(offset: -keyboardHeight + view.safeAreaInsets.bottom)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        scrollToBottom() // 키보드가 나타날 때 자동으로 스크롤
    }
    
    // 키보드가 사라질 때 호출되는 메서드
    @objc func keyboardWillHideInChatting(notification: NSNotification) {
        messageInputViewBottomConstraint.update(offset: 0)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // 메모리 해제를 위해 노티피케이션 제거
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupBindings() {
        let input = ChatViewModel.Input(
            roomId: roomId,
            fetchMessages: Observable.just(()),
            sendMessage: sendButton.rx.tap
                .withLatestFrom(messageTextView.rx.text.orEmpty)
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } // 빈메세지 필터링 - jgh
                .asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.messages
            .bind(to: chattingTableView.rx.items) { (tableView: UITableView, row: Int, message: ChatMessage) in
                if message.senderId == "date" {
                    // 날짜 메시지일 경우, 날짜만 표시하는 셀을 구성
                    let cell = tableView.dequeueReusableCell(withIdentifier: ChatDateTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as! ChatDateTableViewCell
                    cell.config(dateText: message.text) // 날짜만 표시
                    return cell
                } else if message.senderId == self.userId {
                    // 일반 메시지인 경우, 기존 로직 그대로 사용
                    let cell = tableView.dequeueReusableCell(withIdentifier: MyChattingTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as! MyChattingTableViewCell
                    let date = self.formatTime(time: message.timestamp)
                    cell.config(message: message.text, time: date)
                    return cell
                } else {
                    // 상대방의 일반 메시지인 경우, 기존 로직 그대로 사용
                    let cell = tableView.dequeueReusableCell(withIdentifier: ChattingTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as! ChattingTableViewCell
                    let date = self.formatTime(time: message.timestamp)
                    if let other = self.cachedOtherMember {
                        cell.config(image: other.profileImage, message: message.text, time: date, nickname: other.nickname)
                    } else {
                        self.viewModel.findMember(uuid: message.senderId)
                        self.viewModel.memberSubject.observe(on: MainScheduler.instance).subscribe(onNext: { member in
                            self.cachedOtherMember = member
                            cell.config(image: member.profileImage, message: message.text, time: date, nickname: member.nickname)
                        }).disposed(by: self.disposeBag)
                    }
                    cell.profileImageTapped = { [weak self] in
                        self?.presentProfileViewController(senderId: message.senderId)
                    }
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        output.messageSent
            .subscribe(onNext: { [weak self] in
                self?.messageTextView.text = ""
            }).disposed(by: disposeBag)
        
        // 메세지 추가 후 테이블뷰 맨 아래로 스크롤
        output.messages
            .skip(1) // 처음 초기화값 건너뛰고 이후 변경될 때 반응
            .subscribe(onNext: { [weak self] _ in
                self?.scrollToBottom()
            })
            .disposed(by: disposeBag)
    }
    
    // 하프모달로 띄우기 - jgh
    private func presentProfileViewController(senderId: String) {
        let profileVC = ProfileViewController()
        profileVC.modalPresentationStyle = .pageSheet
        profileVC.userid = senderId
        if let sheet = profileVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(profileVC, animated: true, completion: nil)
    }
    
    // 제일 밑 채팅 보이기
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom()
    }
    
    func setupConstraints() {
        
        navigationController?.navigationBar.tintColor = UIColor.puppyPurple
        navigationItem.title = titleText // 여기에 가져온 title정보 나오게
        
        chattingTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(messageInputView.snp.top)
        }
        
        messageInputView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            // bottom 제약 조건을 설정하고 변수에 저장
            messageInputViewBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }
        
        messageTextView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
            $0.height.lessThanOrEqualTo(200).priority(.required)
        }
        
        sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }
        
    }
    
    // 스크롤 제일 밑으로
    func scrollToBottom() {
        let lastSectionIndex = chattingTableView.numberOfSections - 1
        let lastRowIndex = chattingTableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if lastRowIndex >= 0 {
            let indexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
            chattingTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    // 메세지 전송 후 텍스트뷰 높이 초기화
    func resetMessageTextViewHeight() {
        messageTextView.snp.updateConstraints {
            $0.height.equalTo(messageTextViewDefaultHeight)
        }
    }
    
    // 시간을 내가 원하는 모습의 String 으로 변환
    func formatTime(time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        // 텍스트뷰의 높이가 100pt를 넘으면 스크롤을 활성화하고 크기를 유지
        textView.isScrollEnabled = estimatedSize.height > 100
        textView.snp.remakeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
            $0.height.equalTo(min(estimatedSize.height, 100)) // 기존 높이 또는 100중 작은 값으로 설정
        }
    }
}

