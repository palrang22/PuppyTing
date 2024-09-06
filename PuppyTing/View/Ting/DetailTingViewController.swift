//
//  DetailTingViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/28/24.
//

import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift

class DetailTingViewController: UIViewController {
    
    var tingFeedModels: TingFeedModel?
    let fireStoreDatabase = FireStoreDatabaseManager.shared
    private let disposeBag = DisposeBag()
    
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
                                            "내용1\n내용2\n내용3\n내용4"
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
    
    private lazy var blockButton: UIButton = {
        let button = UIButton()
        button.setTitle("차단하기", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .white
        
//        button.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("신고하기", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .white
        
//        button.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("삭제하기", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .white
//        
//        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
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
        setData()
        bind()
    }
    
    //MARK: bind
    
    func setData() {
        if let model = tingFeedModels {
            content.text = model.content
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            timeLabel.text = dateFormatter.string(from: model.time)
            setButton(model: model)
            
            FireStoreDatabaseManager.shared.findMemeber(uuid: model.userid)
                .subscribe(onSuccess: { [weak self] member in
                    self?.nameLabel.text = member.nickname
                    self?.footPrintLabel.text = "🐾 발도장 \(member.footPrint)개"
                }, onFailure: { error in
                    print("멤버 찾기 실패: \(error)")
                }).disposed(by: disposeBag)
        }
    }
    
    private func setButton(model: TingFeedModel) {
        if Auth.auth().currentUser?.uid == model.userid {
            self.deleteButton.isHidden = false
            self.blockButton.isHidden = true
            self.reportButton.isHidden = true
        } else {
            self.deleteButton.isHidden = true
            self.blockButton.isHidden = false
            self.reportButton.isHidden = false
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
                                    self?.okAlert(
                                        title: "삭제 완료",
                                        message: "게시물이 성공적으로 삭제되었습니다.",
                                        okActionHandler: { _ in
                                            self?.navigationController?.popViewController(animated: true)
                                        }
                                    )
                                }, onFailure: { error in
                                    print("삭제 실패: \(error)")
                                    self?.okAlert(
                                        title: "삭제 실패",
                                        message: "게시물 삭제에 실패했습니다. 다시 시도해주세요. 해당 문제가 지속될 경우 문의 게시판에 제보해주세요."
                                    )
                                }).disposed(by: self?.disposeBag ?? DisposeBag())
                        }
                    )
            }).disposed(by: disposeBag)
        
        blockButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let userid = self?.tingFeedModels?.userid else { return }
                self?.fireStoreDatabase.blockUser(userId: userid)
                    .subscribe(onSuccess: { [weak self] in
                        self?.okAlertWithCancel(
                                        title: "사용자 차단",
                                        message: "사용자를 차단하시겠습니까? 차단 이후 사용자의 게시물이 보이지 않습니다.",
                                        okActionTitle: "차단",
                                        okActionHandler: { _ in
                                        self!.okAlert(title: "차단 완료", message: "사용자가 성공적으로 차단되었습니다.")
                                    })
                    }, onFailure: { error in
                        print("차단 실패")
                        self!.okAlert(title: "차단 실패", message: "사용자 차단에 실패했습니다. 다시 시도해주세요.\n해당 문제가 지속될 경우 문의 게시판에 제보해주세요.")
                    }).disposed(by: self!.disposeBag)
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
                    let action = UIAlertAction(title: reason, style: .default) { _ in
                        self?.fireStoreDatabase.reportPost(postId: postid, reason: reason)
                            .subscribe(onSuccess: {
                                self!.okAlert(title: "신고 접수", message: "신고가 접수되었습니다. 관리자가 24시간 이내로 검토할 예정이며, 추가 신고/문의는 nnn@naver.com 으로 보내주세요.", okActionHandler: { _ in
                                    self?.navigationController?.popViewController(animated: true)
                                })
                            }, onFailure: { error in
                            print("신고 실패")
                                self?.okAlert(title: "신고 실패", message: "게시글 신고에 실패했습니다. 다시 시도해주세요.\n해당 문제가 지속될 경우 문의 게시판에 제보해주세요.")
                            }).disposed(by: self!.disposeBag)
                    }
                    reportAlert.addAction(action)
                }
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                reportAlert.addAction(cancelAction)
                
                self!.present(reportAlert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
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
