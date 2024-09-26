//
//  ProfileViewModel.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/9/24.
//

import Foundation
import UIKit

import FirebaseAuth
import RxSwift

class ProfileViewModel {
    
    private let disposeBag = DisposeBag()
    
    // 강아지 정보 관련 BehaviorSubjects
    let puppySubject = PublishSubject<[Pet]>()
    
    // 즐겨찾기 및 발도장 관련 Subjects
    let bookmarkSuccess = PublishSubject<Void>()
    let bookmarkError = PublishSubject<Error>()
    let footPrintSuccess = PublishSubject<Void>()
    let footPrintError = PublishSubject<Error>()
    
    // 즐겨찾기 추가 메서드
    func addBookmark(bookmarkId: String) {
        FireStoreDatabaseManager.shared.addBookmark(forUserId: Auth.auth().currentUser?.uid ?? "", bookmarkId: bookmarkId)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.bookmarkSuccess.onNext(())
            }, onFailure: { [weak self] error in
                self?.bookmarkError.onNext(error)
            }).disposed(by: disposeBag)
    }
    
    // 사용자 차단 메서드
    func blockedUser(uuid: String) {
        FireStoreDatabaseManager.shared.blockUser(userId: uuid)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: {
                // 성공 처리
            }, onFailure: { error in
                // 실패 처리
            }).disposed(by: disposeBag)
    }
    
    // 발도장 추가 메서드
    func addFootPrint(footPrintId: String) {
        FireStoreDatabaseManager.shared.addFootPrint(toUserId: footPrintId)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.footPrintSuccess.onNext(())
            }, onFailure: { [weak self] error in
                self?.footPrintError.onNext(error)
            }).disposed(by: disposeBag)
    }
    
    func fetchPetsForUser(userId: String) {
        FireStoreDatabaseManager.shared.fetchPetsByUserId(userId: userId).observe(on: MainScheduler.instance).subscribe(onSuccess: { petList in
            self.puppySubject.onNext(petList)
        }).disposed(by: disposeBag)
    }
}
