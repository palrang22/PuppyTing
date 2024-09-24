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
    
    private let cancleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "closeButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "작성글 목록"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        bindViewModel()
        viewModel.fetchFeeds(forUserId: userid)
    }
    
    private func setupUI() {
        [cancleButton, titleLabel, tableView].forEach {
            view.addSubview($0)
        }
        
        cancleButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.height.width.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(cancleButton)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(cancleButton).offset(35)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        // Separator를 좌우에서 동일하게 떨어트리기
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    @objc
    private func didTapCloseButton() {
        dismiss(animated: true)
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

extension FeedListViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 셀선택 배경 사라지게 - jgh
        let selectedFeed = feeds[indexPath.row]
       
        let detailVC = DetailTingViewController()
        detailVC.tingFeedModels = selectedFeed
        detailVC.delegate = self // Delegate 설정
        
        // 모달 설정
        detailVC.modalPresentationStyle = .pageSheet // 또는 .formSheet 사용하라는데 둘이 똑같이보임 아이패드에서만 다르게 보이는거같음
        if let sheet = detailVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true // Grabber 표시
        }
        
        present(detailVC, animated: true, completion: nil) // 모달로 띄우기
    }
}

extension FeedListViewController: DetailTingViewControllerDelegate {
    func didDeleteFeed() {

    }
}

