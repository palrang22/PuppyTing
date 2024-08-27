//
//  SignupViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 8/27/24.
//

import UIKit
 import SnapKit
 import RxSwift
 import RxCocoa

class SignupViewController: UIViewController {
    var disposeBag = DisposeBag()
    
    let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let pwRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}" // 8자리 ~ 50자리 영어+숫자+특수문자
    
    // MARK: - UI Components
    
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
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("   인증하기   ", for: .normal)
        button.backgroundColor = UIColor(red: 165/255, green: 147/255, blue: 224/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let pwLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let pwTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        return textField
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
    
    let confirmPwTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
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
    
    let nickTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "2~10자 이내로 입력해주세요."
        textField.borderStyle = .roundedRect
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
    }
    
    private func configureUI() {
        [cancleButton, emailLabel, emailTextField, verifyButton, pwLabel, pwTextField, eTrueLable, eFalseLable, pTrueLable, pFalseLable, confirmLabel, confirmPwTextField, cTrueLable, cFalseLable, nickLabel, nickTextField, nTrueLable, nFalseLable, signUpButton].forEach {
            view.addSubview($0)
        }
        
        cancleButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.height.width.equalTo(44)
        }
        
        emailLabel.snp.makeConstraints {
            $0.bottom.equalTo(emailTextField.snp.top).offset(-6)
            $0.leading.equalTo(emailTextField.snp.leading)
        }
        
        emailTextField.snp.makeConstraints {
            $0.bottom.equalTo(pwTextField.snp.top).offset(-50)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(40)
        }
        
        pwLabel.snp.makeConstraints {
            $0.bottom.equalTo(pwTextField.snp.top).offset(-6)
            $0.leading.equalTo(pwTextField)
        }
        
        pwTextField.snp.makeConstraints {
            $0.bottom.equalTo(confirmPwTextField.snp.top).offset(-50)
            $0.leading.equalTo(emailTextField.snp.leading)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
            $0.trailing.equalTo(emailTextField.snp.trailing)
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
            $0.bottom.equalTo(confirmPwTextField.snp.top).offset(-6)
            $0.leading.equalTo(pwTextField)
        }
        
        confirmPwTextField.snp.makeConstraints {
            $0.bottom.equalTo(nickTextField.snp.top).offset(-50)
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
            $0.bottom.equalTo(nickTextField.snp.top).offset(-6)
            $0.leading.equalTo(pwTextField)
        }
        
        nickTextField.snp.makeConstraints {
            $0.bottom.equalTo(signUpButton.snp.top).offset(-100)
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
            $0.height.equalTo(50)
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
}

