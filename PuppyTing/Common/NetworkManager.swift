//
//  NetworkManager.swift
//  PuppyTing
//
//  Created by 김승희 on 9/1/24.
//
import Foundation
import UIKit

import RxSwift

enum NetworkError: Error {
    case invalidUrl
    case dataFetchFail
    case decodingFail
}

// 싱글톤으로 NetworkManager 선언
class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // Success, Failure 중 단 하나만 뱉는 Single T 타입을 리턴
    func fetch<T:Decodable>(request: URLRequest) -> Single<T> {
        return Single.create { observer in
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: request) {data, response, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else {
                    observer(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                // 오류가 없다면 data를 json으로 받아올 수 있는 상황
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    // 데이터를 잘 받아왔고,
                    // 디코딩이 잘 되었다면 디코딩된 데이터는 마침내 T타입의 데이터가 되어 Single에 Success로 방출
                    observer(.success(decodedData))
                } catch {
                    observer(.failure(NetworkError.decodingFail))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
    
//    func loadImageFromURL(urlString: String) -> Single<UIImage?> {
//        return Single.create { single in
//            guard let url = URL(string: urlString) else {
//                single(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
//                return Disposables.create()
//            }
//
//            // URLSession을 사용하여 비동기로 이미지 다운로드
//            let task = URLSession.shared.dataTask(with: url) { data, response, error in
//                if let error = error {
//                    single(.failure(error))
//                } else if let data = data, let image = UIImage(data: data) {
//                    single(.success(image))
//                } else {
//                    single(.success(nil))
//                }
//            }
//            task.resume()
//
//            return Disposables.create {
//                task.cancel()
//            }
//        }
//    }
//    
//    func fetchImage(url: String, completion: @escaping (UIImage) -> Void) {
//        guard let url = URL(string: url) else {
//            print("noImage")
//            let image = UIImage(named: "defaultProfileImage")
//            if let image = image {
//                print("test")
//                completion(image)
//            } else {
//                completion(UIImage())
//            }
//            return
//        }
//
//        // URLSession을 사용하여 비동기로 이미지 다운로드
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("error \(error)")
//                let image = UIImage(named: "defaultProfileImage")
//                if let image = image {
//                    print("test")
//                    completion(image)
//                } else {
//                    completion(UIImage())
//                }
//            } else if let data = data, let image = UIImage(data: data) {
//                completion(image)
//            } else {
//                print("error")
//            }
//        }
//        task.resume()
//    }
}
