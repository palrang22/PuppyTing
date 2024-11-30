//
//  PostingViewModel.swift
//  PuppyTing
//
//  Created by t2023-m0072 on 9/5/24.
//

import CoreLocation
import UIKit

import FirebaseFirestore
import FirebaseStorage
import RxSwift

class PostingViewModel {
    static let shared = PostingViewModel()
    let db = Firestore.firestore()
    
    func create(collection: String, model: TingFeedModel) -> Completable {
        return Completable.create { completable in
            let data: [String: Any] = [
                "userid": model.userid,
                "location": GeoPoint(latitude: model.location.latitude, longitude: model.location.longitude),
                "content": model.content,
                "timestamp": Timestamp(),
                "photoUrl": model.photoUrl
            ]
            
            self.db.collection("tingFeeds").addDocument(data: data) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func edit(collection: String, documentId: String, model: TingFeedModel) -> Completable {
        return Completable.create { completable in
            let data: [String: Any] = [
                "userid": model.userid,
                "location": GeoPoint(latitude: model.location.latitude, longitude: model.location.longitude),
                "content": model.content,
                "timestamp": Timestamp(),
                "photoUrl": model.photoUrl
            ]
            
            self.db.collection("tingFeeds").document(documentId).updateData(data) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func uploadImages(images: [UIImage]) -> Single<[String]> {
        return Single.create { single in
            var photoUrl = [String]()
            let dispatchGroup = DispatchGroup()
            
            for image in images {
                guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
                let imageName = UUID().uuidString
                let storageRef = Storage.storage().reference().child("images/\(imageName).jpg")
                
                dispatchGroup.enter()
                storageRef.putData(imageData, metadata: nil) { _, error in
                    guard error == nil else {
                        dispatchGroup.leave()
                        return
                    }
                    storageRef.downloadURL { url, error in
                        if let url = url {
                            photoUrl.append(url.absoluteString)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                single(.success(photoUrl))
            }
            return Disposables.create()
        }
    }
}
