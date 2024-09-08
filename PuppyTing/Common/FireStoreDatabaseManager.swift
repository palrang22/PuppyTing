//
//  FireStoreDatabaseManager.swift
//  PuppyTing
//
//  Created by 박승환 on 8/29/24.
//

import Foundation

import FirebaseAuth
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
            let memeber = Member(uuid: uuid, email: email, password: pw, nickname: nickname, profileImage: "defaultProfileImage", footPrint: 0, isSocial: false)
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
            let member = Member(uuid: uuid, email: email, password: "nil", nickname: "User_\(email.split(separator: "@")[0])", profileImage: "defaultProfileImage", footPrint: 0, isSocial: true)
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
    
    func updateMember(member: Member) -> Single<Bool> {
        return Single.create { single in
            let docRef = self.db.collection("member").document(member.uuid)
            docRef.updateData(["nickname" : member.nickname, "password" : member.password, "profileImage" : member.profileImage]) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(true))
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
    
    func findMember(uuid: String, completion: @escaping (Member) -> Void) {
        var member: Member? = nil
        let docRef = db.collection("member").document(uuid)
        docRef.getDocument{ result, error in
            if let result = result, result.exists, let data = result.data() {
                if let dataMember = Member(dictionary: data) {
                    member = dataMember
                }
            }
            if let member = member {
                completion(member)
            }
        }
    }
    
    func findMemberNickname(uuid: String, completion: @escaping (String) -> Void) {
        var nickName = ""
        let docRef = db.collection("member").document(uuid)
        docRef.getDocument{ result, error in
            if let result = result, result.exists, let data = result.data() {
                if let member = Member(dictionary: data) {
                    nickName = member.nickname
                }
            }
            completion(nickName)
        }
    }
    
    func deleteDocument(from collection: String, documentId: String) -> Single<Void> {
        return Single.create { [weak self] single in
            self?.db.collection(collection).document(documentId).delete { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    func blockUser(userId: String) -> Single<Void> {
        guard let currentUser = Auth.auth().currentUser?.uid else {
            return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 인증 실패"]))
        }
        
        return Single.create { [weak self] single in
            let ref = self?.db.collection("member").document(currentUser)
            ref?.updateData(["blockedUsers" : FieldValue.arrayUnion([userId])]) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    func reportPost(postId: String, reason: String) -> Single<Void> {
        let reportData: [String: Any] = [
            "postId": postId,
            "reason": reason,
            "timeStamp": Timestamp(date: Date())
        ]
        
        return Single.create { [weak self] single in
            self?.db.collection("report").addDocument(data: reportData) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    // 즐겨찾기 추가 메서드
    func addBookmard(forUserId userId: String, bookmarkId: String) -> Single<Void> {
        guard let currentUser = Auth.auth().currentUser?.uid else {
            return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 인증 실패"]))
        }
        
        return Single.create { [weak self] single in
            let ref = self?.db.collection("member").document(currentUser)
            ref?.updateData(["bookmark": FieldValue.arrayUnion([bookmarkId])]) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
    func createPuppy(userId: String, name: String, age: Int, petImage: String, tag: [String]) -> Single<Pet> {
        return Single.create { single in
            let docRef = self.db.collection("pet").document()
            let petId = docRef.documentID
            
            let pet = Pet(id: petId, userId: userId, name: name, age: age, petImage: petImage, tag: tag)
            docRef.setData(pet.dictionray) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(pet))
                }
            }
            return Disposables.create()
        }
    }
    
    func findPetList(userId: String) -> Single<[Pet]> {
        return Single.create { single in
            self.db.collection("pet").whereField("userId", isEqualTo: userId).getDocuments { querySnapshot, error in
                if let error = error {
                    single(.failure(error))
                } else {
                    var petList: [Pet] = []
                    print(querySnapshot!.documents)
                    for i in querySnapshot!.documents {
                        if let pet = Pet(dictionary: i.data()) {
                            petList.append(pet)
                        }
                    }
                    single(.success(petList))
                }
            }
            return Disposables.create()
        }
    }
}
