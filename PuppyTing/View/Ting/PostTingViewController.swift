//
//  PostTingViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/28/24.
//

import UIKit

class PostTingViewController: UIViewController {
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
        
    }
    
    @objc
    private func addMapButtonTapped() {
        navigationController?.pushViewController(SearchAddressViewController(), animated: true)
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
