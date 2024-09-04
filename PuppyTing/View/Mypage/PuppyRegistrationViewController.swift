import UIKit

import RxCocoa
import RxSwift
import SnapKit

class PuppyRegistrationViewController: UIViewController {

    // MARK: - Properties

    var completionHandler: ((String, String, UIImage?) -> Void)?
    var isEditMode: Bool = false
    
    private let disposeBag = DisposeBag()
    
    // UI Elements
    private let puppyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75
        imageView.layer.borderColor = UIColor.puppyPurple.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    private let puppyImageChangeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("프로필 변경", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .puppyPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "강아지 이름"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "나이"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let ageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "강아지 나이"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.text = "특징"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let tagTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "특징을 추가하세요! (ex. 친근한, 활발한, 소심한)"
        textField.borderStyle = .roundedRect
        return textField
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        configureNavigationBar()
        setupBindings()
    }

    // MARK: - Setup UI

    private func setupUI() {
        // UI 요소들을 배열로 묶어 한 번에 addSubview
        let views = [puppyImageView, puppyImageChangeButton, nameLabel, nameTextField, ageLabel, ageTextField, tagLabel, tagTextField]
        views.forEach { view.addSubview($0) }

        puppyImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(150)
        }

        puppyImageChangeButton.snp.makeConstraints {
            $0.top.equalTo(puppyImageView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(44)
            $0.width.equalTo(150)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(puppyImageChangeButton.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }

        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        ageLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }

        ageTextField.snp.makeConstraints {
            $0.top.equalTo(ageLabel.snp.bottom).offset(5)
            $0.left.right.height.equalTo(nameTextField)
        }
        
        tagLabel.snp.makeConstraints {
            $0.top.equalTo(ageTextField.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }

        tagTextField.snp.makeConstraints {
            $0.top.equalTo(tagLabel.snp.bottom).offset(5)
            $0.left.right.height.equalTo(ageTextField)
        }
    }

    // MARK: - Configure Navigation Bar

    private func configureNavigationBar() {
        // 네비게이션 바의 오른쪽 버튼을 등록 또는 수정으로 설정
        let rightBarButtonTitle = isEditMode ? "수정" : "등록"
        let rightBarButton = UIBarButtonItem(title: rightBarButtonTitle, style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButton
    }

    // MARK: - Setup Bindings

    private func setupBindings() {
        guard let rightBarButtonItem = navigationItem.rightBarButtonItem else {
            print("rightBarButtonItem is nil")
            return
        }

        // 프로필 이미지 변경 버튼을 눌렀을 때, 이미지 선택 옵션을 표시
        puppyImageChangeButton.rx.tap
            .bind { [weak self] in
                self?.presentImagePickerOptions()
            }
            .disposed(by: disposeBag)

        // 버튼 클릭 이벤트를 Rx로 바인딩
        rightBarButtonItem.rx.tap
            .bind { [weak self] in
                if self?.isEditMode == true {
                    self?.handleEditButtonTapped()
                } else {
                    self?.handleSubmitButtonTapped()
                }
            }
            .disposed(by: disposeBag)

        // 텍스트 필드 입력값을 감지하여 버튼 활성화 상태를 업데이트
        Observable.combineLatest(nameTextField.rx.text.orEmpty, ageTextField.rx.text.orEmpty)
            .map { !$0.isEmpty && !$1.isEmpty }
            .bind(to: rightBarButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    // MARK: - Handlers

    private func handleEditButtonTapped() {
        // 필드의 입력값이 유효한지 확인
        guard let name = nameTextField.text, !name.isEmpty,
              let info = ageTextField.text, !info.isEmpty else {
            // 필드가 비어있을 때 경고 표시
            presentAlert(title: "오류", message: "모든 필드를 채워주세요.")
            return
        }

        // 수정된 데이터를 completionHandler를 통해 전달 (이미지 포함)
        completionHandler?(name, info, puppyImageView.image)
        
        // 수정 후 이전 화면으로 돌아가기
        navigationController?.popViewController(animated: true)
    }

    private func handleSubmitButtonTapped() {
        // 필드의 입력값이 유효한지 확인
        guard let name = nameTextField.text, !name.isEmpty,
              let info = ageTextField.text, !info.isEmpty else {
            // 필드가 비어있을 때 경고 표시
            presentAlert(title: "오류", message: "모든 필드를 채워주세요.")
            return
        }

        // 새로운 데이터를 completionHandler를 통해 전달 (이미지 포함)
        completionHandler?(name, info, puppyImageView.image)
        
        // 등록 후 이전 화면으로 돌아가기
        navigationController?.popViewController(animated: true)
    }

    private func presentAlert(title: String, message: String) {
        // Rx로 UIAlertController의 버튼 클릭을 처리
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Setup Data

    func setupWithPuppy(name: String, info: String, tag: String) {
        // 전달된 데이터를 UI에 반영
        nameTextField.text = name
        ageTextField.text = info
        tagTextField.text = tag
    }
    
    // MARK: - Image Picker

    private func presentImagePickerOptions() {
        // 사진 선택 옵션을 표시하는 액션 시트
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

    private func presentPhotoLibrary() {
        // 앨범에서 사진을 선택할 수 있는 UIImagePickerController 실행
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    private func presentCamera() {
        // 카메라를 통해 사진을 찍을 수 있는 UIImagePickerController 실행
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension PuppyRegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 선택된 이미지를 puppyImageView에 설정
        if let selectedImage = info[.originalImage] as? UIImage {
            puppyImageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 사진 선택이 취소된 경우, picker를 닫음
        picker.dismiss(animated: true, completion: nil)
    }
}
