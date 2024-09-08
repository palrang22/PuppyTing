import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class MyInfoEditViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private var member: Member? = nil {
        didSet {
            // 데이터 전송 시 화면 구성 변환
            if let member = member {
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
    
    func setMember(member: Member?) {
        self.member = member
    }
    
    private let myInfoEditViewModel = MyInfoEditVIewModel()
    
    //MARK: - Properties
    
    private let userProfileImageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 75
        button.contentMode = .scaleAspectFill
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.puppyPurple.cgColor
        button.layer.borderWidth = 1
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
    
    
    //MARK: - Setup UI
    
    private func setupUI() {

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
        views.forEach { view.addSubview($0) }

        // 레이아웃 설정
        userProfileImageButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(150)
        }
        
        emailTitleLabel.snp.makeConstraints {
            $0.top.equalTo(userProfileImageButton.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(emailTitleLabel.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
        }
        
        nickNameTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameTitleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        passwordTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTitleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        passwordChangeButton.snp.makeConstraints {
            $0.centerY.equalTo(passwordTitleLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-20)
            $0.width.equalTo(80)
            $0.height.equalTo(44)
        }
        
        passwordCheckTitleLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
        }
        
        passwordCheckTextField.snp.makeConstraints {
            $0.top.equalTo(passwordCheckTitleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
    }
    
    //MARK: - Setup Actions
    
    private func setupActions() {
        userProfileImageButton.addTarget(self, action: #selector(handleProfileImageChange), for: .touchUpInside)
        passwordChangeButton.addTarget(self, action: #selector(updatePassword), for: .touchUpInside)
    }
    
    // MARK: - Handlers

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
        updateImage()
    }

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
    
    private func updateMember(nickname: String, image: String) {
        guard let member = member else { return }
        let updateMember = Member(uuid: member.uuid, email: member.email, password: member.password, nickname: nickname, profileImage: image, footPrint: member.footPrint, isSocial: member.isSocial, blockedUsers: member.blockedUsers, bookMarkUsers: member.bookMarkUsers, puppies: member.puppies)
        myInfoEditViewModel.updateMember(member: updateMember)
    }
    
    @objc 
    private func updatePassword() {
        guard let password = passwordTextField.text, let passwordCheck = passwordCheckTextField.text, let oldPassword = member?.password else { return }
        guard password == passwordCheck else { return }
        myInfoEditViewModel.updatePassword(oldpassword: oldPassword, newPassword: password)
    }
    
    private func updateFireStorePassword() {
        guard let member = member, let password = passwordTextField.text else { return }
        myInfoEditViewModel.updateFireStorePassword(uuid: member.uuid, password: password)
    }
    
    private func fetchImage(imageUrl: String) {
        myInfoEditViewModel.fetchImage(image: imageUrl)
    }
    
    private func bindData() {
        myInfoEditViewModel.updateSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] isUpdate in
            if isUpdate {
                self?.okAlert(title: "정보 수정", message: "완료", okActionTitle: "ok") { _ in
                    self?.navigationController?.popViewController(animated: true)
                }
            } else {
                self?.okAlert(title: "정보 수정", message: "실패")
            }
        }).disposed(by: disposeBag)
        myInfoEditViewModel.passwordSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] isUpdate in
            if isUpdate {
                // 멤버 변경 해야댐
                self?.updateFireStorePassword()
            } else {
                self?.okAlert(title: "비밀번호 변경 실패", message: "몰?루?")
                self?.passwordTextField.text = ""
                self?.passwordCheckTextField.text = ""
            }
        }).disposed(by: disposeBag)
        myInfoEditViewModel.fireStorePasswordSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] isUpdate in
            if isUpdate {
                self?.okAlert(title: "비밀번호 변경 완료", message: "비밀번호를 변경했습니다.", okActionTitle: "ok")
                self?.passwordTextField.text = ""
                self?.passwordCheckTextField.text = ""
                if let member = self?.member {
                    self?.myInfoEditViewModel.findMember(uuid: member.uuid)
                }
            } else {
                self?.okAlert(title: "비밀번호 변경 실패", message: "몰?루?")
                self?.passwordTextField.text = ""
                self?.passwordCheckTextField.text = ""
            }
        }).disposed(by: disposeBag)
        myInfoEditViewModel.memberSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] member in
            self?.member = member
        }).disposed(by: disposeBag)
        myInfoEditViewModel.imageSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] imageUrl in
            guard let nickname = self?.member?.nickname else { return }
            self?.updateMember(nickname: nickname, image: imageUrl)
        }).disposed(by: disposeBag)
        myInfoEditViewModel.realImageSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] image in
            self?.realImage = image
        }).disposed(by: disposeBag)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension MyInfoEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            userProfileImageButton.setImage(selectedImage, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
