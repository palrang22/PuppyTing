//
//  ChangePasswordViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/2/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class ChangePasswordViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    let pwRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}" // 8자리 ~ 50자리 영어+숫자+특수문자
    
    let pwLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let pwTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    let guideLine: UILabel = {
        let label = UILabel()
        label.text = "대소문자, 특수문자를 포함하여 8자 이상으로 작성"
        label.textAlignment = .left
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
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
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
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
    
    let changePwButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("비밀번호 변경", for: .normal)
        button.backgroundColor = UIColor.puppyPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configUI()
        bindUI()
    }
    
    private func configUI() {
        [pwLabel, pwTextField, pTrueLable, pFalseLable, guideLine, confirmLabel, confirmPwTextField, cTrueLable, cFalseLable, changePwButton].forEach {
            view.addSubview($0)
        }
        
        pwLabel.snp.makeConstraints {
            $0.bottom.equalTo(pwTextField.snp.top).offset(-7)
            $0.leading.equalTo(pwTextField)
        }
        
        pwTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(40)
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
        
        guideLine.snp.makeConstraints {
            $0.top.equalTo(pwTextField.snp.bottom).offset(10)
            $0.leading.equalTo(pwTextField.snp.leading).offset(3)
        }
        
        confirmLabel.snp.makeConstraints {
            $0.bottom.equalTo(confirmPwTextField.snp.top).offset(-7)
            $0.leading.equalTo(pwTextField)
        }
        
        confirmPwTextField.snp.makeConstraints {
            $0.top.equalTo(pwTextField.snp.bottom).offset(80)
            $0.leading.equalTo(pwTextField.snp.leading)
            $0.height.equalTo(40)
            $0.trailing.equalTo(pwTextField.snp.trailing)
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
        
        changePwButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-130)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(44)
        }
    }
    
    private func bindUI() {
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
        
        Observable.combineLatest(
            pwTextField.rx.text.orEmpty.map(checkPasswordValid),
            confirmPwTextField.rx.text.orEmpty.map { confirmPw in
                return confirmPw == self.pwTextField.text
            }
        )
        .map { passwordValid, confirmPasswordValid in
            return passwordValid && confirmPasswordValid
        }
        .subscribe(onNext: { isValid in
            self.changePwButton.isEnabled = isValid
        })
        .disposed(by: disposeBag)
    }
    
    // 비밀번호 유효성 검사
    private func checkPasswordValid(_ password: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pwRegex)
        return predicate.evaluate(with: password)
    }
}
