import UIKit

import RxSwift
import RxCocoa
import SnapKit

class MypageViewController: UIViewController {

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var puppies: [(name: String, info: String, tag: String, image: UIImage?)] = [] // 이미지 추가
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        return stackView
    }()

    private let profileContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.puppyPurple.withAlphaComponent(0.1).cgColor
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.puppyPurple.withAlphaComponent(0.1)
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let profileImage = UIImageView()
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.backgroundColor = .clear
        profileImage.tintColor = .black
        profileImage.image = UIImage(systemName: "person.crop.circle")
        return profileImage
    }()
    
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.text = "닉네임"
        return label
    }()
    
    private let profileEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("정보 수정", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = UIColor.puppyPurple.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.puppyPurple.withAlphaComponent(1)
        return button
    }()
    
    private let myFootLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.text = "내 발도장 n개!"
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal  // 가로 스크롤로 설정
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.puppyPurple.withAlphaComponent(0.1)
        collectionView.layer.cornerRadius = 15
        collectionView.isPagingEnabled = true // 페이징 가능하도록 설정
        collectionView.isHidden = true // 초기에는 숨김
        return collectionView
    }()
    
    private let pageControl: UIPageControl = { // 페이지 인디케이터
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.isHidden = true // 초기에는 숨김
        return pageControl
    }()
    
    private let addPuppyButton: UIButton = {
        let button = UIButton()
        button.setTitle("퍼피 등록하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .puppyPurple
        return button
    }()
    
    private let menuContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.puppyPurple.withAlphaComponent(0.1).cgColor
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.puppyPurple.withAlphaComponent(0.1)
        return view
    }()
    
    private let customerSupportButton: UIButton = {
        let button = UIButton()
        button.setTitle("고객지원", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .puppyPurple
        return button
    }()
    
    private let faqButton: UIButton = {
        let button = UIButton()
        button.setTitle("FAQ", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .puppyPurple
        return button
    }()
    
    private let noticeButton: UIButton = {
        let button = UIButton()
        button.setTitle("공지사항", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .puppyPurple
        return button
    }()
    
    private let logOutButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .puppyPurple
        return button
    }()
    
    private let memberLeaveButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원탈퇴", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .puppyPurple
        return button
    }()

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview() // ScrollView가 전체 화면을 차지하도록 설정
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview() // 세로 스크롤만 가능하도록 가로 크기를 동일하게 설정
        }

        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }

        [profileContainerView, collectionView, pageControl, addPuppyButton, menuContainerView].forEach {stackView.addArrangedSubview($0)}

        [profileImageView, nickNameLabel, profileEditButton, myFootLabel].forEach {profileContainerView.addSubview($0)}

        profileContainerView.snp.makeConstraints {
            $0.height.equalTo(150)
        }

        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(10)
            $0.width.height.equalTo(60)
        }

        nickNameLabel.snp.makeConstraints {
            $0.left.equalTo(profileImageView.snp.right).offset(10)
            $0.centerY.equalTo(profileImageView.snp.centerY)
        }

        profileEditButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.width.equalTo(70)
            $0.height.equalTo(44)
        }

        myFootLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(30)
            $0.height.equalTo(44)
        }

        // 처음에 컬렉션뷰를 숨기기 위해 높이를 0으로 설정
        collectionView.snp.makeConstraints {
            $0.height.equalTo(0)
            $0.left.right.equalToSuperview()
        }

        pageControl.snp.makeConstraints {
            $0.height.equalTo(20)
        }

        addPuppyButton.snp.makeConstraints {
            $0.height.equalTo(44)
        }

        menuContainerView.snp.makeConstraints {
            $0.height.equalTo(250)
        }

        [customerSupportButton, faqButton, noticeButton, logOutButton, memberLeaveButton].forEach {contentView.addSubview($0)}
        
        customerSupportButton.snp.makeConstraints {
            $0.top.equalTo(menuContainerView.snp.bottom).offset(30)
            $0.left.equalTo(30)
            $0.width.equalTo(100)
            $0.height.equalTo(44)
        }
        
        faqButton.snp.makeConstraints {
            $0.top.equalTo(customerSupportButton)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(customerSupportButton)
        }
        
        noticeButton.snp.makeConstraints {
            $0.top.equalTo(customerSupportButton)
            $0.right.equalTo(-30)
            $0.width.height.equalTo(customerSupportButton)
        }
        
        logOutButton.snp.makeConstraints {
            $0.top.equalTo(customerSupportButton.snp.bottom).offset(30)
            $0.left.equalTo(80)
            $0.width.equalTo(100)
            $0.height.equalTo(44)
        }
        
        memberLeaveButton.snp.makeConstraints {
            $0.top.equalTo(logOutButton)
            $0.right.equalTo(-80)
            $0.width.height.equalTo(logOutButton)
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PuppyCollectionViewCell.self, forCellWithReuseIdentifier: PuppyCollectionViewCell.identifier)

        setupMenuItems() // 메뉴 항목을 설정하는 함수 호출
    }
    
    // MARK: - Setup Menu Items
    private func setupMenuItems() {
        let menuItems = ["내 피드 관리", "받은 산책 후기", "즐겨 찾는 친구", "차단 목록"]
        var previousItem: UIView? = nil
        
        for itemName in menuItems {
            let menuItem = createMenuItem(title: itemName)
            menuContainerView.addSubview(menuItem)
            
            menuItem.snp.makeConstraints {
                $0.left.equalToSuperview().offset(10)
                $0.right.equalToSuperview().offset(-10)
                $0.height.equalTo(50)
                
                if let previous = previousItem {
                    $0.top.equalTo(previous.snp.bottom).offset(10)
                } else {
                    $0.top.equalToSuperview().offset(10)
                }
            }
            
            previousItem = menuItem
        }
    }
    
    private func createMenuItem(title: String) -> UIView {
        let menuItem = UIView()
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        
        let chevron = UIImageView()
        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = .black
        
        menuItem.addSubview(label)
        menuItem.addSubview(chevron)
        
        label.snp.makeConstraints {
            $0.left.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        
        chevron.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }
        
        return menuItem
    }
    
    // MARK: - Setup Bindings
    
    private func setupBindings() {
        // 퍼피 등록하기 버튼을 눌렀을 때
        addPuppyButton.rx.tap
            .bind { [weak self] in
                self?.navigateToPuppyRegistration()
            }
            .disposed(by: disposeBag)
        
        // 정보 수정 버튼을 눌렀을 때
        profileEditButton.rx.tap
            .bind { [weak self] in
                self?.navigateToMyInfoEdit()
            }
            .disposed(by: disposeBag)
        
        // 컬렉션 뷰 셀이 선택되었을 때
        collectionView.rx.itemSelected
            .bind { [weak self] indexPath in
                self?.navigateToPuppyEdit(at: indexPath)
            }
            .disposed(by: disposeBag)
    }

    private func navigateToPuppyRegistration() {
        let puppyRegistrationVC = PuppyRegistrationViewController()
        
        // 정보 입력 후 데이터를 전달받아 컬렉션 뷰를 업데이트합니다.
        puppyRegistrationVC.completionHandler = { [weak self] name, info, image in
            self?.addPuppy(name: name, info: info, image: image)
        }
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(puppyRegistrationVC, animated: true)
        } else {
            present(puppyRegistrationVC, animated: true, completion: nil)
        }
    }

    private func navigateToMyInfoEdit() {
        let myInfoEditVC = MyInfoEditViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(myInfoEditVC, animated: true)
        } else {
            present(myInfoEditVC, animated: true, completion: nil)
        }
    }

    private func navigateToPuppyEdit(at indexPath: IndexPath) {
        let puppy = puppies[indexPath.row]
        let puppyRegistrationVC = PuppyRegistrationViewController()
        puppyRegistrationVC.isEditMode = true
        
        puppyRegistrationVC.setupWithPuppy(name: puppy.name, info: puppy.info, tag: puppy.tag)
        
        puppyRegistrationVC.completionHandler = { [weak self] name, info, image in
            self?.puppies[indexPath.row] = (name: name, info: info, tag: puppy.tag, image: image)
            self?.collectionView.reloadItems(at: [indexPath])
        }
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(puppyRegistrationVC, animated: true)
        } else {
            present(puppyRegistrationVC, animated: true, completion: nil)
        }
    }

    private func addPuppy(name: String, info: String, image: UIImage?) {
        let tag = "태그 예시" // 태그는 예시로 고정값을 사용, 필요에 따라 수정 가능
        puppies.append((name: name, info: info, tag: tag, image: image)) // 데이터 추가
        collectionView.reloadData()
        pageControl.numberOfPages = puppies.count // 페이지 수 업데이트
        
        // 컬렉션 뷰와 페이지 컨트롤을 보여지게 함
        collectionView.isHidden = false
        pageControl.isHidden = false

        collectionView.snp.updateConstraints {
            $0.height.equalTo(150) // 컬렉션 뷰의 콘텐츠에 맞는 적절한 높이 설정
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI() // UI 설정
        setupBindings() // 바인딩 설정
    }
}

// MARK: - UICollectionViewDataSource
extension MypageViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return puppies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PuppyCollectionViewCell.identifier, for: indexPath) as? PuppyCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let puppy = puppies[indexPath.row]
        cell.configure(with: puppy)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MypageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 셀의 크기를 설정합니다.
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height - 20)
    }
}
