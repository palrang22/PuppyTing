//
//  LoginViewModel.swift
//  PuppyTing
//
//  Created by 박승환 on 8/29/24.
//

import Foundation
import UIKit

import RxSwift
import FirebaseAuth
import GoogleSignIn

class LoginViewModel {
    private let disposeBag = DisposeBag()
    
    let userSubject = PublishSubject<User>()
    let errorSubject = PublishSubject<Error>()
    
    func googleSignIn(viewController: UIViewController) {
        FirebaseAuthManager.shared.googleSignIn(viewController: viewController).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] user in
            self?.userSubject.onNext(user)
        }, onFailure: { [weak self] error in
            self?.errorSubject.onNext(error)
        }).disposed(by: disposeBag)
    }
}
