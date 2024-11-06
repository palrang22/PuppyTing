//
//  FeedListViewModel.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/23/24.
//

import CoreLocation
import Foundation

import FirebaseFirestore
import RxSwift

class FeedListViewModel {
    let disposeBag = DisposeBag()

    // 피드 데이터를 담는 BehaviorSubject
    let feedsSubject = BehaviorSubject<[TingFeedModel]>(value: [])

    // 파이어베이스에서 피드 데이터를 가져오는 메서드
    func fetchFeeds(forUserId userId: String) {
        Firestore.firestore().collection("tingFeeds")
            .whereField("userid", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching feeds: \(error.localizedDescription)")
                    self?.feedsSubject.onError(error)
                } else {
                    var feeds: [TingFeedModel] = []
                    snapshot?.documents.forEach { document in
                        let data = document.data()
                        if let geoPoint = data["location"] as? GeoPoint, // jgh
                            let content = data["content"] as? String,
                           let timestamp = data["timestamp"] as? Timestamp {
                            
                            let feed = TingFeedModel(
                                userid: userId,
                                postid: document.documentID,
                                location: CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude), // jgh
                                content: content,
                                time: timestamp.dateValue()
                            )
                            
                            feeds.append(feed)
                        }
                    }
                    // BehaviorSubject에 피드 데이터를 전달
                    self?.feedsSubject.onNext(feeds)
                }
            }
    }
}
