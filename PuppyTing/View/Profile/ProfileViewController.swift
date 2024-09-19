//
//  ProfileViewController.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/6/24.
//

import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class ProfileViewController: UIViewController {
    
    var userid: String?
    private var member: Member?
    private let disposeBag = DisposeBag()
    
    private let profileCell = ProfileCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8) // 배경 투명도 설정
        
        view.addSubview(profileCell)
        profileCell.snp.makeConstraints {
            $0.centerY.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(5)
            $0.height.equalTo(280)
        }
        
        loadData()
    }
    
    // Firestore에서 특정 사용자 정보를 가져와 컬렉션뷰에 표시하고 그걸 ProfileCell에 전달
    private func loadData() {
        guard let userid = self.userid else { return }
        FireStoreDatabaseManager.shared.findMemeber(uuid: userid)
            .subscribe(onSuccess: { [weak self] member in
                self?.member = member
                self?.profileCell.parentViewController = self
                self?.profileCell.configure(with: member)
                self?.profileCell.memberId = member.uuid
                self?.profileCell.viewModel = ProfileViewModel()
            }, onFailure: { error in
                print("멤버 찾기 실패: \(error)")
            }).disposed(by: disposeBag)
    }
}


