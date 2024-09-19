import UIKit

import RxCocoa
import RxSwift
import SnapKit

class MyFeedManageViewController: UIViewController { // kkh
    
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    private var feeds: [TingFeedModel] = []
    private let viewModel = MyFeedManageViewModel()

    private func setupNavigationBar() {
        navigationItem.title = "내 피드 관리"
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.register(MyFeedTableViewCell.self, forCellReuseIdentifier: MyFeedTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupTableView()
        bindViewModel()
        viewModel.fetchFeeds()
    }

    private func bindViewModel() {
        viewModel.feedsSubject
            .subscribe(onNext: { [weak self] feeds in
                print("Received feeds: \(feeds)")
                self?.feeds = feeds
                self?.tableView.reloadData()
            }, onError: { error in
                print("Error receiving feeds: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}

extension MyFeedManageViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyFeedTableViewCell.identifier, for: indexPath) as? MyFeedTableViewCell else {
            return UITableViewCell()
        }
        
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
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MyFeedManageViewController: DetailTingViewControllerDelegate {
    func didDeleteFeed() {
        viewModel.fetchFeeds()
    }
}
