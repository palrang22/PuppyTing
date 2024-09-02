//
//  TingViewModel.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//
import CoreLocation
import UIKit

import RxCocoa
import RxSwift

//MARK: 로직 수정예정
class TingViewModel {
    private let apiKey = Bundle.main.infoDictionary?["KAKAO_SEARCH_API"] as? String
    private let networkManager = NetworkManager.shared
    private let disposeBag = DisposeBag()
    private var currentLocation: CLLocation?
    
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
        print("검색어: \(keyword)")
        
        guard let request = createSearchUrl(keyword: keyword, location: location) else {
            print("URL 오류")
            return
        }
        print("생성된 요청: \(request)")
        
        networkManager.fetch(request: request)
            .observe(on: MainScheduler.instance)
            .map { (response: KakaoLocalSearchResponse) -> [Place] in
                return response.documents
            }
            .subscribe(
                onSuccess: { [weak self] places in
                    self?.items.accept(places)
                    print(places)
                    places.forEach { place in
                        print(place.placeName, place.roadAddressName)}
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
        print("API 키가 포함된 요청 헤더: \(request.allHTTPHeaderFields ?? [:])")
        return request
    }
}
