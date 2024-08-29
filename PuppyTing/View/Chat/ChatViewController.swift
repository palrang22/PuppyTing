//
//  ChatViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import UIKit

import SnapKit

class ChatViewController: UIViewController {
    
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
    
    // 메세지 예시
    var messages: [(isMyMessage: Bool, text: String, date: String)] = [
        (true, "안녕하세요!", "10:00"),
        (false, "안녕하세요~ 반가워요!", "10:05"),
        (true, "오늘 산책 가능하신거죠?", "10:20"),
        (false, "넵! 가능합니다!", "11:00"),
        (true, "네넹 어디어디에서 산채갛시소 어쩌고저쩌고 블라블라 어디까지 나오고 칸이 넘어가나 블라블라", "11:25"),
        (false, "djWjdlsjfioefjlskdjksjlfksjdfjsdifjsdlkvjlksdjviosdjklvjeiofjslkdklfjsdjklsfjksdljfsklfjlskdfjklsdfjlksdfjlkdsjflksdjfkldsjflkdsjfkljsdklfmcvklsdjvioerjvklsdvdssfjdiodfjd", "11:50"),
        (true, "lfjsioeejslkflkdjfskfaslfkdsfsdjfsㄴ런러ㅐㅑㄷ저ㅣㅏ너랴ㅐㅇㄹ니ㅏ런ㅇSDJFOiejlksjdoifjsdklfjsdklfjsdlkfjsdfiosdfjklsfjdklfjsdifjsdfjsjfkld", "10:20"),
        (false, "넵! 가능합니다!", "11:00"),
        (true, "네넹 어디어디에서 산채갛시소 어쩌고저쩌고 블라블라 어디까지 나오고 칸이 넘어가나 블라블라", "11:25"),
        (false, "djWjdlsjfioefjlskdjksjlfksjdfjsdifjsdlkvjlksdjviosdjklvjeiofjslkdklfjsdjklsfjksdljfsklfjlskdfjklsdfjlksdfjlkdsjflksdjfkldsjflkdsjfkljsdklfmcvklsdjvioerjvklsdvdssfjdiodfjd", "11:50"),
        (true, "lfjsioeejslkflkdjfskfaslfkdsfsdjfsㄴ런러ㅐㅑㄷ저ㅣㅏ너랴ㅐㅇㄹ니ㅏ런ㅇSDJFOiejlksjdoifjsdklfjsdklfjsdlkfjsdfiosdfjklsfjdklfjsdifjsdfjsjfkld", "10:20"),
        (false, "넵! 가능합니다!", "11:00")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Large Title 해제
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = .white
        
        view.addSubview(chattingTableView)
        view.addSubview(messageInputView)
        messageInputView.addSubview(messageTextView)
        messageInputView.addSubview(sendButton)
        
        chattingTableView.delegate = self
        chattingTableView.dataSource = self
        
        messageTextView.delegate = self
        
        setupConstraints()
    }
    
    func setupConstraints() {
        
        navigationController?.navigationBar.tintColor = UIColor.puppyPurple
        navigationItem.title = "한강산책톡" // 여기에 가져온 title정보 나오게
        
        chattingTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(messageInputView.snp.top)
        }
        
        messageInputView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
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
    
//    func setupSendButtonAction() {
//        sendButton.addTarget(self, action: #selector(), for: .touchUpInside)
//    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message.isMyMessage {
            // 내 메시지인 경우 MyChattingTableViewCell 사용
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MyChattingTableViewCell.identifier, for: indexPath) as? MyChattingTableViewCell else {
                return UITableViewCell()
            }
            // 셀의 텍스트와 날짜 설정
            cell.messageBox.text = message.text
            cell.date.text = message.date
            return cell
        } else {
            // 상대방의 메시지인 경우 ChattingTableViewCell 사용
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChattingTableViewCell.identifier, for: indexPath) as? ChattingTableViewCell else {
                return UITableViewCell()
            }
            // 셀의 텍스트와 날짜 설정
            cell.messageBox.text = message.text
            cell.date.text = message.date
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().inset(8)
            $0.height.equalTo(min(estimatedSize.height, 100)) // 기존 높이 또는 100중 작은 값으로 설정
        }
    }
}
