//
//  PptLoginViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 8/27/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class PptLoginViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "appleLogin") // 이후 로고 들어갈 자리
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let emailfield: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일을 입력하세요."
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let pwfield: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력하세요."
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.puppyPurple
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.puppyPurple
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        settingUI()
    }
    
    private func settingUI() {
        [logoImageView, emailfield, pwfield, loginButton, signupButton].forEach {
            view.addSubview($0)
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        emailfield.snp.makeConstraints {
            $0.bottom.equalTo(pwfield.snp.top).offset(-15)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.height.equalTo(signupButton)
        }
        
        pwfield.snp.makeConstraints {
            $0.bottom.equalTo(loginButton.snp.top).offset(-15)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.height.equalTo(signupButton)
        }
        
        loginButton.snp.makeConstraints {
            $0.bottom.equalTo(signupButton.snp.top).offset(-15)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.height.equalTo(signupButton)
        }
        
        signupButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-130) // 모든화면 맨 밑 버튼 고정 위치
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.width.equalTo(281)
            $0.height.equalTo(44)
        }
    }
}
