//
//  ProfileViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/6/24.
//

import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class ProfileViewController: UIViewController {
    
    var userid: String?
    private var member: Member?
    private let disposeBag = DisposeBag()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: "ProfileCell")
        collectionView.register(PuppyHeaderCell.self, forCellWithReuseIdentifier: "PuppyHeaderCell")
        
        loadData()
    }
    
    // Firestore에서 특정 사용자 정보를 가져와 컬렉션뷰에 표시하고 그걸 ProfileCell에 전달
    private func loadData() {
        guard let userid = self.userid else { return }
        FireStoreDatabaseManager.shared.findMemeber(uuid: userid)
            .subscribe(onSuccess: { [weak self] member in
                self?.member = member
                self?.collectionView.reloadData()
            }, onFailure: { error in
                print("멤버 찾기 실패: \(error)")
            }).disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            if let member = self.member {
                cell.configure(with: member)
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PuppyHeaderCell", for: indexPath) as! PuppyHeaderCell
            return cell
        default:
            fatalError("Unexpected index path")
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case 0:
            return CGSize(width: collectionView.bounds.width, height: 250) // ProfileCell size
        case 1:
            return CGSize(width: collectionView.bounds.width, height: 40) // PuppyHeaderCell size
        default:
            return CGSize(width: collectionView.bounds.width, height: 100)
        }
    }
}
