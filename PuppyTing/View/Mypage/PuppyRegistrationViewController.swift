import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PuppyRegistrationViewController: UIViewController {
    
    var completionHandler: ((String, String) -> Void)?
    private let disposeBag = DisposeBag()
    
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
        button.setTitleColor(.white , for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        return button
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "강아지 이름"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let infoTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "강아지 나이"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let tagTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "특징을 추가하세요! (ex. 친근한, 활발한, 소심한)"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
//    private lazy var tagsCollectionView: UICollectionView = {
//            let layout = UICollectionViewFlowLayout()
//            layout.scrollDirection = .vertical
//            layout.minimumLineSpacing = 5
//            layout.minimumInteritemSpacing = 5
//            
//            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//            collectionView.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
//            collectionView.backgroundColor = .white
//            collectionView.delegate = self
//            collectionView.dataSource = self
//            return collectionView
//        }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("등록", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .puppyPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupBindings()  // RxSwift 바인딩 설정
    }
    
    private func setupUI() {
        let views = [puppyImageView, puppyImageChangeButton, nameTextField, infoTextField, submitButton, tagTextField, /*tagsCollectionView*/]
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
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(puppyImageChangeButton.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        infoTextField.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(20)
            $0.left.right.height.equalTo(nameTextField)
        }
        
        tagTextField.snp.makeConstraints {
            $0.top.equalTo(infoTextField.snp.bottom).offset(20)
            $0.left.right.height.equalTo(infoTextField)
        }
        
//        tagsCollectionView.snp.makeConstraints {
//            $0.top.equalTo(tagTextField.snp.bottom).offset(10)
//            $0.left.equalToSuperview().offset(20)
//            $0.right.equalToSuperview().offset(-20)
//            $0.height.equalTo(100)
//        }
        
        submitButton.snp.makeConstraints {
            $0.top.equalTo(tagTextField.snp.bottom).offset(40)
            $0.left.right.equalTo(infoTextField)
            $0.height.equalTo(50)
        }
    }
    
    private func setupBindings() {
        submitButton.rx.tap
            .bind { [weak self] in
                self?.handleSubmitButtonTapped()
            }
            .disposed(by: disposeBag)
    }
    
    private func handleSubmitButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let info = infoTextField.text, !info.isEmpty else {
            // 입력이 없는 경우 경고 메시지를 표시
            let alert = UIAlertController(title: "오류", message: "모든 필드를 채워주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 완료 핸들러를 통해 입력된 데이터를 전달
        completionHandler?(name, info)
        
        // 네비게이션 스택에서 이전 화면으로 돌아갑니다.
        navigationController?.popViewController(animated: true)
    }
}
