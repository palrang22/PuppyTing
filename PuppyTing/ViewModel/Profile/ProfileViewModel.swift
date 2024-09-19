//
//  ProfileViewModel.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/9/24.
//

import Foundation

import FirebaseAuth
import RxSwift

class ProfileViewModel {
    
    private let disposeBag = DisposeBag()
    
    let bookmarkSuccess = PublishSubject<Void>()
    let bookmarkError = PublishSubject<Error>()
    
    let blockSuccess = PublishSubject<Void>()
    let blockError = PublishSubject<Error>()
    
    func addBookmark(bookmarkId: String) {
        FireStoreDatabaseManager.shared.addBookmark(forUserId: Auth.auth().currentUser?.uid ?? "", bookmarkId: bookmarkId)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.bookmarkSuccess.onNext(())
            }, onFailure: { [weak self] error in
                self?.bookmarkError.onNext(error)
            }).disposed(by: disposeBag)
    }
    
    func blockUser(userId: String) {
        FireStoreDatabaseManager.shared.blockUser(userId: userId).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] in
            self?.blockSuccess.onNext(())
        }, onFailure: { [weak self] error in
            self?.blockError.onNext(error)
        }).disposed(by: disposeBag)
    }
}

