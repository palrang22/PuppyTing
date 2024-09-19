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
    
    private func unfavoriteUser(at indexPath: IndexPath) {
        let favorite = favoriteList[indexPath.row]
        let bookmarkId = favorite.uuid
        
        viewModel.removeBookmark(bookmarkId: bookmarkId)
            .subscribe(onSuccess: { [weak self] in
                self?.favoriteList.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }, onError: { error in
                print("즐겨찾기 해제 오류: \(error)")
            })
            .disposed(by: disposeBag)
    }
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
        
        cell.onUnfavoriteButtonTapped = { [weak self] in
            self?.unfavoriteUser(at: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택 시 처리 로직
    }
}
