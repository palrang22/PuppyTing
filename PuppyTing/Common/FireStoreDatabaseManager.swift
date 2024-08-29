//
//  FireStoreDatabaseManager.swift
//  PuppyTing
//
//  Created by 박승환 on 8/29/24.
//

import Foundation

import FirebaseCore
import FirebaseFirestore
import RxSwift

class FireStoreDatabaseManager {
    
    static let shared = FireStoreDatabaseManager()
    
    private let db = Firestore.firestore()
    
    private init () {
        
    }
    
    func emailSignUp(uuid: String, email: String, pw: String, nickname: String) -> Single<Member> {
        return Single.create{ [weak self] single in
            let memeber = Member(uuid: uuid, email: email, password: pw, nickname: nickname, profileImage: "기본 이미지", footPrint: 0, isSocial: false)
            self?.db.collection("member").document(uuid).setData(memeber.dictionary) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(memeber))
                }
            }
            return Disposables.create()
        }
    }
    
}
