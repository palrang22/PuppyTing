//
//  TingViewModel.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//
import CoreLocation
import UIKit

import FirebaseFirestore
import RxCocoa
import RxSwift

//MARK: 로직 수정예정
class TingViewModel {
    private let apiKey = Bundle.main.infoDictionary?["KAKAO_SEARCH_API"] as? String
    private let networkManager = NetworkManager.shared
    private let disposeBag = DisposeBag()
    private var currentLocation: CLLocation?
    
    private let db = Firestore.firestore()
    var lastDocuments: DocumentSnapshot?
    
    let items = BehaviorRelay<[Place]>(value:[])
    let error = PublishRelay<String>()
    
    func updateLocation(location: CLLocation) {
        currentLocation = location
    }
    
    func searchPlaces(keyword: String) {
        guard let location = currentLocation else {
            print("현재위치 없음")
            return
        }
        
        guard let request = createSearchUrl(keyword: keyword, location: location) else {
            print("URL 오류")
            return
        }
        
        networkManager.fetch(request: request)
            .observe(on: MainScheduler.instance)
            .map { (response: KakaoLocalSearchResponse) -> [Place] in
                return response.documents
            }
            .subscribe(
                onSuccess: { [weak self] places in
                    self?.items.accept(places)
                },
                onFailure: { [weak self] fetchError in
                    self?.error.accept(fetchError.localizedDescription)
                    print("데이터 가져오기 실패: \(fetchError.localizedDescription)")
                }
            ).disposed(by: disposeBag)
    }
    
    func createSearchUrl(keyword: String, location: CLLocation) -> URLRequest? {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let radius = 1000
        
        var components = URLComponents(string: "https://dapi.kakao.com/v2/local/search/keyword.json")
        components?.queryItems = [
            URLQueryItem(name: "query", value: keyword),
            URLQueryItem(name: "y", value: "\(latitude)"),
            URLQueryItem(name: "x", value: "\(longitude)"),
            URLQueryItem(name: "radius", value: "\(radius)")
        ]
        
        guard let url = components?.url, let apiKey = apiKey else { return nil }
        var request = URLRequest(url: url)
        request.addValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // 데이터 전달 메서드
    func fetchFeed(collection: String, userId: String, limit: Int, lastDocument: DocumentSnapshot?) -> Single<([TingFeedModel], Bool)> {
        return Single.create { [weak self] single in
            var dataList: [TingFeedModel] = []
            
            guard let strongSelf = self else {
                single(.failure(NSError(domain: "Self is nil", code: -1, userInfo: nil)))
                return Disposables.create()
            }
            
            let membersDocRef = strongSelf.db.collection("member").document(userId)
            
            membersDocRef.getDocument { documentSnapshot, error in
                if let error = error {
                    print("fetch 오류: \(error)")
                    single(.failure(error))
                    return
                }
                
                if let blockedUsers = documentSnapshot?.data()?["blockedUsers"] as? [String] {
                    var query: Query = strongSelf.db.collection(collection)
                        .order(by: "timestamp", descending: true)
                        .limit(to: limit)
                    
                    if let lastDoc = lastDocument {
                        query = query.start(afterDocument: lastDoc)
                    }
                    
                    query.getDocuments(source: .server) { querySnapshot, error in
                        if let error = error {
                            print("Error fetching documents: \(error)")
                            single(.failure(error))
                        } else {
                            guard let snapshot = querySnapshot else {
                                single(.success(([], false)))
                                return
                            }
                            
                            for document in snapshot.documents {
                                let data = document.data()
                                if let userid = data["userid"] as? String,
                                   !blockedUsers.contains(userid),
                                   let geoPoint = data["location"] as? GeoPoint,
                                   let content = data["content"] as? String,
                                   let timestamp = data["timestamp"] as? Timestamp {
                                    
                                    let location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                                    let time = timestamp.dateValue()
                                    let postid = document.documentID
                                    
                                    let tingFeed = TingFeedModel(userid: userid, postid: postid, location: location, content: content, time: time)
                                    dataList.append(tingFeed)
                                }
                            }
                            self?.lastDocuments = snapshot.documents.last
                            
                            let hasMore = snapshot.documents.count >= limit
                            single(.success((dataList, hasMore)))
                        }
                    }
                } else {
                    print("blockedUsers 필드가 없습니다.")
                    single(.success(([], false)))
                }
            }
            
            return Disposables.create()
        }
    }
}
