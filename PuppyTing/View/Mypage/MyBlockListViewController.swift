import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class MyBlockListViewController : UIViewController {
    
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    
    private func setupNavigationBar() {
        navigationItem.title = "차단 목록"
        
        let deleteButton = UIBarButtonItem(title: "선택 삭제", style: .plain, target: self, action: #selector(handleEditButtonTapped))
        navigationItem.rightBarButtonItem = deleteButton
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
    }
}

extension MyBlockListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 셀 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 // 예시로 10개의 셀을 반환
    }
    
    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyBlockListTableViewCell.identifier, for: indexPath) as? MyBlockListTableViewCell else {
            return UITableViewCell()
        }
        
        // 데이터 설정 (임의의 데이터)
        let title = "차단한 사람 닉네임 \(indexPath.row + 1)"
        let profileImage = UIImage(systemName: "person.crop.circle")
        
        cell.configure(with: title, image: profileImage)
        
        return cell
    }
    
    // 셀 높이 자동 조정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // 셀 높이 예측
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
