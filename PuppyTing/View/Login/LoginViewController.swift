//
//  LoginViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 8/27/24.
//

import AuthenticationServices
import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class LoginViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let loginViewModel = LoginViewModel()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "이웃과 함께하는 반려견 산책"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "puppytingTextLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "appleLogin"), for: .normal)
        return button
    }()
    
    private let googleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "googleLogin"), for: .normal)
        return button
    }()
    
    private let pptLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "puppytingLogin"), for: .normal)
//        button.backgroundColor = UIColor.puppyPurple
//        button.setTitle("퍼피팅 아이디로 로그인", for: .normal)
//        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    //ksh
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindData()
        setButtonAction()
    }
    
    // UI 작업 - jgh
    // ksh 수정
    func setupUI() {
        [appleLoginButton, googleLoginButton, pptLoginButton].forEach {
            buttonStack.addArrangedSubview($0)
        }
        
        [logoLabel, logoImageView, buttonStack].forEach {
            view.addSubview($0)
        }

        //let screenHeight = UIScreen.main.bounds.height // 화면 높이
        
        logoLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(logoImageView.snp.top).offset(-10)
        }
        
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(-40)
            $0.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.6)
        }
        
        buttonStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.25)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
        }
        
//        appleLoginButton.snp.makeConstraints {
//            $0.top.equalTo(logoImageView.snp.bottom).offset(screenHeight * 0.06)
//            $0.centerX.equalTo(view.safeAreaLayoutGuide)
//        }
//        
//        googleLoginButton.snp.makeConstraints {
//            $0.top.equalTo(appleLoginButton.snp.bottom).offset(screenHeight * 0.02)
//            $0.centerX.equalTo(view.safeAreaLayoutGuide)
//        }
//        
//        pptLoginButton.snp.makeConstraints {
//            $0.top.equalTo(googleLoginButton.snp.bottom).offset(screenHeight * 0.02)
//            $0.centerX.equalTo(view.safeAreaLayoutGuide)
//            $0.leading.equalTo(appleLoginButton.snp.leading)
//            $0.trailing.equalTo(appleLoginButton.snp.trailing)
//            $0.height.equalTo(appleLoginButton)
//        }
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
        pptLoginButton.addTarget(self, action: #selector(didTapPuppytingLogin), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(didTapGoogleLoginButton), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(didTapAppleLoginButton), for: .touchUpInside)
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
    
    @objc
    private func didTapAppleLoginButton() {
        let nonce = loginViewModel.startAppleLogin()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func isExistsUser(uuid: String) {
        loginViewModel.isExistsUser(uuid: uuid)
    }
    
    private func signUp() {
        guard let user = loginViewModel.user, let email = user.email else { return }
        loginViewModel.signUp(uuid: user.uid, email: email)
    }
    
    private func endSignIn() {
        okAlert(title: LoginMessage().socialLoginSuccess, message: LoginMessage().loginSuccessMessage) { _ in
            AppController.shared.setHome()
        }
    }
    
    private func error(error: Error) {
        if let error = error as? AuthError {
            switch error {
            case .ClientIdinvalidError:
                okAlert(title: LoginFailMessage().socialLoginFail, message: LoginFailMessage().otherFailMessage)
            case .GoogleSignInFailError:
                okAlert(title: LoginFailMessage().socialLoginFail, message: LoginFailMessage().otherFailMessage)
            case .TokeninvalidError:
                okAlert(title: LoginFailMessage().socialLoginFail, message: LoginFailMessage().otherFailMessage)
            default:
                okAlert(title: LoginFailMessage().socialLoginFail, message: LoginFailMessage().otherFailMessage)
            }
        }
    }
    
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // 성공적으로 Apple ID 자격 증명을 받으면 ViewModel을 통해 Firebase와 연동
            loginViewModel.appleSignIn(credential: appleIDCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 에러 로그 출력
        print("Apple SignIn Failed: \(error.localizedDescription)")
    }
}
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    // 로그인 화면을 표시할 창을 반환
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window! // 현재 ViewController의 창을 반환
    }
}
