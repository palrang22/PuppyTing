//
//  LoginViewModel.swift
//  PuppyTing
//
//  Created by 박승환 on 8/29/24.
//

import AuthenticationServices
import Foundation
import UIKit

import FirebaseAuth
import GoogleSignIn
import RxSwift

class LoginViewModel {
    private let disposeBag = DisposeBag()
    
    let userSubject = PublishSubject<User>()
    let errorSubject = PublishSubject<Error>()
    let userExistsSubject = PublishSubject<Bool>()
    let memeberSubject = PublishSubject<Member>()
    let memberErrorSubject = PublishSubject<Error>()
    var user: User? = nil
    
    func googleSignIn(viewController: UIViewController) {
        FirebaseAuthManager.shared.googleSignIn(viewController: viewController).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] user in
            self?.userSubject.onNext(user)
            self?.user = user
        }, onFailure: { [weak self] error in
            self?.errorSubject.onNext(error)
        }).disposed(by: disposeBag)
    }
    
    func isExistsUser(uuid: String) {
        FireStoreDatabaseManager.shared.findMemeber(uuid: uuid).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] exists in
            self?.userExistsSubject.onNext(exists)
        }).disposed(by: disposeBag)
    }
    
    func signUp(uuid: String, email: String) {
        FireStoreDatabaseManager.shared.socialSignUp(uuid: uuid, email: email).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] member in
            self?.memeberSubject.onNext(member)
        }, onFailure: { [weak self] error in
            self?.memberErrorSubject.onNext(error)
        }).disposed(by: disposeBag)
    }
    
    func appleSignIn(credential: ASAuthorizationAppleIDCredential) {
        FirebaseAuthManager.shared.appleSignIn(credential: credential).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] user in
            self?.userSubject.onNext(user)
            self?.user = user
        }, onFailure: { error in
            self.errorSubject.onNext(error)
        }).disposed(by: disposeBag)
    }
    
    func startAppleLogin() -> String {
        return FirebaseAuthManager.shared.startAppleSignIn()
    }
    
}
