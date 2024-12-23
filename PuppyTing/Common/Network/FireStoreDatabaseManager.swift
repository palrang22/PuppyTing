//
//  FireStoreDatabaseManager.swift
//  PuppyTing
//
//  Created by 박승환 on 8/29/24.
//

import Foundation

import CoreLocation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import RxSwift


class FireStoreDatabaseManager {
    
    static let shared = FireStoreDatabaseManager()
    
    private let db = Firestore.firestore()
    private let disposeBag = DisposeBag() // kkh
    
    private init() {}
    
    //MARK: CREATE
    
    func emailSignUp(uuid: String, email: String, pw: String, nickname: String) -> Single<Member> {
        return Single.create { [weak self] single in
            let member = Member(uuid: uuid, email: email, password: pw, nickname: nickname, profileImage: "defaultProfileImage", footPrint: 0, isSocial: false)
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
            docRef.updateData(["nickname": member.nickname, "profileImage": member.profileImage]) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(true))
                }
            }
            return Disposables.create()
        }
    }
    
    func updatePassword(uuid: String, password: String) -> Single<Bool> {
        return Single.create { single in
            let docRef = self.db.collection("member").document(uuid)
            docRef.updateData(["password": password]) { error in
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
    
    func blockUser(userId: String) -> Single<Void> {
        guard let currentUser = Auth.auth().currentUser?.uid else {
            return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 인증 실패"]))
        }
        
        return Single.create { [weak self] single in
            let ref = self?.db.collection("member").document(currentUser)
            ref?.updateData(["blockedUsers": FieldValue.arrayUnion([userId])]) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    func getBlockedUsers(uuid: String, complection: @escaping ([String]) -> Void) {
        let ref = db.collection("member").document(uuid)
        ref.getDocument { document, error in
            if let document = document, let data = document.data(), let blockedUsers = data["blockedUsers"] as? [String] {
                complection(blockedUsers)
            }
        }
    }
    
    func getBlockedUsers() -> Single<[Member]> { // kkh
        guard let currentUser = Auth.auth().currentUser?.uid else {
            return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 인증 실패"]))
        }
        
        return Single.create { [weak self] single in
            let ref = self?.db.collection("member").document(currentUser)
            ref?.getDocument { document, error in
                if let error = error {
                    print("Firestore에서 차단 목록 가져오기 실패: \(error)")
                    single(.failure(error))
                } else if let document = document, let data = document.data(), let blockedUsers = data["blockedUsers"] as? [String] {
                    print("차단된 사용자 목록: \(blockedUsers)")
                    var members: [Member] = []
                    let group = DispatchGroup()
                    
                    for userId in blockedUsers {
                        group.enter()
                        self?.findMemeber(uuid: userId).subscribe(onSuccess: { member in
                            members.append(member)
                            group.leave()
                        }, onFailure: { _ in
                            group.leave()
                        }).disposed(by: self?.disposeBag ?? DisposeBag())
                    }
                    
                    group.notify(queue: .main) {
                        single(.success(members))
                    }
                } else {
                    print("차단된 사용자 목록을 가져오지 못했습니다.")
                    single(.success([]))
                }
            }
            return Disposables.create()
        }
    }
    
    func unblockUser(userId: String) -> Single<Void> { // kkh
        guard let currentUser = Auth.auth().currentUser?.uid else {
            return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 인증 실패"]))
        }
        
        return Single.create { [weak self] single in
            let ref = self?.db.collection("member").document(currentUser)
            ref?.updateData(["blockedUsers": FieldValue.arrayRemove([userId])]) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchFeeds(forUserId userId: String) -> Single<[TingFeedModel]> { // kkh
        return Single.create { [weak self] single in
            self?.db.collection("tingFeeds")
                .whereField("userid", isEqualTo: userId) // userid로 필터링
                .getDocuments { snapshot, error in
                    if let error = error {
                        single(.failure(error))
                    } else {
                        var feeds: [TingFeedModel] = []
                        
                        snapshot?.documents.forEach { document in
                            let data = document.data()
                            if let content = data["content"] as? String,
                               let timestamp = data["timestamp"] as? Timestamp {
                                
                                let feed = TingFeedModel(
                                    userid: userId,
                                    postid: document.documentID,
                                    location: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                    content: content,
                                    time: timestamp.dateValue()
                                )
                                
                                feeds.append(feed)
                            }
                        }
                        
                        single(.success(feeds))
                    }
                }
            return Disposables.create()
        }
    }
    
    func reportPost(report: Report) -> Single<Void> {
        return Single.create { [weak self] single in
            self?.db.collection("report").addDocument(data: report.dictionary) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    // 즐겨찾기 추가 메서드 - jgh
    func addBookmark(forUserId userId: String, bookmarkId: String) -> Single<Void> {
        guard let currentUser = Auth.auth().currentUser?.uid else {
            return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 인증 실패"]))
        }
        
        return Single.create { [weak self] single in
            let ref = self?.db.collection("member").document(currentUser)
            ref?.updateData(["bookMarkUsers": FieldValue.arrayUnion([bookmarkId])]) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    // 즐겨찾기 해제 메서드 - jgh
    func removeBookmark(forUserId userId: String, bookmarkId: String) -> Single<Void> {
        guard let currentUser = Auth.auth().currentUser?.uid else {
            return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 인증 실패"]))
        }
        
        return Single.create { [weak self] single in
            let ref = self?.db.collection("member").document(currentUser)
            ref?.updateData(["bookMarkUsers": FieldValue.arrayRemove([bookmarkId])]) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    // 즐겨찾기 목록 가져오는 메서드 - jgh
    func fetchUserBookmarks(forUserId userId: String) -> Single<[String]> {
        return Single.create { [weak self] single in
            let ref = self?.db.collection("member").document(userId)
            ref?.getDocument { document, error in
                if let error = error {
                    single(.failure(error))
                } else if let document = document, document.exists, let data = document.data() {
                    let bookmarks = data["bookMarkUsers"] as? [String] ?? []
                    single(.success(bookmarks))
                } else {
                    single(.success([]))
                }
            }
            return Disposables.create()
        }
    }
    
    //MARK: Read
    
    func checkUserData(user: User, completion: @escaping (Bool) -> Void) {
        let docRef = db.collection("member").document(user.uid)
        
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func checkUserData(uuid: String, completion: @escaping (Bool) -> Void) {
        let docRef = db.collection("member").document(uuid)
        
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func findMember(uuid: String, completion: @escaping (Member) -> Void) {
        var member: Member? = nil
        let docRef = db.collection("member").document(uuid)
        docRef.getDocument { result, error in
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
    
    func findMember(uuid: String) -> Member? {
        var member: Member? = nil
        let docRef = db.collection("member").document(uuid)
        docRef.getDocument { result, error in
            if let result = result, result.exists, let data = result.data() {
                if let dataMember = Member(dictionary: data) {
                    member = dataMember
                }
            }
        }
        return member
    }
    
    func findMemberNickname(uuid: String, completion: @escaping (String) -> Void) {
        var nickName = "알 수 없는 사용자"
        let docRef = db.collection("member").document(uuid)
        docRef.getDocument { result, error in
            if let result = result, result.exists, let data = result.data() {
                if let member = Member(dictionary: data) {
                    nickName = member.nickname
                }
            }
            completion(nickName)
        }
    }
    
    // MARK: - 유저정보로 강아지 정보 가져오기 메서드
    
    // 특정 사용자의 강아지 정보를 userId로 가져오는 메서드
        func fetchPetsByUserId(userId: String) -> Single<[Pet]> {
            return Single.create { [weak self] single in
                // Pet 컬렉션에서 userId가 해당 사용자의 uuid와 일치하는 문서들을 검색
                self?.db.collection("pet")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            single(.failure(error))
                        } else if let documents = snapshot?.documents {
                            let pets = documents.compactMap { Pet(dictionary: $0.data()) }
                            single(.success(pets))
                        } else {
                            single(.success([])) // 강아지 정보가 없는 경우 빈 배열 반환
                        }
                    }
                return Disposables.create()
            }
        }
    
    //MARK: UPDATE
    
    func addFootPrint(toUserId: String) -> Single<Void> {
        return Single.create { [weak self] single in
            let ref = self?.db.collection("member").document(toUserId)
            
            ref?.updateData(["footPrint": FieldValue.increment(Int64(1))]) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    //MARK: DELETE
    
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
    
    func deleteFeed(withId feedId: String, completion: @escaping (Error?) -> Void) { // kkh
        deleteDocument(from: "tingFeeds", documentId: feedId)
            .subscribe(onSuccess: {
                completion(nil) // 삭제 성공 시 nil 반환
            }, onFailure: { error in
                completion(error)
            })
            .disposed(by: disposeBag)
        
    }
}
