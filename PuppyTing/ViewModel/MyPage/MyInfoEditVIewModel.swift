//
//  MyInfoEditVIewModel.swift
//  PuppyTing
//
//  Created by 박승환 on 9/7/24.
//

import Foundation
import UIKit

import RxSwift

class MyInfoEditVIewModel {
    
    private let disposeBag = DisposeBag()
    
    let updateSubject = PublishSubject<Bool>()
    let passwordSubject = PublishSubject<Bool>()
    let imageSubject = PublishSubject<String>()
    
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
    
    func updateImage(image: UIImage) {
        FirebaseStorageManager.shared.uploadImage(image: image).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] imageUrl in
            self?.imageSubject.onNext(imageUrl)
        }).disposed(by: disposeBag)
    }
    
}
