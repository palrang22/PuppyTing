//
//  LoginViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 8/27/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class LoginViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "appleLogin") // 이후 수정
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let appleLogButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "appleLogin"), for: .normal)
        return button
    }()
    
    let ggLogButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "googleLogin"), for: .normal)
        return button
    }()
    
    let pptLogButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.puppyPurple
        button.setTitle("퍼피팅 아이디로 로그인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        
        [logoImageView, appleLogButton, ggLogButton, pptLogButton].forEach {
            view.addSubview($0)
        }

        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.width.height.equalTo(100)
        }
        
        appleLogButton.snp.makeConstraints {
            $0.bottom.equalTo(ggLogButton.snp.top).offset(-15)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        ggLogButton.snp.makeConstraints {
            $0.bottom.equalTo(pptLogButton.snp.top).offset(-15)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        pptLogButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-130)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(appleLogButton.snp.leading)
            $0.trailing.equalTo(appleLogButton.snp.trailing)
            $0.height.equalTo(appleLogButton)
        }
    }
}
