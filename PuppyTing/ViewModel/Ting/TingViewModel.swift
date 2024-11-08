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
    private let apiKey = Bundle.main.infoDictionary?["KAKAO_REST_KEY"] as? String
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
            return
        }
        
        guard let request = createSearchUrl(keyword: keyword, location: location) else {
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
        
        guard let url = components?.url, let apiKey = apiKey else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }
        
    // 피드를 불러오는 메서드
    func fetchFeed(collection: String, userId: String, limit: Int, lastDocument: DocumentSnapshot?) -> Observable<([TingFeedModel], DocumentSnapshot?, Bool)> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else {
                observer.onError(NSError(domain: "Self is nil", code: -1, userInfo: nil))
                return Disposables.create()
            }
            
            let membersDocRef = strongSelf.db.collection("member").document(userId)
            
            // 사용자의 차단 목록을 먼저 가져오기 (필요할 경우)
            membersDocRef.getDocument { documentSnapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                if let blockedUsers = documentSnapshot?.data()?["blockedUsers"] as? [String] {
                    var query: Query = strongSelf.db.collection(collection)
                        .order(by: "timestamp", descending: true)
                        .limit(to: limit)
                    
                    // 마지막 문서가 있을 경우 해당 문서 이후로 데이터를 가져옴
                    if let lastDoc = lastDocument {
                        query = query.start(afterDocument: lastDoc)
                    }
                    
                    // Firestore에서 쿼리 실행
                    query.getDocuments { querySnapshot, error in
                        if let error = error {
                            observer.onError(error)
                        } else {
                            guard let snapshot = querySnapshot else {
                                observer.onNext(([], nil, false))
                                return
                            }
                            
                            var dataList: [TingFeedModel] = []
                            for document in snapshot.documents {
                                let data = document.data()
                                if let userid = data["userid"] as? String,
                                   !blockedUsers.contains(userid),
                                   let geoPoint = data["location"] as? GeoPoint,
                                   let content = data["content"] as? String,
                                   let timestamp = data["timestamp"] as? Timestamp,
                                   let photoUrl = data["photoUrl"] as? [String] {
                                    
                                    let location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                                    let time = timestamp.dateValue()
                                    let postid = document.documentID
                                    let tingFeed = TingFeedModel(userid: userid, postid: postid, location: location, content: content, time: time, photoUrl: photoUrl)
                                    dataList.append(tingFeed)
                                }
                            }
                            
                            let lastDocument = snapshot.documents.last
                            let hasMore = snapshot.documents.count >= limit
                            observer.onNext((dataList, lastDocument, hasMore))
                        }
                    }
                } else {
                    observer.onNext(([], nil, false))
                }
            }
            
            return Disposables.create()
        }
    }

}
