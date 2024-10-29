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
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()

    // 버튼 이미지로 변경 - jgh
    let cancleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "closeButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    // 회원가입 타이틀 - jgh
    let signTitle: UILabel = {
        let label = UILabel()
        label.text = "회원가입"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
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
        textField.placeholder = "example@mail.com"
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
        textField.placeholder = "examplepw1@"
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
        textField.placeholder = "examplepw1@"
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
        
        // 키보드 높이 조절 메서드 호출
        setupKeyboardObservers()
    }
    
    private func configureUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        [cancleButton, signTitle, emailLabel, emailCheck, emailTextField, pwLabel, pwCheck, pwTextField, guideLine, eTrueLable, eFalseLable, pTrueLable, pFalseLable, confirmLabel, confirmCheck, confirmPwTextField, cTrueLable, cFalseLable, nickLabel, nickCheck, nickTextField, nTrueLable, nFalseLable, signUpButton].forEach {
            contentView.addSubview($0)
        }
        
        cancleButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.height.width.equalTo(44)
        }
        
        signTitle.snp.makeConstraints {
            $0.top.equalTo(cancleButton.snp.bottom).offset(10)
            $0.leading.equalTo(emailLabel.snp.leading)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(signTitle.snp.bottom).offset(40)
            $0.leading.equalTo(emailTextField.snp.leading)
        }
        
        emailCheck.snp.makeConstraints {
            $0.centerY.equalTo(emailLabel.snp.centerY)
            $0.leading.equalTo(emailLabel.snp.trailing).offset(5)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        pwLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(20)
            $0.leading.equalTo(emailTextField.snp.leading)
        }
        
        pwCheck.snp.makeConstraints {
            $0.centerY.equalTo(pwLabel.snp.centerY)
            $0.leading.equalTo(pwLabel.snp.trailing).offset(5)
        }
        
        pwTextField.snp.makeConstraints {
            $0.top.equalTo(pwLabel.snp.bottom).offset(5)
            $0.leading.equalTo(emailTextField.snp.leading)
            $0.trailing.equalTo(emailTextField.snp.trailing)
            $0.height.equalTo(40)
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
            $0.top.equalTo(guideLine.snp.bottom).offset(20)
            $0.leading.equalTo(pwTextField.snp.leading)
        }
        
        confirmCheck.snp.makeConstraints {
            $0.centerY.equalTo(confirmLabel.snp.centerY)
            $0.leading.equalTo(confirmLabel.snp.trailing).offset(5)
        }
        
        confirmPwTextField.snp.makeConstraints {
            $0.top.equalTo(confirmLabel.snp.bottom).offset(5)
            $0.leading.equalTo(emailTextField.snp.leading)
            $0.trailing.equalTo(emailTextField.snp.trailing)
            $0.height.equalTo(40)
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
            $0.top.equalTo(confirmPwTextField.snp.bottom).offset(20)
            $0.leading.equalTo(pwTextField.snp.leading)
        }
        
        nickCheck.snp.makeConstraints {
            $0.centerY.equalTo(nickLabel.snp.centerY)
            $0.leading.equalTo(nickLabel.snp.trailing).offset(5)
        }
        
        nickTextField.snp.makeConstraints {
            $0.top.equalTo(nickLabel.snp.bottom).offset(5)
            $0.leading.equalTo(emailTextField.snp.leading)
            $0.trailing.equalTo(emailTextField.snp.trailing)
            $0.height.equalTo(40)
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
            $0.top.equalTo(nickTextField.snp.bottom).offset(70)
            $0.bottom.equalToSuperview().offset(-30)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(44)
        }
    }
    
    private func bindUI() { // -kkh 수정부분 : 버튼이 활성화 되게하고 빈칸이 있을 시 Alert창이 뜨도록 변경
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
        // 유효성 검사 추가 및 Alert 표시
        guard let email = emailTextField.text, let pw = pwTextField.text, let confirmPw = confirmPwTextField.text, let nickname = nickTextField.text else {
            return
        }
        
        if email.isEmpty || pw.isEmpty || confirmPw.isEmpty || nickname.isEmpty {
            okAlert(title: "입력 오류", message: "모든 필드를 채워주세요.")
            return
        }
        
        if !checkEmailValid(email) {
            okAlert(title: "입력 오류", message: "이메일 형식이 잘못되었습니다.")
            return
        }
        
        if !checkPasswordValid(pw) {
            okAlert(title: "입력 오류", message: "비밀번호 형식이 잘못되었습니다.")
            return
        }
        
        if confirmPw != pw {
            okAlert(title: "입력 오류", message: "비밀번호가 일치하지 않습니다.")
            return
        }
        
        if !checNickNameValid(nickname) {
            okAlert(title: "입력 오류", message: "닉네임은 2~10자 사이여야 합니다.")
            return
        }

        // 모든 조건을 통과하면 ViewModel 호출
        signUpViewModel.authentication(email: email, pw: pw)
    }
    
    private func signUp(user: User) {
        guard let email = user.email, let pw = pwTextField.text, let nickname = nickTextField.text else { return }
        signUpViewModel.signUp(uuid: user.uid, email: email, pw: pw, nickname: nickname)
    }
    
    private func endSignUp() {
        okAlert(title: SignUpMessage().signUpSuccess, message: SignUpMessage().signUpSuccessMessage) { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
    
    private func error(error: Error) {
        if let error = error as? AuthError {
            switch error {
            case .CreateFailError:
                okAlert(title: SignUpFailMessage().signUpFail, message: SignUpFailMessage().createFailMessage)
            case .SendEmailFailError:
                okAlert(title: SignUpFailMessage().signUpFail, message: SignUpFailMessage().sendEmailFailMessage)
            default:
                okAlert(title: SignUpFailMessage().signUpFail, message: SignUpFailMessage().otherFailMessage)
            }
        } else {
            okAlert(title: SignUpFailMessage().signUpFail, message: SignUpFailMessage().otherFailMessage)
        }
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
