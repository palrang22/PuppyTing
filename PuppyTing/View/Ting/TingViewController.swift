//
//  TingViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

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
    
    //MARK: Component 선언
    private lazy var feedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TingCollectionViewCell.self,
                                forCellWithReuseIdentifier: TingCollectionViewCell.id)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "지역이름"
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
    
    //MARK: View 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
        bind()
        readFeedData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readFeedData()
    }
    
    private func readFeedData() {
        viewModel.readAll(collection: "tingFeeds") { [weak self] data in
            self?.tingFeedModels = data
            DispatchQueue.main.async {
                self?.feedCollectionView.reloadData()
            }}
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
        return CGSize(width: collectionView.frame.width, height: 350)
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
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: TingCollectionViewCell.id, for: indexPath) as? TingCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let feedModel = tingFeedModels[indexPath.row]
        cell.configure(with: feedModel)
        return cell
    }
}
//
//extension TingViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        navigationController?.pushViewController(DetailTingViewController(), animated: true)
//    }
//}
