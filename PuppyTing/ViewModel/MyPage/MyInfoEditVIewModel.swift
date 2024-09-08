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
    let fireStorePasswordSubject = PublishSubject<Bool>()
    let imageSubject = PublishSubject<String>()
    let realImageSubject = PublishSubject<UIImage>()
    let memberSubject = PublishSubject<Member>()
    
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
    
    func updateFireStorePassword(uuid: String, password: String) {
        FireStoreDatabaseManager.shared.updatePassword(uuid: uuid, password: password).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] isUpdate in
            self?.fireStorePasswordSubject.onNext(isUpdate)
        }).disposed(by: disposeBag)
    }
    
    func updateImage(image: UIImage) {
        FirebaseStorageManager.shared.uploadImage(image: image).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] imageUrl in
            self?.imageSubject.onNext(imageUrl)
        }).disposed(by: disposeBag)
    }
    
    func fetchImage(image: String) {
        NetworkManager.shared.loadImageFromURL(urlString: image).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] image in
            if let image = image {
                self?.realImageSubject.onNext(image)
            }
        }).disposed(by: disposeBag)
    }
    
    func findMember(uuid: String) {
        FireStoreDatabaseManager.shared.findMemeber(uuid: uuid).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] member in
            self?.memberSubject.onNext(member)
        }).disposed(by: disposeBag)
    }
    
}
