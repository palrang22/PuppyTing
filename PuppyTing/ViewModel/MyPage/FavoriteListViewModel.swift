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
            
            // 각 유저의 정보를 가져오는 Observable 배열 생성
            let favoriteObservables = bookmarkUserIds.map { userId in
                return Observable<DocumentSnapshot>.create { observer in
                    self.db.collection("member").document(userId).getDocument { (userDoc, error) in
                        if let error = error {
                            observer.onError(error)
                        } else if let userDoc = userDoc {
                            observer.onNext(userDoc)
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
                .map { userDoc -> Favorite? in
                    guard let userData = userDoc.data() else { return nil }
                    return Favorite(data: userData)
                }
            }
            
            // 모든 Observable의 결과를 병합
            Observable.combineLatest(favoriteObservables)
                .map { favorites in
                    favorites.compactMap { $0 } // [Favorite?]를 [Favorite]로 변환
                }
                .bind(to: self.favorites)
                .disposed(by: self.disposeBag)
        }
    }
}
