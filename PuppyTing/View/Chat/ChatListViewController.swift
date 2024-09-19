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
        bindData()
        
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
            .subscribe { _ in
                self.refreshControl.endRefreshing()
            }.disposed(by: disposeBag)
        
        output.chatRooms
            .bind(to: tableView.rx.items(cellIdentifier: ChatTableViewCell.identifier, cellType: ChatTableViewCell.self)) { index, data, cell in
                let otherUser = data.users.first == userId ? data.users.last : data.users.first
                if let otherUser = otherUser {
                    FireStoreDatabaseManager.shared.checkUserData(uuid: otherUser) { result in
                        if result {
                            FireStoreDatabaseManager.shared.findMember(uuid: otherUser) { member in
                                if let lastChat = data.lastChat?.text {
                                    cell.config(image: member.profileImage, title: member.nickname, content: lastChat)
                                } else {
                                    cell.config(image: member.profileImage, title: member.nickname, content: "내용 없음")
                                }
                            }
                        } else {
                            if let lastChat = data.lastChat?.text {
                                cell.config(image: "nil", title: "알 수 없음", content: lastChat)
                            } else {
                                cell.config(image: "nil", title: "알 수 없음", content: "내용 없음")
                            }
                        }
                    }
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
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                
                let chatRooms = try? self.chatRoomViewModel.chatRoomsSubject.value()
                if let chatRoom = chatRooms?[indexPath.row] {
                    self.chatRoomViewModel.deleteChatRoom(chatRoom)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindData() {
        chatRoomViewModel.deleteRoomSubject.observe(on: MainScheduler.instance).subscribe(onNext: { isDelete in
            if isDelete {
                //채팅방 삭제
                self.okAlert(title: "채팅방 삭제", message: "채팅방 삭제 완료")
            } else {
                //채팅방 삭제 실패
                self.okAlert(title: "채팅방 삭제", message: "채팅방 삭제 실패")
            }
        }).disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    private func navigateToChatView(chatRoom: ChatRoom) {
        let chatVC = ChatViewController()
        chatVC.roomId = chatRoom.id
        let userId = findUserId()
        let otherUser = chatRoom.users.first == userId ? chatRoom.users.last : chatRoom.users.first
        if let otherUser = otherUser {
            FireStoreDatabaseManager.shared.findMemberNickname(uuid: otherUser) { nickname in
                chatVC.titleText = nickname
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
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
