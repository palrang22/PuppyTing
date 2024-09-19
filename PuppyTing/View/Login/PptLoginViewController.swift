//
//  PptLoginViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 8/27/24.
//

import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class PptLoginViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    private let pptLoginViewModel = PptLoginViewModel()
    
    let eRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let pRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}" // 8자리 ~ 50자리 영어+숫자+특수문자
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "puppytingTextLogo") // 이후 로고 들어갈 자리
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let emailfield: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일을 입력하세요."
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    let pwfield: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력하세요."
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
        textField.isSecureTextEntry = true // 비밀번호 입력 숨기기
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
    
    let findPwButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("비밀번호 찾기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        settingUI()
        bind()
        bindData()
        setButtonAction()
        
        // 키보드 포커싱 해제 메서드 호출
        setupKeyboardDismissRecognizer()
    }
    
    private func settingUI() {
        [closeButton, logoImageView, emailfield, pwfield, loginButton, signupButton, findPwButton].forEach {
            view.addSubview($0)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.height.width.equalTo(44)
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
        
        findPwButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
    }
    
    private func bind() {
        let emailValid = emailfield.rx.text.orEmpty
            .map { [weak self] email in
                return self?.checkEmailValid(email) ?? false
            }
            .share(replay: 1, scope: .whileConnected)
        
        let pwValid = pwfield.rx.text.orEmpty
            .map { [weak self] password in
                return self?.checkPasswordValid(password) ?? false
            }
            .share(replay: 1, scope: .whileConnected)
        
        Observable.combineLatest(emailValid, pwValid) { $0 && $1 }
            .subscribe(onNext: { [weak self] isValid in
                self?.loginButton.isEnabled = isValid
            })
            .disposed(by: disposeBag)

    }
    
    private func bindData() {
        pptLoginViewModel.userSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] user in
            self?.login()
        }).disposed(by: disposeBag)
        pptLoginViewModel.errorSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] error in
            self?.error(error: error)
        }).disposed(by: disposeBag)
    }

    // 이메일 유효성 검사
    private func checkEmailValid(_ email: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", eRegex)
        return predicate.evaluate(with: email)
    }

    // 비밀번호 유효성 검사
    private func checkPasswordValid(_ password: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pRegex)
        return predicate.evaluate(with: password)
    }
    
    private func setButtonAction() {
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        findPwButton.addTarget(self, action: #selector(didTapFindPwButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapSignUpButton() {
        let SignupViewController = SignupViewController()
        SignupViewController.modalPresentationStyle = .fullScreen
        present(SignupViewController, animated: true)
    }
    
    @objc
    private func didTapCloseButton() {
        dismiss(animated: true)
    }
    
    @objc
    private func didTapFindPwButton() {
        let FindingPassWordVC = FindingPasswordViewController()
        FindingPassWordVC.modalPresentationStyle = .fullScreen
        present(FindingPassWordVC, animated: true)
    }
    
    @objc
    private func didTapLoginButton() {
        guard let email = emailfield.text, let pw = pwfield.text else { return }
        pptLoginViewModel.emailSignIn(email: email, pw: pw)
    }
    
    private func login() {
        okAlert(title: "로그인 완료", message: "로그인이 완료되었습니다.", okActionTitle: "OK") { _ in
            AppController.shared.setHome()
        }
    }
    
    private func error(error: Error) {
        if let error = error as? AuthError {
            switch error {
            case .EmailVerificationFailError:
                okAlert(title: "로그인 실패", message: "이메일 인증에 실패했습니다.", okActionTitle: "ok")
            case .InvalidCredential:
                okAlert(title: "로그인 실패", message: "이메일 혹은 비밀번호가 잘못 입력 되었습니다.", okActionTitle: "ok")
            default:
                okAlert(title: "로그인 실패", message: "알 수 없는 이유로 로그인에 실패했습니다.", okActionTitle: "다시 로그인 시도하기")
            }
        }
    }
}
