//
//  FindingPasswordViewModel.swift
//  PuppyTing
//
//  Created by 박승환 on 9/2/24.
//

import Foundation

import FirebaseAuth
import RxSwift

class FindingPasswordViewModel {
    private let disposeBag = DisposeBag()
    
    let sendEmailSubject = PublishSubject<Bool>()
    let errorSubject = PublishSubject<Error>()
    
    func passwordReset(email: String) {
        FirebaseAuthManager.shared.passwordReset(email: email).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] emailSend in
            self?.sendEmailSubject.onNext(emailSend)
        }, onFailure: { [weak self] error in
            self?.errorSubject.onNext(error)
        }).disposed(by: disposeBag)
    }
    
    
    
}
