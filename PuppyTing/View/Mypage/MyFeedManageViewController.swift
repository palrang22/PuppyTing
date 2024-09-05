import UIKit
import RxCocoa
import RxSwift
import SnapKit

class MyFeedManageViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    
    private func setupNavigationBar() {
        navigationItem.title = "내 피드 관리"
        
        let editButton = UIBarButtonItem(title: "삭제", style: .plain, target: self, action: #selector(handleEditButtonTapped))
        navigationItem.rightBarButtonItem = editButton
    }

    @objc private func handleEditButtonTapped() {
        print("Edit button tapped")
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        // 커스텀 셀 등록
        tableView.register(MyFeedTableViewCell.self, forCellReuseIdentifier: MyFeedTableViewCell.identifier)
        
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

extension MyFeedManageViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 셀 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 // 예시로 10개의 셀을 반환
    }
    
    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyFeedTableViewCell.identifier, for: indexPath) as? MyFeedTableViewCell else {
            return UITableViewCell()
        }
        
        // 데이터 설정 (임의의 데이터)
        let title = "피드 제목 \(indexPath.row + 1)"
        let date = "2024-09-0\(indexPath.row + 1)"
        let description = "이것은 게시글의 내용이 들어갈 곳 여러 줄을 입력할 수 있으며 텍스트가 길면 자동으로 줄바꿈이 됨"
        
        // 셀에 제목, 날짜, 설명 데이터 설정
        cell.configure(with: title, description: description, datelabel: date)
        
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
