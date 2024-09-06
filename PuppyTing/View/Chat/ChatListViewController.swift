//
//  ChatListViewController.swift
//  PuppyTing
//
//  Created by 박승환 on 8/28/24.
//

import Foundation
import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift


class ChatListViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate {
    
    private let disposeBag = DisposeBag()
    private let chatRoomViewModel = ChatRoomViewModel()
    
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
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.refreshControl = refreshControl
        
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
    
    private func findUserId() -> String {
        guard let user = Auth.auth().currentUser else { return "" }
        return user.uid
    }
    
    let refreshControl = UIRefreshControl()
    
    private func bindTableView() {
        let userId = findUserId()
        let input = ChatRoomViewModel.Input(fetchRooms: refreshControl.rx.controlEvent(.valueChanged).startWith(()))
        let output = chatRoomViewModel.transform(input: input, userId: userId)
        
        output.chatRooms
            .bind(to: tableView.rx.items(cellIdentifier: ChatTableViewCell.identifier, cellType: ChatTableViewCell.self)) { index, data, cell in
                
                if let lastChat = data.lastChat?.text {
                    cell.configure(with: [UIImage(named: "defaultProfileImage") ?? UIImage()], title: data.name, content: lastChat)
                } else {
                    cell.configure(with: [UIImage(named: "defaultProfileImage") ?? UIImage()], title: data.name, content: "내용없음")
                }
                
            }
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ChatRoom.self)
            .subscribe(onNext: { [weak self] data in
                self?.navigateToChatView(chatRoom: data)
            })
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    private func navigateToChatView(chatRoom: ChatRoom) {
        let chatVC = ChatViewController()
        chatVC.roomId = chatRoom.id
        chatVC.titleText = "1대1 채팅방"
        navigationController?.pushViewController(chatVC, animated: true)
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
