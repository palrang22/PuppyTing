import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class MyInfoEditViewController: UIViewController {
    
    var updateSubject = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    
    private var member: Member? = nil {
        didSet {
            // 데이터 전송 시 화면 구성 변환
            if let member = member {
                if member.isSocial {
                    passwordTextField.isHidden = true
                    passwordTitleLabel.isHidden = true
                    passwordChangeButton.isHidden = true
                    passwordCheckTextField.isHidden = true
                    passwordCheckTitleLabel.isHidden = true
                }
                emailLabel.text = member.email
                nickNameTextField.text = member.nickname
                if member.profileImage == "defaultProfileImage" {
                    userProfileImageButton.setImage(UIImage(named: "defaultProfileImage"), for: .normal)
                } else {
                    fetchImage(imageUrl: member.profileImage)
                }
            }
        }
    }
    
    private var realImage: UIImage? = nil {
        didSet {
            //이미지 변경
            if let image = realImage {
                userProfileImageButton.setImage(image, for: .normal)
            }
        }
    }
    
    let pwRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}"
    
    func setMember(member: Member?) {
        self.member = member
    }
    
    private let myInfoEditViewModel = MyInfoEditVIewModel()
    
    //MARK: - Properties
    
    // 스크롤뷰 추가 - jgh
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let userProfileImageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 75
        button.contentMode = .scaleAspectFill
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.puppyPurple.cgColor
        button.layer.borderWidth = 1
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    
    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "OOOO@naver.com"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let nickNameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "닉네임이 표시될 위치"
        //TextField.isSecureTextEntry = true
        textField.borderStyle = .none
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.puppyPurple.cgColor
        textField.layer.borderWidth = 1.0
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y:0, width: 8, height: 0))
        textField.leftViewMode = .always
        //TextField.isUserInteractionEnabled = false
        return textField
    }()
    
    private let nickNameChangeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("변경하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.puppyPurple, for: .normal)
        return button
    }()
    
    private let passwordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let passwordChangeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("변경하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.puppyPurple, for: .normal)
        return button
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호 표시위치"
        textField.isSecureTextEntry = true
        textField.borderStyle = .none
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.puppyPurple.cgColor
        textField.layer.borderWidth = 1.0
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y:0, width: 8, height: 0))
        textField.leftViewMode = .always
        //TextField.isUserInteractionEnabled = false
        return textField
    }()
    
    private let passwordCheckTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 재입력"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let passwordCheckTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호 표시위치"
        textField.isSecureTextEntry = true
        textField.borderStyle = .none
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.puppyPurple.cgColor
        textField.layer.borderWidth = 1.0
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y:0, width: 8, height: 0))
        textField.leftViewMode = .always
        //TextField.isUserInteractionEnabled = false
        return textField
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupKeyboardDismissRecognizer()
        setupNavigationBar()
        setupUI()
        setupActions()
        bindData()
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "정보 수정"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        navigationItem.titleView = titleLabel
        
        // 오른쪽에 "수정" 버튼 추가
        let editButton = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(handleEditButtonTapped))
        navigationItem.rightBarButtonItem = editButton
    }
    
    //MARK: - Setup Actions
    
    private func setupActions() {
        userProfileImageButton.addTarget(self, action: #selector(handleProfileImageChange), for: .touchUpInside)
        passwordChangeButton.addTarget(self, action: #selector(updatePassword), for: .touchUpInside)
    }
    
    //MARK: 멤버 정보 수정 관련 메서드

    private func updateMemberProfile(nickname: String, imageUrl: String) {
        if let member = member {
            let updatedMember = Member(
                uuid: member.uuid,
                email: member.email,
                password: member.password,
                nickname: nickname,
                profileImage: imageUrl,
                footPrint: member.footPrint,
                isSocial: member.isSocial,
                blockedUsers: member.blockedUsers,
                bookMarkUsers: member.bookMarkUsers,
                puppies: member.puppies
            )
            myInfoEditViewModel.updateMember(member: updatedMember)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateMember(nickname: String, image: String) {
        guard let member = member else { return }
        let updateMember = Member(uuid: member.uuid,
                                  email: member.email,
                                  password: member.password,
                                  nickname: nickname, profileImage: image,
                                  footPrint: member.footPrint,
                                  isSocial: member.isSocial,
                                  blockedUsers: member.blockedUsers,
                                  bookMarkUsers: member.bookMarkUsers,
                                  puppies: member.puppies
        )
        myInfoEditViewModel.updateMember(member: updateMember)
    }
    
    private func fetchImage(imageUrl: String) {
        guard let url = URL(string: imageUrl) else {
            userProfileImageButton.setImage(UIImage(named: "defaultProfileImage"), for: .normal)
            return
        }
        userProfileImageButton.kf.setImage(with: url, for: .normal, placeholder: UIImage(named: "defaultProfileImage"), options: [
            .cacheOriginalImage
        ], completionHandler: { result in
            switch result {
            case .success(let value):
                print("Image successfully loaded: \(value.image)")
            case .failure(let error):
                print("Image loading failed: \(error.localizedDescription)")
                self.userProfileImageButton.setImage(UIImage(named: "defaultProfileImage"), for: .normal)
            }
        })
    }
    
    //MARK: 사진 업로드 관련 메서드

    private func presentPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    private func updateImage() {
        let image = userProfileImageButton.imageView?.image
        if let image = image {
            myInfoEditViewModel.updateImage(image: image)
        }
    }
    
    // MARK: 비밀번호 관련 메서드
    private func checkPasswordValid(_ password: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pwRegex)
        return predicate.evaluate(with: password)
    }
    
    private func updateFireStorePassword() {
        guard let member = member, let password = passwordTextField.text else { return }
        myInfoEditViewModel.updateFireStorePassword(uuid: member.uuid, password: password)
    }
    
    //MARK: bind
    
    private func bindData() {
        myInfoEditViewModel.updateSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isUpdate in
                self?.hideLoadingIndicator()
                if isUpdate {
                    self?.okAlert(title: "정보 수정", message: "정보 수정이 완료되었습니다.") { _ in
                        self?.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self?.okAlert(title: "정보 수정", message: "정보 수정에 실패했습니다. 관리자에게 문의하세요.")
                }
            }).disposed(by: disposeBag)
        
        myInfoEditViewModel.passwordSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isUpdate in
                if isUpdate {
                    self?.updateFireStorePassword()
                } else {
                    self?.okAlert(title: "비밀번호 변경 실패", message: "비밀번호 변경에 실패했습니다. 관리자에게 문의하세요.")
                    self?.passwordTextField.text = ""
                    self?.passwordCheckTextField.text = ""
                }
            }).disposed(by: disposeBag)
        
        myInfoEditViewModel.fireStorePasswordSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isUpdate in
                if isUpdate {
                    self?.okAlert(title: "비밀번호 변경 완료", message: "비밀번호를 성공적으로 변경했습니다.")
                    self?.passwordTextField.text = ""
                    self?.passwordCheckTextField.text = ""
                    if let member = self?.member {
                        self?.myInfoEditViewModel.findMember(uuid: member.uuid)
                    }
                } else {
                    self?.okAlert(title: "비밀번호 변경 실패", message: "비밀번호 변경에 실패했습니다. 관리자에게 문의하세요.")
                    self?.passwordTextField.text = ""
                    self?.passwordCheckTextField.text = ""
                }
            }).disposed(by: disposeBag)
        
        myInfoEditViewModel.memberSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] member in
                self?.member = member
            }).disposed(by: disposeBag)
        
        myInfoEditViewModel.imageSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] imageUrl in
                guard let nickname = self?.nickNameTextField.text else { return }
                self?.updateMember(nickname: nickname, image: imageUrl)
            }).disposed(by: disposeBag)
        
        myInfoEditViewModel.realImageSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                self?.realImage = image
            }).disposed(by: disposeBag)
    }
    
    //MARK: 버튼 클릭 메서드 모음
    @objc private func handleProfileImageChange() {
        let actionSheet = UIAlertController(title: "프로필 이미지 변경", message: "사진을 선택하거나 찍어주세요.", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "앨범에서 선택", style: .default, handler: { [weak self] _ in
            self?.presentPhotoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "사진 찍기", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc private func handleEditButtonTapped() {
        showLoadingIndicatorWithoutBackground()
        let updatedNickname = nickNameTextField.text ?? ""
        
        if let image = realImage {
            print("이미지 업로드 시작")
            myInfoEditViewModel.updateImage(image: image)  // 이미지 업로드 호출
        } else {
            print("realImage가 nil임")
            updateMemberProfile(nickname: updatedNickname, imageUrl: "defaultProfileImage")
        }
        updateSubject.onNext(true)
    }
    
    @objc
    private func updatePassword() {
        guard let password = passwordTextField.text, let passwordCheck = passwordCheckTextField.text, let oldPassword = member?.password else { return }
        guard password == passwordCheck else {
            okAlert(title: "비밀번호 변경", message: "비밀번호가 일치하지 않습니다.", okActionTitle: "ok")
            return
        }
        guard checkPasswordValid(password) else {
            okAlert(title: "비밀번호 변경", message: "비밀번호는 8자리 ~ 50자리 영어+숫자+특수문자 로 설정해주세요", okActionTitle: "ok")
            return
        }
        myInfoEditViewModel.updatePassword(oldpassword: oldPassword, newPassword: password)
    }
    
    
    //MARK: 레이아웃
    
    private func setupUI() {
        
        // 스크롤뷰 컨텐트뷰 추가
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
        }
        
        let views = [
            userProfileImageButton,
            emailTitleLabel,
            emailLabel,
            nickNameTitleLabel,
            nickNameTextField,
            nickNameChangeButton,
            passwordTitleLabel,
            passwordTextField,
            passwordChangeButton,
            passwordCheckTitleLabel,
            passwordCheckTextField
        ]
        views.forEach { contentView.addSubview($0) }
        
        // 레이아웃 설정
        userProfileImageButton.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(20)
            $0.centerX.equalTo(contentView)
            $0.width.height.equalTo(150)
        }
        
        emailTitleLabel.snp.makeConstraints {
            $0.top.equalTo(userProfileImageButton.snp.bottom).offset(30)
            $0.left.equalTo(contentView).offset(20)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(emailTitleLabel.snp.bottom).offset(30)
            $0.left.equalTo(contentView).offset(20)
        }
        
        nickNameTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(30)
            $0.left.equalTo(contentView).offset(20)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameTitleLabel.snp.bottom).offset(20)
            $0.left.equalTo(contentView).offset(20)
            $0.right.equalTo(contentView).offset(-20)
            $0.height.equalTo(40)
        }
        
        passwordTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(30)
            $0.left.equalTo(contentView).offset(20)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTitleLabel.snp.bottom).offset(20)
            $0.left.equalTo(contentView).offset(20)
            $0.right.equalTo(contentView).offset(-20)
            $0.height.equalTo(40)
        }
        
        passwordChangeButton.snp.makeConstraints {
            $0.centerY.equalTo(passwordTitleLabel.snp.centerY)
            $0.right.equalTo(contentView).offset(-20)
            $0.width.equalTo(80)
            $0.height.equalTo(44)
        }
        
        passwordCheckTitleLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(30)
            $0.left.equalTo(contentView).offset(20)
        }
        
        passwordCheckTextField.snp.makeConstraints {
            $0.top.equalTo(passwordCheckTitleLabel.snp.bottom).offset(20)
            $0.left.equalTo(contentView).offset(20)
            $0.right.equalTo(contentView).offset(-20)
            $0.height.equalTo(40)
            $0.bottom.equalTo(contentView).offset(-20)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension MyInfoEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            userProfileImageButton.setImage(selectedImage, for: .normal)
            realImage = selectedImage
        } else {
            print("이미지 선택 실패")
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
