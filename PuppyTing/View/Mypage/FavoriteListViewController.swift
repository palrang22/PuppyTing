//
//  FavoriteListViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/9/24.
//

import UIKit

import RxSwift

class FavoriteListViewController: UIViewController {
    
    private let tableView = UITableView()
    private let viewModel = FavoriteListViewModel()
    private let disposeBag = DisposeBag()
    private var favoriteList = [Favorite]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        bindViewModel()
        viewModel.fetchFavorites()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        navigationItem.title = "즐겨찾는 친구"
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.register(FavoriteListTableViewCell.self, forCellReuseIdentifier: FavoriteListTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        // Separator를 좌우에서 동일하게 떨어트리기
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    private func bindViewModel() {
        viewModel.favorites
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] favorites in
                self?.favoriteList = favorites
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
//    private func unfavoriteUser(at indexPath: IndexPath) {
//        let favorite = favoriteList[indexPath.row]
//        let bookmarkId = favorite.uuid
//        
//        viewModel.removeBookmark(bookmarkId: bookmarkId)
//            .subscribe(onSuccess: { [weak self] in
//                self?.favoriteList.remove(at: indexPath.row)
//                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
//            }, onError: { error in
//                print("즐겨찾기 해제 오류: \(error)")
//            })
//            .disposed(by: disposeBag)
//    }
}

extension FavoriteListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteListTableViewCell.identifier, for: indexPath) as? FavoriteListTableViewCell else {
            return UITableViewCell()
        }
        
        let favorite = favoriteList[indexPath.row]
        cell.configure(with: favorite)
        
//        cell.onUnfavoriteButtonTapped = { [weak self] in
//            self?.unfavoriteUser(at: indexPath)
//        }
        cell.selectionStyle = .none // 셀선택 배경 안바뀌게
        
        return cell
    }
    
    // 셀 선택시 프로필모달 띄우기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFavorite = favoriteList[indexPath.row]
        let profileVC = ProfileViewController()
        
        profileVC.modalPresentationStyle = .pageSheet
        profileVC.userid = selectedFavorite.uuid
        
        if let sheet = profileVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(profileVC, animated: true, completion: nil)
    }
}
