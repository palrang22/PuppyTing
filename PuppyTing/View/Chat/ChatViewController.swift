//
//  ChatViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class ChatViewController: UIViewController {
    
    let viewModel = ChatViewModel()
    let disposeBag = DisposeBag()
    
    var titleText: String? // 타이틀 저장 변수 ChatListVC에서 가져와야함..
    
    let chattingTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MyChattingTableViewCell.self, forCellReuseIdentifier: MyChattingTableViewCell.identifier)
        tableView.register(ChattingTableViewCell.self, forCellReuseIdentifier: ChattingTableViewCell.identifier)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Large Title 해제
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = .white
        
        [chattingTableView, messageInputView].forEach {
            view.addSubview($0)
        }
        
        [messageTextView, sendButton].forEach {
            messageInputView.addSubview($0)
        }
        
//        chattingTableView.delegate = self
//        chattingTableView.dataSource = self
//
        messageTextView.delegate = self
        
        // 키보드 포커싱 해제 메서드 호출
        setupKeyboardDismissRecognizer()
        
        setupConstraints()
        
        // Rx 바인딩
        setupBindings()
        
        // 키보드에 맞게 메세지입력뷰 조정 메서드
        bindKeyboardHeightToInputViewAdjustment(disposeBag: disposeBag)
    }
    
    // 현 화면에서 키보드 올라가는데 메세지입력뷰만 조정
    func bindKeyboardHeightToInputViewAdjustment(disposeBag: DisposeBag) {
        observeKeyboardHeight()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] keyboardHeight in
                UIView.animate(withDuration: 0.3) {
                    guard let self = self else { return }
                    
                    self.messageInputView.snp.remakeConstraints { make in
                        make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
                        
                        // 키보드가 보일 때 키보드 높이만큼 인셋
                        if keyboardHeight > 0 {
                            make.bottom.equalTo(self.view.snp.bottom).inset(keyboardHeight)
                        } else {
                            // 키보드가 사라질 때는 탭바 바로 위에 위치
                            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                        }
                    }
                    
                    // 레이아웃 업데이트
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        viewModel.messages
            .bind(to: chattingTableView.rx.items) { tableView, row, message in
                if message.isMyMessage {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: MyChattingTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as? MyChattingTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.messageBox.text = message.text
                    cell.date.text = message.date
                    return cell
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: ChattingTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as? ChattingTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.messageBox.text = message.text
                    cell.date.text = message.date
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        // sendButton 클릭 시 ViewModel에 메세지 전달
        sendButton.rx.tap
            .withLatestFrom(messageTextView.rx.text.orEmpty) // 버튼 눌렸을 때 텍스트뷰 내용 가져옴
            .bind(to: viewModel.messageText) // ViewModel의 MessageText에 바인딩
            .disposed(by: disposeBag)
        
        // 메세지 전송 후 텍스트뷰 초기화, 크기 초기화
        viewModel.messageText
            .map { _ in "" }
            .bind(to: messageTextView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.messageText
            .subscribe(onNext: { [weak self] _ in
                self?.resetMessageTextViewHeight()
            })
            .disposed(by: disposeBag)
        
        // 메세지 추가 후 테이블뷰 맨 아래로 스크롤
        viewModel.messages
            .skip(1) // 처음 초기화값 건너뛰고 이후 변경될 때 반응
            .subscribe(onNext: { [weak self] _ in
                self?.scrollToBottom()
            })
            .disposed(by: disposeBag)
    }
    
    // 제일 밑 채팅 보이기
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom()
    }
    
    func setupConstraints() {
        
        navigationController?.navigationBar.tintColor = UIColor.puppyPurple
        navigationItem.title = "한강산책톡" // 여기에 가져온 title정보 나오게
        
        chattingTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(messageInputView.snp.top)
        }
        
        messageInputView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        messageTextView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
            $0.height.lessThanOrEqualTo(100).priority(.required)
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
