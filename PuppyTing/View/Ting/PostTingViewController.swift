//
//  PostTingViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/28/24.
//

import CoreLocation
import UIKit

import FirebaseAuth

class PostTingViewController: UIViewController {
    
    var placeName: String?
    var roadAddressName: String?
    var coordinate: CLLocationCoordinate2D?
    
    let mapController = SearchedMapViewController()
    
    //MARK: UI Component 선언
    private lazy var addMapButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "장소 추가"
        config.image = UIImage(systemName: "location.fill.viewfinder")
        config.imagePadding = 10
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .puppyPurple
        config.cornerStyle = .large
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(addMapButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = "언제, 어디서 산책하실 건가요? 산책 일정을 공유하는 퍼피팅 친구를 만나보세요!"
        textView.textColor = .gray
        textView.font = .systemFont(ofSize: 16, weight: .medium)
        textView.delegate = self
        return textView
    }()

    //MARK: View 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        setupKeyboardDismissRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    //MARK: 메서드
    @objc
    private func addButtonTapped() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("유저 정보가 없습니다.")
            return
        }
        let coordinate = self.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let content = textView.text ?? "내용 없음"
        let model = TingFeedModel(userid: userID,
                                  postid: "",
                                  location: coordinate,
                                  content: content,
                                  time: Date())
        let viewModel = PostingViewModel()
        viewModel.create(collection: "tingFeeds", model: model)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func addMapButtonTapped() {
        navigationController?.pushViewController(SearchAddressViewController(), animated: true)
    }
    
    @objc
    func handleMapInfo(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        placeName = userInfo["placeName"] as? String
        roadAddressName = userInfo["roadAddressName"] as? String
        coordinate = userInfo["coordinate"] as? CLLocationCoordinate2D
    }

    //MARK: UI 설정 및 제약조건 등
    private func setUI() {
        let addButton = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(addButtonTapped))
        view.backgroundColor = .white
        self.navigationItem.title = "퍼피팅 찾기"
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.rightBarButtonItem?.tintColor = .puppyPurple
    }
    
    private func setConstraints() {
        [addMapButton, textView]
            .forEach { view.addSubview($0) }
        
        addMapButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(44)
            $0.width.equalTo(100)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(addMapButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
}

extension PostTingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
        textView.textColor = .gray
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "언제, 어디서 산책하실 건가요? 산책 일정을 공유하는 퍼피팅 친구를 만나보세요!"
            textView.textColor = .gray
        }
    }
}
