//
//  TingCollectionViewCell.swift
//  PuppyTing
//
//  Created by 김승희 on 8/27/24.
//

import UIKit

import RxSwift

class TingCollectionViewCell: UICollectionViewCell {
    static let id = "tingCollectionViewCell"
    
    private let disposeBag = DisposeBag()
    
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
        return label
    }()
    
    // 추후 mapKit으로 수정예정
    private let mapView: UIImageView = {
        let map = UIImageView()
        map.image = UIImage(named: "mapPhoto")
        return map
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConstraints()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: config 메서드
    func configure(with model: TingFeedModel) {
        self.nameLabel.text = model.userid
        self.content.text = model.content

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        self.timeLabel.text = dateFormatter.string(from: model.time)
        self.footPrintLabel.text = "🐾 발도장 \(model.postid)개"
        
        FireStoreDatabaseManager.shared.findMemeber(uuid: model.userid)
            .subscribe(onSuccess: { [weak self] member in
                self?.nameLabel.text = member.nickname
                self?.footPrintLabel.text = "🐾 발도장 \(member.footPrint)개"
            }, onFailure: { error in
                print("멤버 찾기 실패: \(error)")
            }).disposed(by: disposeBag)

    }
    
    //MARK: UI 및 제약조건
    private func setLayout() {
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
    }
    
    private func setConstraints() {
        [nameLabel,
         timeLabel].forEach { infoStack.addArrangedSubview($0) }
        [shadowContainerView, profilePic,
         infoStack,
         footPrintLabel,
         content,
         mapView,
         messageSendButton].forEach { contentView.addSubview($0) }
        
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
        
        footPrintLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(profilePic)
        }
        
        content.snp.makeConstraints {
            $0.top.equalTo(profilePic.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        mapView.snp.makeConstraints {
            $0.top.equalTo(content.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(70)
        }
        
        messageSendButton.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }
}
