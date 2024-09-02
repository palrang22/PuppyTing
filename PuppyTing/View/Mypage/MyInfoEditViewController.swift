import UIKit

import RxSwift
import RxCocoa
import SnapKit

class MyInfoEditViewController: UIViewController {
    
    //MARK: - Properties
    
    private let UserProfileImageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 75
        button.contentMode = .scaleAspectFill
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.puppyPurple.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    
    private let EmailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let EmailLabel: UILabel = {
        let label = UILabel()
        label.text = "OOOO@naver.com"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let NickNameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let NickNameTextField: UITextField = {
        let TextField = UITextField()
        TextField.placeholder = "닉네임이 표시될 위치"
        TextField.isSecureTextEntry = true
        TextField.borderStyle = .none
        TextField.layer.cornerRadius = 5
        TextField.layer.borderColor = UIColor.puppyPurple.cgColor
        TextField.layer.borderWidth = 1.0
        TextField.font = UIFont.systemFont(ofSize: 16)
        TextField.leftView = UIView(frame: CGRect(x: 0, y:0, width: 8, height: 0))
        TextField.leftViewMode = .always
        TextField.isUserInteractionEnabled = false
        return TextField
    }()
    
    private let NickNameChangeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("변경하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.puppyPurple, for: .normal)
        return button
    }()
    
    private let PasswordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let PasswordChangeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("변경하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.puppyPurple, for: .normal)
        return button
    }()
    
    private let PasswordTextField: UITextField = {
        let TextField = UITextField()
        TextField.placeholder = "비밀번호 표시위치"
        TextField.isSecureTextEntry = true
        TextField.borderStyle = .none
        TextField.layer.cornerRadius = 5
        TextField.layer.borderColor = UIColor.puppyPurple.cgColor
        TextField.layer.borderWidth = 1.0
        TextField.font = UIFont.systemFont(ofSize: 16)
        TextField.leftView = UIView(frame: CGRect(x: 0, y:0, width: 8, height: 0))
        TextField.leftViewMode = .always
        TextField.isUserInteractionEnabled = false
        return TextField
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupUI()
        setupActions()
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
            UserProfileImageButton,
            EmailTitleLabel,
            EmailLabel,
            NickNameTitleLabel,
            NickNameTextField,
            NickNameChangeButton,
            PasswordTitleLabel,
            PasswordTextField,
            PasswordChangeButton
        ]
        views.forEach { view.addSubview($0) }

        // 레이아웃 설정
        UserProfileImageButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(150)
        }
        
        EmailTitleLabel.snp.makeConstraints {
            $0.top.equalTo(UserProfileImageButton.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
        }
        
        EmailLabel.snp.makeConstraints {
            $0.top.equalTo(EmailTitleLabel.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
        }
        
        NickNameTitleLabel.snp.makeConstraints {
            $0.top.equalTo(EmailLabel.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
        }
        
        NickNameTextField.snp.makeConstraints {
            $0.top.equalTo(NickNameTitleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        PasswordTitleLabel.snp.makeConstraints {
            $0.top.equalTo(NickNameTextField.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
        }
        
        PasswordTextField.snp.makeConstraints {
            $0.top.equalTo(PasswordTitleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        PasswordChangeButton.snp.makeConstraints {
            $0.centerY.equalTo(PasswordTitleLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-20)
            $0.width.equalTo(80)
            $0.height.equalTo(44)
        }
    }
    
    //MARK: - Setup Actions
    
    private func setupActions() {
        UserProfileImageButton.addTarget(self, action: #selector(handleProfileImageChange), for: .touchUpInside)
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
        navigationController?.popViewController(animated: true)
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
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension MyInfoEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            UserProfileImageButton.setImage(selectedImage, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
