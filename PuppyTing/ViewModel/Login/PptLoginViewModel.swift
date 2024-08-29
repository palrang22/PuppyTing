//
//  PptLoginViewModel.swift
//  PuppyTing
//
//  Created by 박승환 on 8/29/24.
//

import Foundation

import FirebaseAuth
import RxSwift

class PptLoginViewModel {
    private let disposeBag = DisposeBag()
    
    let userSubject = PublishSubject<User>()
    let errorSubject = PublishSubject<Error>()
    
    func emailSignIn(email: String, pw: String) {
        FirebaseAuthManager.shared.emailSignIn(email: email, pw: pw).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] user in
            self?.userSubject.onNext(user)
        }, onFailure: { [weak self] error in
            // error 을 onError 로 처리하면 스트림이 자동 종료되므로 error 를 저장할 subject 를 만들어 error 를 onNext 로 오류 전달
            self?.errorSubject.onNext(error)
        }).disposed(by: disposeBag)
    }
}
