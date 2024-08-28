import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MypageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var puppies: [(name: String, info: String, tag: String)] = [] // 튜플을 사용
    
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
        label.text = "내 발도장           nn개!" // 띄어쓰기 10번함
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal  // 가로 스크롤로 설정
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.puppyPurple.withAlphaComponent(0.1)
        collectionView.layer.cornerRadius = 15
        collectionView.isPagingEnabled = true // 페이징 가능하도록 설정
        collectionView.isHidden = true // 초기에는 숨김
        return collectionView
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
    
    private let pageControl: UIPageControl = { // 페이지 인디케이터
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.isHidden = true // 초기에는 숨김
        return pageControl
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

        [profileContainerView, collectionView, pageControl, addPuppyButton, menuContainerView].forEach {
            stackView.addArrangedSubview($0)
        }

        [profileImageView, nickNameLabel, profileEditButton, myFootLabel].forEach {
            profileContainerView.addSubview($0)
        }

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

        // 처음에 컬렉션뷰를 숨기기 위해 높이를 0으로 설정합니다.
        collectionView.snp.makeConstraints {
            $0.height.equalTo(0)
            $0.left.right.equalToSuperview()
        }

        pageControl.snp.makeConstraints {
            $0.height.equalTo(20)  // 적절한 높이 설정
        }

        addPuppyButton.snp.makeConstraints {
            $0.height.equalTo(44)
        }

        menuContainerView.snp.makeConstraints {
            $0.height.equalTo(250)
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
    }

    private func navigateToPuppyRegistration() {
        let puppyRegistrationVC = PuppyRegistrationViewController()
        
        // 정보 입력 후 데이터를 전달받아 컬렉션 뷰를 업데이트합니다.
        puppyRegistrationVC.completionHandler = { [weak self] name, info in
            self?.addPuppy(name: name, info: info)
        }
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(puppyRegistrationVC, animated: true)
        } else {
            present(puppyRegistrationVC, animated: true, completion: nil)
        }
    }

    private func addPuppy(name: String, info: String) {
        puppies.append((name: name, info: info, tag: "태그")) // 데이터 추가
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
        
        setupUI() // UI 설정
        setupBindings() // 바인딩 설정
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 셀의 크기를 설정합니다.
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height - 20)
    }
    
    // MARK: - UICollectionViewDataSource
    
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
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
