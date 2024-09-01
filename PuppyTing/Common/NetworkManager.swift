//
//  NetworkManager.swift
//  PuppyTing
//
//  Created by 김승희 on 9/1/24.
//
import Foundation

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
            
            print("URLSession 시작 - \(request)")
            
            session.dataTask(with: request) {data, response, error in
                if let error = error {
                    print("네트워크 에러 발생: \(error.localizedDescription)")
                    observer(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP 상태 코드: \(httpResponse.statusCode)")
                } else {
                    print("HTTP 응답이 없습니다.")
                    observer(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else {
                    print("데이터 가져오기 실패")
                    observer(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                print("서버로부터 수신한 데이터: \(String(data: data, encoding: .utf8) ?? "데이터를 문자열로 변환할 수 없음")")
                
                // 오류가 없다면 data를 json으로 받아올 수 있는 상황
                do {
                    print("디코딩 전 데이터: \(String(data: data, encoding: .utf8) ?? "데이터를 문자열로 변환할 수 없음")")
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    // 데이터를 잘 받아왔고,
                    // 디코딩이 잘 되었다면 디코딩된 데이터는 마침내 T타입의 데이터가 되어 Single에 Success로 방출
                    print("디코딩 성공: \(decodedData)")
                    observer(.success(decodedData))
                } catch {
                    print("디코딩 실패: \(error.localizedDescription)")
                    observer(.failure(NetworkError.decodingFail))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}
