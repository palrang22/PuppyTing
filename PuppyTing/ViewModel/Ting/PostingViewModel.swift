//
//  PostingViewModel.swift
//  PuppyTing
//
//  Created by t2023-m0072 on 9/5/24.
//

import CoreLocation
import UIKit

import FirebaseFirestore
import RxSwift

class PostingViewModel {
    let db = Firestore.firestore()
    
    func create(collection: String, model: TingFeedModel) {
        let data: [String: Any] = [
                    "userid": model.userid,
                    "location": GeoPoint(latitude: model.location.latitude, longitude: model.location.longitude),
                    "content": model.content,
                    "timestamp": Timestamp()
                ]
                
        db.collection("tingFeeds").addDocument(data: data) { error in
            if let error = error {
                print("데이터 전송 실패")
            } else {
                print("데이터 전송 성공")
            }
        }
    }
}
