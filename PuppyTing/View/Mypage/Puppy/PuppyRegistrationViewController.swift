import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class PuppyRegistrationViewController: UIViewController {

    // MARK: - Properties
    
    var pet: Pet?
    var isEditMode: Bool = false

    var puppyRegisteredSubject = PublishSubject<(String, String, String?)>()
    var puppyUpdatedSubject = PublishSubject<(String, String, String?)>()
    private let puppyRegistrationViewModel = PuppyRegistrationViewModel()
    private let disposeBag = DisposeBag()
    
    func setPet(pet: Pet) {
        self.pet = pet
    }
    
    // UI Elements
    private let scrollView = UIScrollView() // kkh
    private let contentView = UIView() // kkh
    
    // 이미지뷰삭제, 프로필 변경 버튼 ui 없애고 버튼 자체에 이미지 나오게 - jgh
    private let puppyImageChangeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 75
        button.contentMode = .scaleAspectFill
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.puppyPurple.cgColor
        button.layer.borderWidth = 1
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
        textField.placeholder = "강아지 나이를 정수로 입력해주세요."
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.text = "태그"
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
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    // 이별하기 삭제하기로 변경 - jgh
    private let separationButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(string: "프로필 삭제하기", attributes: [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.lightGray,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = .clear // 배경색 투명
        button.layer.cornerRadius = 0 // 모서리 둥글기 제거
        button.isHidden = true
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupKeyboardObservers()
        setupKeyboardDismissRecognizer()
        setupUI()
        configureNavigationBar()
        setupBindings()
        bind()
    }
    
    //extension으로 뺐습니다 - ksh
    deinit {
        removeKeyboardObservers()
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        // views 배열에 있는 모든 요소를 contentView에 추가
        let views = [/*puppyImageView, */puppyImageChangeButton, nameLabel, nameTextField, ageLabel, ageTextField, tagLabel, tagTextField, tagScrollView, separationButton]
        views.forEach { contentView.addSubview($0) }
        
        tagScrollView.addSubview(tagStack)
        
        puppyImageChangeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(150)
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
        
        tagStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        tagScrollView.snp.makeConstraints {
            $0.top.equalTo(tagLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(50)
        }
        
        tagTextField.snp.makeConstraints {
            $0.top.equalTo(tagScrollView.snp.bottom).offset(5)
            $0.left.right.height.equalTo(ageTextField)
        }

        separationButton.snp.makeConstraints {
            $0.top.equalTo(tagTextField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20) // 마지막 요소를 기준으로 contentView의 높이 설정
            $0.height.equalTo(44)
        }
        
//         수정 모드에서만 이별하기 버튼 보이도록 설정
        separationButton.isHidden = !isEditMode
    }

    
    private func findUserId() -> String {
        guard let user = Auth.auth().currentUser else { return "" }
        return user.uid
    }
    
    private func updateImage(image: UIImage) {
        puppyRegistrationViewModel.updateImage(image: image)
    }
    
    private func bind() {
        guard let pet = pet else { return }
        nameTextField.text = pet.name
        ageTextField.text = "\(pet.age)"
        pet.tag.forEach { addTag(word: $0) }
        // Kingfisher로 이미지 로딩 후, 버튼에 이미지 설정 - jgh
        let url = URL(string: pet.petImage)
        puppyImageChangeButton.kf.setImage(with: url, for: .normal, placeholder: UIImage(named: "defaultImage"))
    }

    // MARK: - Configure Navigation Bar

    private func configureNavigationBar() {
        // 네비게이션 바의 오른쪽 버튼을 등록 또는 수정으로 설정
        let rightBarButtonTitle = isEditMode ? "수정 완료" : "등록"
        let rightBarButton = UIBarButtonItem(title: rightBarButtonTitle, style: .plain, target: self, action: isEditMode ? #selector(handleEditButtonTapped) : #selector(handleSubmitButtonTapped))
        
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
        
        // 강아지와 이별하기 버튼 클릭 시 Alert 표시
        separationButton.rx.tap
            .bind { [weak self] in
                self?.showSeparationAlert()
            }
            .disposed(by: disposeBag)
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

    @objc private func handleSubmitButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let strAge = ageTextField.text, let age = Int(strAge),
              !name.isEmpty, !strAge.isEmpty else {
            okAlert(title: "오류", message: "모든 필드를 채워주세요.")
            return
        }
        
        let userId = findUserId()
        var tagArr: [String] = []
        for view in tagStack.arrangedSubviews {
            if let button = view as? UIButton, let tag = button.titleLabel?.text {
                tagArr.append(tag)
            }
        }
        
        guard let image = puppyImageChangeButton.imageView?.image else {
            okAlert(title: "오류", message: "이미지를 선택해주세요.")
            return
        }
        
        FirebaseStorageManager.shared.uploadImage(image: image)
            .flatMap { imageUrl in
                return self.puppyRegistrationViewModel.createPuppy(userId: userId, name: name, age: age, petImage: imageUrl, tag: tagArr)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { pet in
                self.puppyRegisteredSubject.onNext((name, "\(age)", pet.petImage)) // 이벤트 방출
                self.navigationController?.popViewController(animated: true)
            }, onFailure: { error in
                print("강아지 등록 실패: \(error)")
            })
            .disposed(by: disposeBag)
        
    }

    @objc private func handleEditButtonTapped() {
        print("petId: \(pet?.id ?? "nil")")
        print("name: \(nameTextField.text ?? "nil")")
        print("age: \(ageTextField.text ?? "nil")")
        
        guard let petId = pet?.id,
              let name = nameTextField.text, !name.isEmpty,  // 이름 필드 검사
              let strAge = ageTextField.text, !strAge.isEmpty, // 나이 필드 검사
              let age = Int(strAge) else {  // 나이 필드를 Int로 변환
            okAlert(title: "오류", message: "1. 모든 필드를 채워주세요.")
            return
        }

        let userId = findUserId()
        var tagArr: [String] = []
        for view in tagStack.arrangedSubviews {
            if let button = view as? UIButton, let tag = button.titleLabel?.text {
                tagArr.append(tag)
            }
        }

        guard let image = puppyImageChangeButton.imageView?.image else {
            okAlert(title: "오류", message: "이미지를 선택해주세요.")
            return
        }

        FirebaseStorageManager.shared.uploadImage(image: image)
            .flatMap { imageUrl in
                self.puppyRegistrationViewModel.updatePuppy(petId: petId, userId: userId, name: name, age: age, petImage: imageUrl, tag: tagArr)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { pet in
                self.navigationController?.popViewController(animated: true)
            }, onFailure: { error in
                print("강아지 수정 실패: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    // 이별 알림창
    private func showSeparationAlert() { // kkh
        let alert = UIAlertController(title: "정말 이별하시겠습니까?", message: "떠나보내시면 되돌릴 수 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "이별하기", style: .destructive, handler: { [weak self] _ in
                self?.deletePuppy()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func deletePuppy() { // kkh
        guard let petId = pet?.id  else { return }
        let userId = findUserId()
            
        puppyRegistrationViewModel.deletePuppy(petId: petId, userId: userId)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: {
                self.navigationController?.popViewController(animated: true)
            }, onFailure: { error in
                print("강아지 삭제 실패: \(error)")
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Setup Dataf

    func setupWithPuppy(name: String, info: String, tag: String, imageUrl: String?) {
        nameTextField.text = name
        ageTextField.text = info
        tagTextField.text = tag
        
        // 이미지 URL이 없는 경우는 리턴 - jgh
        guard let imageUrl = imageUrl, let url = URL(string: imageUrl) else {
            puppyImageChangeButton.setImage(UIImage(named: "defaultProfileImage"), for: .normal) // 기본 이미지 설정
            return
        }
        
        // Kingfisher로 버튼에 이미지 설정 - jgh
        puppyImageChangeButton.kf.setImage(with: url, for: .normal, placeholder: UIImage(named: "defaultProfileImage"))
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
        // 선택된 이미지를 puppyImageChangeButton에 설정 - jgh
        if let selectedImage = info[.originalImage] as? UIImage {
            // 버튼의 이미지를 설정
            puppyImageChangeButton.setImage(selectedImage, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 사진 선택이 취소된 경우, picker를 닫음
        picker.dismiss(animated: true, completion: nil)
    }
}
