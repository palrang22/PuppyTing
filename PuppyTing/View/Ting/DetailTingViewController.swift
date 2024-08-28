//
//  DetailTingViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/28/24.
//

import UIKit

class DetailTingViewController: UIViewController {
    //MARK: Component 선언
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
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
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
        label.text = "🐾 발도장 n개"
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
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        let styleText = NSAttributedString(string:
                                            "오늘 어디어디에서 산책하실 분 있나요? 경로는 아직 구체적으로 정해지지 않았지만 대략적인 방향은 잡아두었습니다. 산책시간은 오후 늦게쯤을 생각하고 있어요. 함께 산책하면 더욱 즐거운 시간이 될 것 같아요! 강아지와 함께 가볍게 산책하며 좋은 시간을 보내고 싶다면 꼭 함께해 주세요. 이따가 만나서 즐거운 시간을 보내면 좋겠습니다! 날씨도 좋으니, 산책 후에는 근처 카페에서 차 한 잔 하며 쉬어가도 좋을 것 같아요.\n오늘 어디어디에서 산책하실 분 있나요? 경로는 아직 구체적으로 정해지지 않았지만 대략적인 방향은 잡아두었습니다. 산책시간은 오후 늦게쯤을 생각하고 있어요. 함께 산책하면 더욱 즐거운 시간이 될 것 같아요! 강아지와 함께 가볍게 산책하며 좋은 시간을 보내고 싶다면 꼭 함께해 주세요. 이따가 만나서 즐거운 시간을 보내면 좋겠습니다! 날씨도 좋으니, 산책 후에는 근처 카페에서 차 한 잔 하며 쉬어가도 좋을 것 같아요.\n오늘 어디어디에서 산책하실 분 있나요? 경로는 아직 구체적으로 정해지지 않았지만 대략적인 방향은 잡아두었습니다. 산책시간은 오후 늦게쯤을 생각하고 있어요. 함께 산책하면 더욱 즐거운 시간이 될 것 같아요! 강아지와 함께 가볍게 산책하며 좋은 시간을 보내고 싶다면 꼭 함께해 주세요. 이따가 만나서 즐거운 시간을 보내면 좋겠습니다! 날씨도 좋으니, 산책 후에는 근처 카페에서 차 한 잔 하며 쉬어가도 좋을 것 같아요.\n오늘 어디어디에서 산책하실 분 있나요? 경로는 아직 구체적으로 정해지지 않았지만 대략적인 방향은 잡아두었습니다. 산책시간은 오후 늦게쯤을 생각하고 있어요. 함께 산책하면 더욱 즐거운 시간이 될 것 같아요! 강아지와 함께 가볍게 산책하며 좋은 시간을 보내고 싶다면 꼭 함께해 주세요. 이따가 만나서 즐거운 시간을 보내면 좋겠습니다! 날씨도 좋으니, 산책 후에는 근처 카페에서 차 한 잔 하며 쉬어가도 좋을 것 같아요.\n오늘 어디어디에서 산책하실 분 있나요? 경로는 아직 구체적으로 정해지지 않았지만 대략적인 방향은 잡아두었습니다. 산책시간은 오후 늦게쯤을 생각하고 있어요. 함께 산책하면 더욱 즐거운 시간이 될 것 같아요! 강아지와 함께 가볍게 산책하며 좋은 시간을 보내고 싶다면 꼭 함께해 주세요. 이따가 만나서 즐거운 시간을 보내면 좋겠습니다! 날씨도 좋으니, 산책 후에는 근처 카페에서 차 한 잔 하며 쉬어가도 좋을 것 같아요.\n오늘 어디어디에서 산책하실 분 있나요? 경로는 아직 구체적으로 정해지지 않았지만 대략적인 방향은 잡아두었습니다. 산책시간은 오후 늦게쯤을 생각하고 있어요. 함께 산책하면 더욱 즐거운 시간이 될 것 같아요! 강아지와 함께 가볍게 산책하며 좋은 시간을 보내고 싶다면 꼭 함께해 주세요. 이따가 만나서 즐거운 시간을 보내면 좋겠습니다! 날씨도 좋으니, 산책 후에는 근처 카페에서 차 한 잔 하며 쉬어가도 좋을 것 같아요.\n"
                                           , attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .paragraphStyle: style])
        label.attributedText = styleText
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let mapView: UIImageView = {
        let map = UIImageView()
        map.image = UIImage(named: "mapPhoto")
        return map
    }()
    
    private let blockButton: UIButton = {
        let button = UIButton()
        button.setTitle("차단하기", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .white
        return button
    }()
    
    private let reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("신고하기", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .white
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("삭제하기", for: .normal)
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

    //MARK: View 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
    }
    
    //MARK: bind 메서드
    private func bind() {
        
    }
    
    //MARK: UI 설정 및 제약조건 등
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
        [deleteButton, blockButton, reportButton]
            .forEach { buttonStack.addArrangedSubview($0) }
        [profilePic,
         infoStack,
         footPrintLabel,
         content,
         buttonStack,
         mapView,
         messageSendButton].forEach { contentView.addSubview($0) }
        
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
        
        content.snp.makeConstraints {
            $0.top.equalTo(profilePic.snp.bottom).offset(40)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        
        mapView.snp.makeConstraints {
            $0.top.equalTo(content.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(150)
        }
        
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(20)
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
