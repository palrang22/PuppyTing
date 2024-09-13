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
            
            // 여러 유저의 정보를 가져오기 위해 DispatchGroup 사용
            var favoriteList = [Favorite]()
            let dispatchGroup = DispatchGroup()
            
            bookmarkUserIds.forEach { userId in
                dispatchGroup.enter()
                self.db.collection("member").document(userId).getDocument { (userDoc, error) in
                    if let userData = userDoc?.data() {
                        let favorite = Favorite(data: userData)
                        favoriteList.append(favorite)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.favorites.onNext(favoriteList)
            }
        }
    }
}
