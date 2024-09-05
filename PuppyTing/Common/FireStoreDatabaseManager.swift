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
    
    func socialSignUp(uuid: String, email: String) -> Single<Member> {
        return Single.create { [weak self] single in
            let member = Member(uuid: uuid, email: email, password: "nil", nickname: "User_\(email.split(separator: "@")[0])", profileImage: "기본 이미지", footPrint: 0, isSocial: true)
            self?.db.collection("member").document(uuid).setData(member.dictionary) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(member))
                }
            }
            return Disposables.create()
        }
    }
    
    func findMemeber(uuid: String) -> Single<Bool> {
        return Single.create { [weak self] single in
            let docRef = self?.db.collection("member").document(uuid)
            docRef?.getDocument(completion: { result, error in
                if let error = error {
                    single(.failure(error))
                } else if let result = result, result.exists {
                    single(.success(true))
                } else {
                    single(.success(false))
                }
            })
            return Disposables.create()
        }
    }
    
    func findMemeber(uuid: String) -> Single<Member> {
        return Single.create { [weak self] single in
            let docRef = self?.db.collection("member").document(uuid)
            docRef?.getDocument(completion: { result, error in
                if let error = error {
                    single(.failure(error))
                } else if let result = result, result.exists, let data = result.data() {
                    if let member = Member(dictionary: data) {
                        single(.success(member))
                    }
                }
            })
            return Disposables.create()
        }
    }
    
}
