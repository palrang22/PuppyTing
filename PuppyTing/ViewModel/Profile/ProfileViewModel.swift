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
    
    let footPrintSuccess = PublishSubject<Void>()
    let footPrintError = PublishSubject<Error>()
    
    func addBookmark(bookmarkId: String) {
        FireStoreDatabaseManager.shared.addBookmark(forUserId: Auth.auth().currentUser?.uid ?? "", bookmarkId: bookmarkId)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.bookmarkSuccess.onNext(())
            }, onFailure: { [weak self] error in
                self?.bookmarkError.onNext(error)
            }).disposed(by: disposeBag)
    }
    
    func addFootPrint(footPrintId: String) {
        FireStoreDatabaseManager.shared.addFootPrint(toUserId: footPrintId)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.footPrintSuccess.onNext(())
            }, onFailure: { [weak self] error in
                self?.footPrintError.onNext(error)
            }).disposed(by: disposeBag)
    }

}

