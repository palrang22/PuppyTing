//
//  FavoriteListViewModel.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/13/24.
//

import UIKit

import FirebaseAuth
import FirebaseFirestore
import RxSwift

class FavoriteListViewModel {
    
    private let db = Firestore.firestore()
    private let disposeBag = DisposeBag()
    
    // 즐겨찾기 목록을 저장할 Observable
    let favorites = PublishSubject<[Favorite]>()
    
    // 즐겨찾기 추가 성공과 오류를 처리할 Observable
    let bookmarkSuccess = PublishSubject<Void>()
    let bookmarkError = PublishSubject<Error>()
    
    // 즐겨찾기 삭제
    func removeBookmark(bookmarkId: String) -> Single<Void> {
        guard let userId = Auth.auth().currentUser?.uid else {
            return Single.error(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "현재 사용자 정보가 없습니다."]))
        }
        
        return FireStoreDatabaseManager.shared.removeBookmark(forUserId: userId, bookmarkId: bookmarkId)
            .observe(on: MainScheduler.instance)
    }
    
    // 즐겨찾기 목록 불러오기
    func fetchFavorites() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        
        let memberRef = db.collection("member").document(currentUser)
        
        memberRef.getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists,
                  let data = document.data(), let bookmarkUserIds = data["bookMarkUsers"] as? [String] else {
                print("즐겨찾기 목록 불러오기 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                return
            }
            
            // Observable.create로 Firestore의 비동기 작업을 감싸고, zip을 사용하여 모든 즐겨찾기 유저 정보를 한 번에 처리
            // Firestore에서 유저 정보 불러오기
            let favoriteObservables = bookmarkUserIds.map { userId in
                return Observable<Favorite>.create { observer in
                    self.db.collection("member").document(userId).getDocument { (userDoc, error) in
                        if let userData = userDoc?.data() {
                            let favorite = Favorite(data: userData)
                            observer.onNext(favorite)
                        } else if let error = error {
                            observer.onError(error)
                        }
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            
            // 모든 유저 정보가 불러와질 때까지 기다리기
            Observable.zip(favoriteObservables)
                .subscribe(onNext: { favoriteList in
                    self.favorites.onNext(favoriteList)
                }, onError: { error in
                    print("즐겨찾기 목록 불러오기 실패: \(error.localizedDescription)")
                })
                .disposed(by: self.disposeBag)
        }
    }
}
