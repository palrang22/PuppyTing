//
//  TingViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//
import CoreLocation
import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class TingViewController: UIViewController {
    private let viewModel = TingViewModel()
    private let disposeBag = DisposeBag()
    
    var tingFeedModels: [TingFeedModel] = []
    var currentUserID: String = Auth.auth().currentUser?.uid ?? ""
    var isLoading = false
    var hasMoreData = false
    
    //MARK: Component 선언
    private lazy var feedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TingCollectionViewCell.self,
                                forCellWithReuseIdentifier: TingCollectionViewCell.id)
        //collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "모든 지역"
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .heavy)
        return label
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "postButton"), for: .normal)
        button.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: View 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()        
        bind()
        loadInitialData()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.feedCollectionView.reloadData()
//    }
    
    private func loadInitialData() {
        loadFeedData(limit: 10)
    }
        
    private func loadMoreData() {
        if !isLoading && hasMoreData {
            isLoading = true
            loadFeedData(limit: 10)
        }
    }
    
    @objc private func refreshFeed() {
        viewModel.lastDocuments = nil
        tingFeedModels.removeAll()
        loadInitialData()
        refreshControl.endRefreshing()
    }
        
    private func loadFeedData(limit: Int) {
        viewModel.fetchFeed(collection: "tingFeeds", userId: currentUserID, limit: limit, lastDocument: viewModel.lastDocuments)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] (data, hasMore) in
                    guard let self = self else { return }
                    let newFeeds = data.filter { newFeed in
                        !self.tingFeedModels.contains(where: { $0.postid == newFeed.postid })
                    }
                    self.tingFeedModels.append(contentsOf: newFeeds)
                    self.feedCollectionView.reloadData()
                    self.hasMoreData = hasMore
                    
//                    if let lastDoc = data.last {
//                        self.viewModel.lastDocuments = lastDoc
//                    }
                    self.isLoading = false
                },
                onFailure: { [weak self] error in
                    print("데이터 로드 실패: \(error.localizedDescription)")
                    self?.isLoading = false
                }
            ).disposed(by: disposeBag)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            print("스크롤됨")
            loadMoreData()
        }
    }
    
    //MARK: Rx
    private func bind() {
        feedCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self else { return }
                let selectedFeed = self.tingFeedModels[indexPath.row]
                navigate(with: selectedFeed)
            }).disposed(by: disposeBag)
    }
    
    private func handleLocation(location: CLLocationCoordinate2D) {
        // location 정보를 처리하는 메서드
        print("받아온 location: \(location.latitude), \(location.longitude)")
        // 이곳에서 location을 이용한 추가 작업 처리 가능
    }
    
    private func navigate(with selectedData: TingFeedModel) {
        let detailVC = DetailTingViewController()
        detailVC.tingFeedModels = selectedData
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    //MARK: 임시 - button 및 CollectionView 이동 로직
    @objc
    private func postButtonTapped() {
        navigationController?.pushViewController(PostTingViewController(), animated: true)
    }
    
    //MARK: UI 설정 및 제약조건 등
    private func setUI() {
        view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addressLabel)
        navigationController?.navigationBar.tintColor = .puppyPurple
    }
    
    private func setLayout() {
        [feedCollectionView, postButton].forEach { view.addSubview($0) }
        feedCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        postButton.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.width.height.equalTo(64)
        }
    }
}


//MARK: CollectionView
extension TingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let dummyCell = TingCollectionViewCell()
        let feedModel = tingFeedModels[indexPath.row]
        dummyCell.configure(with: feedModel, currentUserID: currentUserID)
        
        dummyCell.setNeedsLayout()
        dummyCell.layoutIfNeeded()
        
        let height = dummyCell.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)).height + 30
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

extension TingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tingFeedModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < tingFeedModels.count else {
            print("Error: Index out of range. row: \(indexPath.row), count: \(tingFeedModels.count)")
            return UICollectionViewCell() // 빈 셀 반환
        }
        
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: TingCollectionViewCell.id, for: indexPath) as? TingCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let feedModel = tingFeedModels[indexPath.row]
        cell.viewController = self
        cell.configure(with: feedModel, currentUserID: currentUserID)
        return cell
    }
}
