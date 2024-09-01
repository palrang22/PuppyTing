//
//  KakaoSearchManager.swift
//  PuppyTing
//
//  Created by 김승희 on 9/1/24.
//

import Foundation

import RxSwift

class NetworkManager {
    private let apiKey: String
    private let session: URLSession
    
    init(apiKey: String, session: URLSession) {
        self.apiKey = apiKey
        self.session = URLSession.shared
    }
    
    func searchPlace(keyword: String) -> Observable<[Place]> {
        return Observable.create { observer in
            let searchKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "https://dapi.kakao.com/v2/local/search/keyword.json?query=\(searchKeyword)"
            guard let url = URL(string: urlString) else {
                observer.onError(<#T##error: any Error##any Error#>)
            }
        }
    }
}
