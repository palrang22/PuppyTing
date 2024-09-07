//
//  MyInfoEditVIewModel.swift
//  PuppyTing
//
//  Created by 박승환 on 9/7/24.
//

import Foundation

import RxSwift

class MyInfoEditVIewModel {
    
    private let disposeBag = DisposeBag()
    
    private let memberSubject = PublishSubject<Member>()
    let updateSubject = PublishSubject<Bool>()
    let passwordSubject = PublishSubject<Bool>()
    
    func findMember(uuid: String) {
        FireStoreDatabaseManager.shared.findMemeber(uuid: uuid).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] member in
            self?.memberSubject.onNext(member)
        }).disposed(by: disposeBag)
    }
    
    func updateMember(member: Member) {
        FireStoreDatabaseManager.shared.updateMember(member: member).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] isUpdate in
            self?.updateSubject.onNext(isUpdate)
        }).disposed(by: disposeBag)
    }
    
    func updatePassword(oldpassword: String, newPassword: String) {
        FirebaseAuthManager.shared.passwordUpdate(oldPassword: oldpassword, newPassword: newPassword).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] isUpdate in
            self?.passwordSubject.onNext(isUpdate)
        }).disposed(by: disposeBag)
    }
    
}
