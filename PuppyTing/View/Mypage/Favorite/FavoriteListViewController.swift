//
//  FavoriteListViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/9/24.
//

import UIKit

import FirebaseAuth
import RxSwift

class FavoriteListViewController: UIViewController {
    
    private let tableView = UITableView()
    private let viewModel = FavoriteListViewModel()
    private let disposeBag = DisposeBag()
    private var favoriteList = [Favorite]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        setupView()
        setupTableView()
        bindViewModel()
        viewModel.fetchFavorites()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
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
        
        // Separator를 좌우에서 동일하게 떨어트리기
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
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
    
    private func createChatRoom(chatRoomName: String, users: [String], userId: String) {
        FirebaseRealtimeDatabaseManager.shared.checkIfChatRoomExists(userIds: users) { exists, chatId in
            if exists {
                if let roomId = chatId {
                    self.moveChatRoom(roomId: roomId, users: users, userId: userId)
                }
            } else {
                FirebaseRealtimeDatabaseManager.shared.createChatRoom(name: chatRoomName, users: users)
                    .observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] roomId in
                    self?.moveChatRoom(roomId: roomId, users: users, userId: userId)
                }).disposed(by: self.disposeBag)
            }
        }
    }
    
    private func moveChatRoom(roomId: String, users: [String], userId: String) {
        let chatVC = ChatViewController()
        chatVC.roomId = roomId
        let userId = userId
        let otherUser = users.first == userId ? users.last : users.first
        if let otherUser = otherUser {
            FireStoreDatabaseManager.shared.findMemberNickname(uuid: otherUser) { nickname in
                chatVC.titleText = nickname
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
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
        
        // "작성글 보기" 버튼이 눌렸을 때 실행될 클로저
        cell.onViewPostsButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            let feedListVC = FeedListViewController()
            feedListVC.userid = favorite.uuid // 해당 유저의 글 목록을 보여주기 위한 userId 전달
            
            navigationController?.pushViewController(feedListVC, animated: true)
        }
        
        cell.onChatActionButtonTapped = { [weak self] in
            let userId = Auth.auth().currentUser?.uid
            let otherUserId = favorite.uuid
            guard let userId = userId else { return }
            let users = [userId, otherUserId]
            self?.createChatRoom(chatRoomName: favorite.nickname, users: users, userId: userId)
        }
        
        cell.selectionStyle = .none // 셀선택 배경 안바뀌게
        
        return cell
    }
    
    // 셀 선택시 프로필모달 띄우기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFavorite = favoriteList[indexPath.row]
        let profileVC = ProfileViewController()
        
        profileVC.modalPresentationStyle = .pageSheet
        profileVC.userId = selectedFavorite.uuid
        
        if let sheet = profileVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(profileVC, animated: true, completion: nil)
    }
}
