import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class MypageViewController: UIViewController {

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let puppys = BehaviorRelay<[Pet]>(value: [])
    private var petList: [Pet] = [] {
        didSet {
            puppys.accept(petList)

            if !petList.isEmpty {
                pageControl.numberOfPages = petList.count
                puppyCollectionView.isHidden = false
                pageControl.isHidden = false
                
                puppyCollectionView.snp.updateConstraints {
                    $0.height.equalTo(150)
                }
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    private let viewModel = MyPageViewModel()
    private var memeber: Member? = nil {
        didSet {
            // 데이터가 들어오면유저가 있는거임
            guard let member = memeber else { return }
            nickNameLabel.text = member.nickname
            myFootLabel.text = "내 발도장 \(member.footPrint)개"
        }
    }

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
        profileImage.layer.cornerRadius = 30
        profileImage.layer.masksToBounds = true
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
    
    private let puppyCollectionView: UICollectionView = {
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
    
    //MARK: View 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupKeyboardDismissRecognizer()
        setGesture()
        setupUI()
        setupBindings()
        fetchMemberInfo()
        addButtonAction()
        loadUserInfo()
        loadPuppyInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserInfo()
        loadPuppyInfo()
    }
    
    //MARK: Gesture
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.cancelsTouchesInView = false
        puppyCollectionView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        addPuppyButton.rx.tap
            .bind { [weak self] in
                self?.navigateToPuppyRegistration()
            }
            .disposed(by: disposeBag)
        
        profileEditButton.rx.tap
            .bind { [weak self] in
                self?.navigateToMyInfoEdit()
            }
            .disposed(by: disposeBag)
        
        puppys.bind(to: puppyCollectionView.rx
            .items(cellIdentifier: PuppyCollectionViewCell.identifier
                   , cellType: PuppyCollectionViewCell.self)) { index, pet, cell in
                cell.config(puppy: pet)
            }.disposed(by: disposeBag)
        
        puppyCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                print("셀 선택됨: \(indexPath.row)")  // 선택된 셀의 인덱스를 출력
                self?.navigateToPuppyEdit(at: indexPath)
            }).disposed(by: disposeBag)
        
        puppyCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    //MARK: Puppy 관련 메서드
    private func findUserId() -> String {
        guard let user = Auth.auth().currentUser else { return "" }
        return user.uid
    }

    private func navigateToPuppyRegistration() {
        let puppyRegistrationVC = PuppyRegistrationViewController()

        puppyRegistrationVC.puppyRegisteredSubject
            .observe(on: MainScheduler.instance) // 메인 스레드에서 처리
            .subscribe(onNext: { [weak self] name, info, imageUrl in
                let newPet = Pet(id: UUID().uuidString, userId: self?.findUserId() ?? "", name: name, age: Int(info) ?? 0, petImage: imageUrl ?? "", tag: ["태그"])
                self?.petList.append(newPet)
                self?.puppyCollectionView.reloadData()
                self?.pageControl.numberOfPages = self?.petList.count ?? 0
                self?.pageControl.isHidden = false

                self?.puppyCollectionView.snp.updateConstraints {
                    $0.height.equalTo(150)
                }

                UIView.animate(withDuration: 0.3) {
                    self?.view.layoutIfNeeded()
                }
            }).disposed(by: disposeBag)

        if let navigationController = self.navigationController {
            navigationController.pushViewController(puppyRegistrationVC, animated: true)
        } else {
            present(puppyRegistrationVC, animated: true, completion: nil)
        }
    }

    private func navigateToPuppyEdit(at indexPath: IndexPath) {
        let puppy = petList[indexPath.row]
        let puppyRegistrationVC = PuppyRegistrationViewController()
        puppyRegistrationVC.isEditMode = true
        puppyRegistrationVC.setPet(pet: puppy)
        puppyRegistrationVC.setupWithPuppy(name: puppy.name, info: "\(puppy.age)", tag: puppy.tag.joined(separator: ", "), imageUrl: puppy.petImage)

        puppyRegistrationVC.puppyUpdatedSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] name, info, imageUrl in
                let updatedPuppy = Pet(id: puppy.id, userId: puppy.userId, name: name, age: Int(info) ?? puppy.age, petImage: imageUrl ?? puppy.petImage, tag: puppy.tag)
                self?.petList[indexPath.row] = updatedPuppy
                self?.puppyCollectionView.reloadItems(at: [indexPath])
            })
            .disposed(by: disposeBag)

        if let navigationController = self.navigationController {
            navigationController.pushViewController(puppyRegistrationVC, animated: true)
        } else {
            present(puppyRegistrationVC, animated: true, completion: nil)
        }
    }


    private func addPuppy(name: String, info: String, imageUrl: String?) {
        let tag = "태그 예시"
        guard let imageUrl = imageUrl else { return }

        let newPet = Pet(id: UUID().uuidString, userId: findUserId(), name: name, age: Int(info) ?? 0, petImage: imageUrl, tag: [tag])
        petList.append(newPet) // petList에 추가
        puppyCollectionView.reloadData()
        pageControl.numberOfPages = petList.count // 페이지 수 업데이트
        pageControl.isHidden = false

        puppyCollectionView.snp.updateConstraints {
            $0.height.equalTo(150) // 컬렉션 뷰의 콘텐츠에 맞는 높이 설정
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func loadPuppyInfo() {
        let userId = findUserId()
        print("현재 로그인된 사용자 UUID: \(userId)")

        viewModel.fetchMemberPets(memberId: userId)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] petList in
                self?.handlePetList(petList)
            }, onFailure: { error in
                print("Error fetching pets: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }
    
    private func handlePetList(_ petList: [Pet]) {
        if !petList.isEmpty {
            self.petList = petList
            self.puppyCollectionView.isHidden = false
            self.pageControl.isHidden = false
            self.pageControl.numberOfPages = petList.count
        } else {
            self.puppyCollectionView.isHidden = true
            self.pageControl.isHidden = true
        }
    }
    
    //MARK: Myinfo 관련 메서드
    
    private func navigateToMyInfoEdit() {
        let myInfoEditVC = MyInfoEditViewController()
        myInfoEditVC.setMember(member: self.memeber)

        myInfoEditVC.updateSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isUpdated in
                print("updatesubject호출됨, \(isUpdated)")
                guard let self = self else { return }
                if isUpdated {
                    print("loaduserinfo 처리됨")
                    self.loadUserInfo()
                }
            })
            .disposed(by: disposeBag)

        if let navigationController = self.navigationController {
            navigationController.pushViewController(myInfoEditVC, animated: true)
        } else {
            present(myInfoEditVC, animated: true, completion: nil)
        }
    }
    
    private func loadUserInfo() {
        print("loaduserinfo 호출됨")
        fetchMemberInfo()
        
        viewModel.memberSubject
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] member in
                    DispatchQueue.main.async {
                        self?.memeber = member
                        self?.nickNameLabel.text = member.nickname
                        self?.myFootLabel.text = "내 발도장: \(member.footPrint)개"
                        self?.loadProfileImage(urlString: member.profileImage)
                    }
                }).disposed(by: disposeBag)
    }
    
    private func loadProfileImage(urlString: String) {
        KingFisherManager.shared.loadProfileImage(urlString: urlString, into: profileImageView, placeholder: UIImage(named: "defaultProfileImage"))
    }
    
    private func fetchMemberInfo() {
        guard let user = Auth.auth().currentUser else { return }
        viewModel.fetchMemberInfo(uuid: user.uid)
    }
    
    
    //MARK: 로그아웃 관련 메서드
    private func addButtonAction() {
        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
    }
    
    @objc
    private func logOut() {
        okAlertWithCancel(title: "로그아웃",
                          message: "정말로 로그아웃 하시겠습니까?",
                          okActionTitle: "아니오",
                          cancelActionTitle: "예",
                          cancelActionHandler:  { _ in
            AppController.shared.logOut()
        })
    }
    
    
    //MARK: Menu관련 메서드
    // MARK: - Setup Menu Items
    private func setupMenuItems() {
        let menuItems = ["내 피드 관리", "받은 산책 후기", "즐겨 찾는 친구", "차단 목록"]
        var previousItem: UIView? = nil

        for (index, itemName) in menuItems.enumerated() {
            let menuItem = createMenuItem(title: itemName)
            menuContainerView.addSubview(menuItem)

            // 버튼에 대한 탭 제스처 추가
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuItemTapped(_:)))
            menuItem.tag = index
            menuItem.addGestureRecognizer(tapGesture)

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

    // MARK: - createMenuItem 함수 추가
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

    // MARK: - 메뉴 항목 탭 처리
    @objc private func menuItemTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedIndex = sender.view?.tag else { return }

        switch selectedIndex {
        case 0:
            navigateToMyFeedManagement() // 내 피드 관리 페이지로 이동
        case 1:
            // 다른 페이지로 이동 (받은 산책 후기)
            break
        case 2:
            // 다른 페이지로 이동 (즐겨 찾는 친구)
            break
        case 3:
            // 다른 페이지로 이동 (차단 목록)
            break
        default:
            break
        }
    }

    // MARK: - 내 피드 관리 페이지로 이동
    private func navigateToMyFeedManagement() {
        let myFeedManageViewController = MyFeedManageViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(myFeedManageViewController, animated: true)
        } else {
            present(myFeedManageViewController, animated: true, completion: nil)
        }
    }
    
    
    
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide) // 안전 영역을 기준으로 설정
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

        [profileContainerView, puppyCollectionView, pageControl, addPuppyButton, menuContainerView].forEach {
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

        puppyCollectionView.snp.makeConstraints {
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

        let upperButtonsStackView = UIStackView(arrangedSubviews: [customerSupportButton, faqButton, noticeButton])
        upperButtonsStackView.axis = .horizontal
        upperButtonsStackView.spacing = 20
        upperButtonsStackView.distribution = .equalSpacing

        let lowerButtonsStackView = UIStackView(arrangedSubviews: [logOutButton, memberLeaveButton])
        lowerButtonsStackView.axis = .horizontal
        lowerButtonsStackView.spacing = 20
        lowerButtonsStackView.distribution = .equalSpacing

        let olympicButtonsContainer = UIStackView(arrangedSubviews: [upperButtonsStackView, lowerButtonsStackView])
        olympicButtonsContainer.axis = .vertical
        olympicButtonsContainer.spacing = 20
        olympicButtonsContainer.alignment = .center

        stackView.addArrangedSubview(olympicButtonsContainer)

        customerSupportButton.snp.makeConstraints {
            $0.top.equalTo(menuContainerView.snp.bottom).offset(30)
            $0.right.equalTo(faqButton.snp.left).offset(-20)
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
            $0.left.equalTo(faqButton.snp.right).offset(20)
            $0.width.height.equalTo(customerSupportButton)
        }
        
        logOutButton.snp.makeConstraints {
            $0.top.equalTo(customerSupportButton.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(0)
            $0.width.equalTo(135)
            $0.height.equalTo(44)
        }
        
        memberLeaveButton.snp.makeConstraints {
            $0.top.equalTo(logOutButton)
            $0.left.equalTo(logOutButton.snp.right).offset(30)
            $0.width.height.equalTo(logOutButton)
        }

        //collectionView.dataSource = self
        puppyCollectionView.register(PuppyCollectionViewCell.self, forCellWithReuseIdentifier: PuppyCollectionViewCell.identifier)

        setupMenuItems() // 메뉴 항목을 설정하는 함수 호출
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MypageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height - 20)
    }
}

//extension MypageViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("클릭됨")
//        navigateToPuppyEdit(at: indexPath)
//    }
//}
