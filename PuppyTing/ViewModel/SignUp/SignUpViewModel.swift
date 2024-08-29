//
//  SignUpViewModel.swift
//  PuppyTing
//
//  Created by 박승환 on 8/29/24.
//

import Foundation

import FirebaseAuth
import RxSwift

class SignUpViewModel {
    
    private let disposeBag = DisposeBag()
    
    let userSubject = PublishSubject<User>()
    let userErrorSubject = PublishSubject<Error>()
    let memeberSubject = PublishSubject<Member>()
    let memberErrorSubject = PublishSubject<Error>()
    
    func authentication(email: String, pw: String) {
        FirebaseAuthManager.shared.emailSignUp(email: email, pw: pw).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] user in
            self?.userSubject.onNext(user)
        }, onFailure: { error in
            self.userErrorSubject.onNext(error)
        }).disposed(by: disposeBag)
    }
    
    func signUp(uuid: String, email: String, pw: String, nickname: String) {
        FireStoreDatabaseManager.shared.emailSignUp(uuid: uuid, email: email, pw: pw, nickname: nickname).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] memeber in
            self?.memeberSubject.onNext(memeber)
        }, onFailure: { error in
            self.memberErrorSubject.onNext(error)
        }).disposed(by: disposeBag)
    }
    
    
}
