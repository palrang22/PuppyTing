//
//  FeedListViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/23/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class FeedListViewController: UIViewController {
    
    var userid: String = ""
    private let tableView = UITableView()
    var feeds: [TingFeedModel] = [] // 피드 데이터를 저장하는 배열
    let viewModel = FeedListViewModel()

    private let disposeBag = DisposeBag()
    
    private func setupNavigationBar() {
        navigationItem.title = "작성글 목록"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupUI()
        bindViewModel()
        viewModel.fetchFeeds(forUserId: userid)
    }
    
    private func setupUI() {
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        // Separator를 좌우에서 동일하게 떨어트리기
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    private func bindViewModel() {
        viewModel.feedsSubject
            .subscribe(onNext: { [weak self] feeds in
                self?.feeds = feeds
                self?.tableView.reloadData()
            }, onError: { error in
                print("Error receiving feeds: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}

extension FeedListViewController:  UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 셀선택 배경 사라지게 - jgh
        let selectedFeed = feeds[indexPath.row]
       
        let detailVC = DetailTingViewController()
        detailVC.tingFeedModels = selectedFeed
        detailVC.delegate = self // Delegate 설정
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }    
}

extension FeedListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: indexPath) as? FeedTableViewCell else {
            return UITableViewCell()
        }
        
        // 피드 데이터를 사용해 셀 구성
        let feed = feeds[indexPath.row]
        cell.configure(with: feed)
        
        return cell
    }
}

extension FeedListViewController: DetailTingViewControllerDelegate {
    func didDeleteFeed() {

    }
}

