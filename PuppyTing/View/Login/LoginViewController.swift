//
//  LoginViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 8/27/24.
//

import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class LoginViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private let loginViewModel = LoginViewModel()
    
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
        bindData()
        setButtonAction()
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
    
    private func bindData() {
        loginViewModel.userSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] user in
            self?.isExistsUser(uuid: user.uid)
        }).disposed(by: disposeBag)
        loginViewModel.userExistsSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] exists in
            if exists {
                self?.endSignIn()
            } else {
                self?.signUp()
            }
        }).disposed(by: disposeBag)
        loginViewModel.memeberSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] member in
            self?.endSignIn()
        }).disposed(by: disposeBag)
        loginViewModel.errorSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] error in
            self?.error(error: error)
        }).disposed(by: disposeBag)
        loginViewModel.memberErrorSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] error in
            self?.error(error: error)
        }).disposed(by: disposeBag)
    }
    
    private func setButtonAction() {
        pptLogButton.addTarget(self, action: #selector(didTapPuppytingLogin), for: .touchUpInside)
        ggLogButton.addTarget(self, action: #selector(didTapGoogleLoginButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapPuppytingLogin() {
        let pptLoginViewController = PptLoginViewController()
        pptLoginViewController.modalPresentationStyle = .fullScreen
        present(pptLoginViewController, animated: true)
    }
    
    @objc
    private func didTapGoogleLoginButton() {
        loginViewModel.googleSignIn(viewController: self)
    }
    
    private func isExistsUser(uuid: String) {
        loginViewModel.isExistsUser(uuid: uuid)
    }
    
    private func signUp() {
        guard let user = loginViewModel.user, let email = user.email else { return }
        loginViewModel.signUp(uuid: user.uid, email: email)
    }
    
    private func endSignIn() {
        okAlert(title: "소셜 로그인", message: "로그인이 완료되었습니다.", okActionTitle: "OK") { _ in
            AppController.shared.setHome()
        }
    }
    
    private func error(error: Error) {
        if let error = error as? AuthError {
            switch error {
            case .ClientIdinvalidError:
                okAlert(title: "소셜 로그인 실패", message: "관리자 문의 필요함", okActionTitle: "ok")
            case .GoogleSignInFailError:
                okAlert(title: "소셜 로그인 실패", message: "관리자 문의 필요함", okActionTitle: "ok")
            case .TokeninvalidError:
                okAlert(title: "소셜 로그인 실패", message: "관리자 문의 필요함", okActionTitle: "ok")
            default:
                okAlert(title: "로그인 실패", message: "알 수 없는 이유로 로그인에 실패했습니다.", okActionTitle: "다시 로그인 시도하기")
            }
        }
    }
    
}
