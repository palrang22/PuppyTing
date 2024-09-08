import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class PuppyRegistrationViewController: UIViewController {

    // MARK: - Properties

    var completionHandler: ((String, String, UIImage?) -> Void)?
    var isEditMode: Bool = false
    private let puppyRegistrationViewModel = PuppyRegistrationViewModel()
    
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
        textField.placeholder = "스페이스바 또는 쉼표로 구분하여 태그를 추가해보세요!"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private var tagStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .fill
        stack.layer.cornerRadius = 5
        stack.spacing = 10
        return stack
    }()
    
    private let tagScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = true
        return scroll
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupKeyboardDismissRecognizer()
        setupUI()
        configureNavigationBar()
        setupBindings()
        bindData()
    }

    // MARK: - Setup UI

    private func setupUI() {
        // UI 요소들을 배열로 묶어 한 번에 addSubview
        let views = [puppyImageView, puppyImageChangeButton, nameLabel, nameTextField, ageLabel, ageTextField, tagLabel, tagTextField, tagScrollView]
        views.forEach { view.addSubview($0) }
        
        tagScrollView.addSubview(tagStack)

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
        
        tagScrollView.snp.makeConstraints {
            $0.top.equalTo(tagTextField.snp.bottom).offset(20)
            $0.leading.equalTo(tagTextField)
            $0.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        tagStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
    }
    
    private func findUserId() -> String {
        guard let user = Auth.auth().currentUser else { return "" }
        return user.uid
    }
    
    private func updateImage(image: UIImage) {
        puppyRegistrationViewModel.updateImage(image: image)
    }
    
    private func addPuppy() {
        guard let name = nameTextField.text,
              let strAge = ageTextField.text,
              let age = Int(strAge)
              else { return }
        let userId = findUserId()
        let image = puppyImage
        // 이미지, 이름, 나이 저장
        var tagArr: [String] = []
        
        for view in tagStack.arrangedSubviews {
            if let button = view as? UIButton {
                if let tag = button.titleLabel?.text {
                    tagArr.append(tag)
                }
            }
        }
        
        guard !tagArr.isEmpty else { return }
        
        print("이름 : \(name)\n나이 : \(age)\n태그 : \(tagArr)")
        puppyRegistrationViewModel.createPet(userId: userId, name: name, age: age, petImage: image, tag: tagArr)
    }
    
    private func uploadImage() {
        guard let image = puppyImageView.image else { return }
        updateImage(image: image)
    }
    
    
    
    var puppyImage: String = "" {
        didSet {
            addPuppy()
        }
    }
    
    var pet: Pet? = nil {
        didSet {
            // 데이터 생성
            // 등록 후 이전 화면으로 돌아가기
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func bindData() {
        puppyRegistrationViewModel.imageSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] image in
            self?.puppyImage = image
        }).disposed(by: disposeBag)
        puppyRegistrationViewModel.petSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] pet in
            self?.pet = pet
        }).disposed(by: disposeBag)
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
        
        // tagTextField 입력값 쉼표/스페이스바 감지 메서드 - sh
        tagTextField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                
                if text.last == "," || text.last == " " {
                    let tagWord = text.dropLast()
                    if !tagWord.isEmpty {
                        self.addTag(word: String(tagWord))
                        self.tagTextField.text = ""
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    // UIButton Extension 사용하여 버튼 생성 메서드 - sh
    private func addTag(word: String) {
        let button = UIButton()
        button.makeTag(word: word, target: self, action: #selector(tagTapped))
        
        let currentWidth = button.intrinsicContentSize.width
        
        tagStack.addArrangedSubview(button)
        
        button.snp.makeConstraints {
            $0.width.equalTo(currentWidth + CGFloat(20))
        }
        tagStack.layoutIfNeeded()
    }
    
    // 태그 클릭시 삭제되는 메서드 - sh
    @objc
    private func tagTapped(sender: UIButton) {
        print("tapped")
        tagStack.removeArrangedSubview(sender)
        sender.removeFromSuperview()
        tagStack.layoutIfNeeded()
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
        //completionHandler?(name, info, puppyImageView.image)
        uploadImage()
        
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
