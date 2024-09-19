//
//  SignupViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 8/27/24.
//

import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class SignupViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let pwRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}" // 8자리 ~ 50자리 영어+숫자+특수문자
    
    let signUpViewModel = SignUpViewModel()

    let cancleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let emailCheck: UILabel = {
        let label = UILabel()
        label.text = "(필수)"
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    let pwLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let pwCheck: UILabel = {
        let label = UILabel()
        label.text = "(필수)"
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let pwTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
        textField.isSecureTextEntry = true // 비밀번호 입력 숨기기
        return textField
    }()
    
    let guideLine: UILabel = {
        let label = UILabel()
        label.text = "대소문자, 숫자, 특수문자를 포함하여 8자 이상으로 작성"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let eTrueLable: UILabel = {
        let label = UILabel()
        label.text = "✓"
        label.textColor = .green
        return label
    }()
    
    let eFalseLable: UILabel = {
        let label = UILabel()
        label.text = "✕"
        label.textColor = .red
        return label
    }()
    
    let pTrueLable: UILabel = {
        let label = UILabel()
        label.text = "✓"
        label.textColor = .green
        return label
    }()
    
    let pFalseLable: UILabel = {
        let label = UILabel()
        label.text = "✕"
        label.textColor = .red
        return label
    }()
    
    let confirmLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 확인"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let confirmCheck: UILabel = {
        let label = UILabel()
        label.text = "(필수)"
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let confirmPwTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
        textField.isSecureTextEntry = true // 비밀번호 입력 숨기기
        return textField
    }()
    
    let cTrueLable: UILabel = {
        let label = UILabel()
        label.text = "✓"
        label.textColor = .green
        return label
    }()
    
    let cFalseLable: UILabel = {
        let label = UILabel()
        label.text = "✕"
        label.textColor = .red
        return label
    }()
    
    let nickLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let nickCheck: UILabel = {
        let label = UILabel()
        label.text = "(필수)"
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let nickTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "2~10자 이내로 입력해주세요."
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    let nTrueLable: UILabel = {
        let label = UILabel()
        label.text = "✓"
        label.textColor = .green
        return label
    }()
    
    let nFalseLable: UILabel = {
        let label = UILabel()
        label.text = "✕"
        label.textColor = .red
        return label
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.backgroundColor = UIColor.puppyPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        bindUI()
        setButtonAction()
        bindData()
        
        // 키보드 포커싱 해제 메서드 호출
        setupKeyboardDismissRecognizer()
    }
    
    private func configureUI() {
        [cancleButton, emailLabel, emailCheck, emailTextField, pwLabel, pwCheck, pwTextField, guideLine, eTrueLable, eFalseLable, pTrueLable, pFalseLable, confirmLabel, confirmCheck, confirmPwTextField, cTrueLable, cFalseLable, nickLabel, nickCheck, nickTextField, nTrueLable, nFalseLable, signUpButton].forEach {
            view.addSubview($0)
        }
        
        cancleButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.height.width.equalTo(44)
        }
        
        emailLabel.snp.makeConstraints {
            $0.bottom.equalTo(emailTextField.snp.top).offset(-7)
            $0.leading.equalTo(emailTextField.snp.leading)
        }
        
        emailCheck.snp.makeConstraints {
            $0.centerY.equalTo(emailLabel.snp.centerY)
            $0.leading.equalTo(emailLabel.snp.trailing).offset(5)
        }
        
        emailTextField.snp.makeConstraints {
            $0.bottom.equalTo(pwTextField.snp.top).offset(-60)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(40)
        }
        
        pwLabel.snp.makeConstraints {
            $0.bottom.equalTo(pwTextField.snp.top).offset(-7)
            $0.leading.equalTo(pwTextField)
        }
        
        pwCheck.snp.makeConstraints {
            $0.centerY.equalTo(pwLabel.snp.centerY)
            $0.leading.equalTo(pwLabel.snp.trailing).offset(5)
        }
        
        pwTextField.snp.makeConstraints {
            $0.bottom.equalTo(confirmPwTextField.snp.top).offset(-90)
            $0.leading.equalTo(emailTextField.snp.leading)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
            $0.trailing.equalTo(emailTextField.snp.trailing)
        }
        
        guideLine.snp.makeConstraints {
            $0.top.equalTo(pwTextField.snp.bottom).offset(10)
            $0.leading.equalTo(pwTextField.snp.leading).offset(3)
        }
        
        eTrueLable.snp.makeConstraints {
            $0.centerY.equalTo(emailTextField.snp.centerY)
            $0.trailing.equalTo(emailTextField.snp.trailing).offset(-8)
            $0.width.height.equalTo(20)
        }
        
        eFalseLable.snp.makeConstraints {
            $0.centerY.equalTo(emailTextField.snp.centerY)
            $0.trailing.equalTo(emailTextField.snp.trailing).offset(-8)
            $0.width.height.equalTo(20)
        }
        
        pTrueLable.snp.makeConstraints {
            $0.centerY.equalTo(pwTextField.snp.centerY)
            $0.trailing.equalTo(pwTextField.snp.trailing).offset(-8)
            $0.width.height.equalTo(20)
        }
        
        pFalseLable.snp.makeConstraints {
            $0.centerY.equalTo(pwTextField.snp.centerY)
            $0.trailing.equalTo(pwTextField.snp.trailing).offset(-8)
            $0.width.height.equalTo(20)
        }
        
        confirmLabel.snp.makeConstraints {
            $0.bottom.equalTo(confirmPwTextField.snp.top).offset(-7)
            $0.leading.equalTo(pwTextField)
        }
        
        confirmCheck.snp.makeConstraints {
            $0.centerY.equalTo(confirmLabel.snp.centerY)
            $0.leading.equalTo(confirmLabel.snp.trailing).offset(5)
        }
        
        confirmPwTextField.snp.makeConstraints {
            $0.bottom.equalTo(nickTextField.snp.top).offset(-60)
            $0.leading.equalTo(emailTextField.snp.leading)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
            $0.trailing.equalTo(emailTextField.snp.trailing)
        }
        
        cTrueLable.snp.makeConstraints {
            $0.centerY.equalTo(confirmPwTextField.snp.centerY)
            $0.trailing.equalTo(confirmPwTextField.snp.trailing).offset(-8)
            $0.width.height.equalTo(20)
        }
        
        cFalseLable.snp.makeConstraints {
            $0.centerY.equalTo(confirmPwTextField.snp.centerY)
            $0.trailing.equalTo(confirmPwTextField.snp.trailing).offset(-8)
            $0.width.height.equalTo(20)
        }
        
        nickLabel.snp.makeConstraints {
            $0.bottom.equalTo(nickTextField.snp.top).offset(-7)
            $0.leading.equalTo(pwTextField)
        }
        
        nickCheck.snp.makeConstraints {
            $0.centerY.equalTo(nickLabel.snp.centerY)
            $0.leading.equalTo(nickLabel.snp.trailing).offset(5)
        }
        
        nickTextField.snp.makeConstraints {
            $0.bottom.equalTo(signUpButton.snp.top).offset(-70)
            $0.leading.equalTo(emailTextField.snp.leading)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
            $0.trailing.equalTo(emailTextField.snp.trailing)
        }
        
        nTrueLable.snp.makeConstraints {
            $0.centerY.equalTo(nickTextField.snp.centerY)
            $0.trailing.equalTo(nickTextField.snp.trailing).offset(-8)
            $0.width.height.equalTo(20)
        }
        
        nFalseLable.snp.makeConstraints {
            $0.centerY.equalTo(nickTextField.snp.centerY)
            $0.trailing.equalTo(nickTextField.snp.trailing).offset(-8)
            $0.width.height.equalTo(20)
        }
        
        signUpButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-130)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(44)
        }
    }
    
    private func bindUI() {
        emailTextField.rx.text.orEmpty
            .map { [weak self] email in
                let isValid = self?.checkEmailValid(email) ?? false
                return (isValid, email.isEmpty)
            }
            .subscribe(onNext: { isValid, isEmpty in
                self.eFalseLable.isHidden = isValid || isEmpty
                self.eTrueLable.isHidden = !isValid || isEmpty
            })
            .disposed(by: disposeBag)
        
        pwTextField.rx.text.orEmpty
            .map { [weak self] password in
                let isValid = self?.checkPasswordValid(password) ?? false
                return (isValid, password.isEmpty)
            }
            .subscribe(onNext: { isValid, isEmpty in
                self.pFalseLable.isHidden = isValid || isEmpty
                self.pTrueLable.isHidden = !isValid || isEmpty
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            pwTextField.rx.text.orEmpty,
            confirmPwTextField.rx.text.orEmpty
        )
        .map { password, confirmPw in
            return (confirmPw == password, confirmPw.isEmpty)
        }
        .subscribe(onNext: { isMatching, isEmpty in
            self.cFalseLable.isHidden = isMatching || isEmpty
            self.cTrueLable.isHidden = !isMatching || isEmpty
        })
        .disposed(by: disposeBag)
        
        nickTextField.rx.text.orEmpty
            .map { [weak self] nickName in
                let isValid = self?.checNickNameValid(nickName) ?? false
                return (isValid, nickName.isEmpty)
            }
            .subscribe(onNext: { isValid, isEmpty in
                self.nFalseLable.isHidden = isValid || isEmpty
                self.nTrueLable.isHidden = !isValid || isEmpty
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            emailTextField.rx.text.orEmpty.map(checkEmailValid),
            pwTextField.rx.text.orEmpty.map(checkPasswordValid),
            confirmPwTextField.rx.text.orEmpty.map { confirmPw in
                return confirmPw == self.pwTextField.text
            },
            nickTextField.rx.text.orEmpty.map(checNickNameValid)
        )
        .map { emailValid, passwordValid, confirmPasswordValid, nickNameValid in
            return emailValid && passwordValid && confirmPasswordValid && nickNameValid
        }
        .subscribe(onNext: { isValid in
            self.signUpButton.isEnabled = isValid
        })
        .disposed(by: disposeBag)
    }
    
    private func bindData() {
        signUpViewModel.userSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] user in
            self?.signUp(user: user)
        }).disposed(by: disposeBag)
        
        signUpViewModel.userErrorSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] error in
            self?.error(error: error)
        }).disposed(by: disposeBag)
        
        signUpViewModel.memeberSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] memeber in
            self?.endSignUp()
        }).disposed(by: disposeBag)
        
        signUpViewModel.memberErrorSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] error in
            self?.error(error: error)
        }).disposed(by: disposeBag)
    }
    
    // 이메일 유효성 검사
    private func checkEmailValid(_ email: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
    
    // 비밀번호 유효성 검사
    private func checkPasswordValid(_ password: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pwRegex)
        return predicate.evaluate(with: password)
    }
    
    // 닉네임 유효성 검사
    private func checNickNameValid(_ nickName: String) -> Bool {
        return nickName.count > 1 && nickName.count < 11
    }
    
    private func setButtonAction() {
        cancleButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapCloseButton() {
        dismiss(animated: true)
    }
    
    @objc
    private func didTapSignUpButton() {
        guard let email = emailTextField.text, let pw = pwTextField.text else { return }
        signUpViewModel.authentication(email: email, pw: pw)
    }
    
    private func signUp(user: User) {
        guard let email = user.email, let pw = pwTextField.text, let nickname = nickTextField.text else { return }
        signUpViewModel.signUp(uuid: user.uid, email: email, pw: pw, nickname: nickname)
    }
    
    private func endSignUp() {
        okAlert(title: "회원가입 완료", message: "회원가입이 완료되었습니다.\n이메일 인증을 하고 로그인을 진행해주세요!") { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
    
    private func error(error: Error) {
        if let error = error as? AuthError {
            switch error {
            case .CreateFailError:
                okAlert(title: "회원가입 실패", message: "회원가입에 실패했습니다.", okActionTitle: "ok")
            case .SendEmailFailError:
                okAlert(title: "회원가입 실패", message: "이메일 전송에 실패했습니다.", okActionTitle: "ok")
            default:
                okAlert(title: "회원가입 실패", message: "알 수 없는 이유로 회원가입에 실패했습니다.", okActionTitle: "ok")
            }
        } else {
            okAlert(title: "회원가입 실패", message: "알 수 없는 이유로 회원가입에 실패했습니다.", okActionTitle: "ok")
        }
    }
}

