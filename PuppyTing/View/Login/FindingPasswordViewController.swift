//
//  FindingPasswordViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/2/24.
//

import UIKit

import SnapKit

class FindingPasswordViewController: UIViewController {
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let findingLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 찾기"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    let fdGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호를 변경할 계정의 이메일을 입력해 주세요."
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일"
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    let certifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("인증", for: .normal)
        button.backgroundColor = UIColor.puppyPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configUI()
        setButtonAction()
    }
    
    private func configUI() {
        [closeButton, findingLabel, fdGuideLabel, emailTextField, certifyButton].forEach {
            view.addSubview($0)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.height.width.equalTo(44)
        }
        
        findingLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(70)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        fdGuideLabel.snp.makeConstraints {
            $0.top.equalTo(findingLabel.snp.bottom).offset(10)
            $0.leading.equalTo(findingLabel.snp.leading)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(250)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(44)
        }
        
        certifyButton.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(30)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(44)
        }
    }
    
    private func setButtonAction() {
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapCloseButton() {
        dismiss(animated: true)
    }
}
