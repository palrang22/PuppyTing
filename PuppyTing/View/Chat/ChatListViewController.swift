//
//  ChatListViewController.swift
//  PuppyTing
//
//  Created by 박승환 on 8/28/24.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa

class ChatListViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate {
    
    private let disposeBag = DisposeBag()
    
    var searchBar: UISearchBar?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindTableView()
        
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    private func setupUI() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "채팅"

        // Search Button 추가
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchBar))
        navigationItem.rightBarButtonItem = searchButton
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    // 예제 데이터
    private let profileData = Observable.just([
        (images: [UIImage(named: "defaultProfileImage") ?? UIImage()], title: "한강 산책단톡 1", subtitle: "9월 10일 저녁 7시 산책 가실분!"),
        (images: [UIImage(named: "defaultProfileImage") ?? UIImage(), UIImage(named: "defaultProfileImage") ?? UIImage()], title: "한강 산책 단톡 4", subtitle: "바로가쟈~!"),
        (images: [UIImage(named: "defaultProfileImage") ?? UIImage(), UIImage(named: "defaultProfileImage") ?? UIImage(), UIImage(named: "defaultProfileImage") ?? UIImage()], title: "한강 바로가쟈!", subtitle: "산책 렛츠기릿"),
        (images: [UIImage(named: "defaultProfileImage") ?? UIImage(), UIImage(named: "defaultProfileImage") ?? UIImage(), UIImage(named: "defaultProfileImage") ?? UIImage(), UIImage(named: "defaultProfileImage") ?? UIImage()], title: "오늘은 강서구 바로가쟈!", subtitle: "어제 산책 너무 좋았어!")
    ])
    
    private func bindTableView() {
        profileData
            .bind(to: tableView.rx.items(cellIdentifier: ChatTableViewCell.identifier, cellType: ChatTableViewCell.self)) { index, data, cell in
                cell.configure(with: data.images, title: data.title, content: data.subtitle)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected((images: [UIImage], title: String, subtitle: String).self)
            .subscribe(onNext: { data in
                print("Selected chat room: \(data.title)")
            })
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    @objc func showSearchBar() {
        // 타이틀과 버튼 숨기기
        navigationItem.title = nil
        navigationItem.rightBarButtonItem = nil

        // Search Bar 생성
        searchBar = UISearchBar()
        searchBar?.delegate = self
        searchBar?.placeholder = "검색어를 입력하세요"
        searchBar?.showsCancelButton = true

        // 전체 화면에 검색 바 표시
        navigationItem.titleView = searchBar

        // Search Bar에 포커스를 맞춤
        searchBar?.becomeFirstResponder()
    }
    
    // 검색 버튼 클릭 시 호출되는 메소드
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        print("검색어: \(searchText)")

        // 검색 완료 후 Search Bar 숨기기
        hideSearchBar()
    }

    // 취소 버튼 클릭 시 호출되는 메소드
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Search Bar 숨기기
        hideSearchBar()
    }

    func hideSearchBar() {
        // Search Bar 숨기기
        navigationItem.titleView = nil
        
        // Large Title과 Search Button 복원
        navigationItem.title = "채팅"
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchBar))
        navigationItem.rightBarButtonItem = searchButton
    }
    
}
