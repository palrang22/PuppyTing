import UIKit

import RxSwift
import SnapKit

class MyBlockListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    private let viewModel = BlockListViewModel()
    
    private var blockedUsers: [Member] = [] // 차단된 사용자 목록을 저장할 배열
    
    private func setupNavigationBar() {
        navigationItem.title = "차단 목록"
        
//        let deleteButton = UIBarButtonItem(title: "선택 삭제", style: .plain, target: self, action: #selector(handleEditButtonTapped))
//        navigationItem.rightBarButtonItem = deleteButton
    }

    @objc private func handleEditButtonTapped() {
        print("Delete button tapped")
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        // 커스텀 셀 등록
        tableView.register(MyBlockListTableViewCell.self, forCellReuseIdentifier: MyBlockListTableViewCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupTableView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        // 차단된 사용자 목록을 가져옴
        viewModel.fetchBlockedUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func bindViewModel() {
        viewModel.blockedUsers
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] members in
                self?.blockedUsers = members
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MyBlockListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyBlockListTableViewCell.identifier, for: indexPath) as? MyBlockListTableViewCell else {
            return UITableViewCell()
        }
        
        // 데이터 설정
        let member = blockedUsers[indexPath.row]
        cell.configure(with: member)
        cell.delegate = self // 델리게이트 설정
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - MyBlockListTableViewCellDelegate
extension MyBlockListViewController: MyBlockListTableViewCellDelegate {
    
    func didTapUnblockButton(for member: Member) {
        // Firestore에서 차단 해제
        FireStoreDatabaseManager.shared.unblockUser(userId: member.uuid)
            .subscribe(onSuccess: {
                // 차단 목록에서 해당 사용자 제거
                self.blockedUsers.removeAll { $0.uuid == member.uuid }
                
                // 테이블 뷰 갱신
                self.tableView.reloadData()
                
            }, onFailure: { error in
                print("차단 해제 실패: \(error)")
            }).disposed(by: disposeBag)
    }
}
