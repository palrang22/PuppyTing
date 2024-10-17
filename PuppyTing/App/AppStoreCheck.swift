//
//  AppStoreCheck.swift
//  PuppyTing
//
//  Created by 내꺼다 on 10/15/24.
//

import UIKit

class AppStoreCheck {
    
    // 현재 앱 버전
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    // 빌드 넘버
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    // 앱스토어 URL (앱스토어의 App ID 반영)
    static let appStoreOpenUrlString = "itms-apps://itunes.apple.com/app/apple-store/id6670602342"
    
    // 앱스토어 최신 정보 확인 (비동기 처리)
    func checkLatestVersion(completion: @escaping (String?) -> Void) {
        let appleID = "6670602342" // 여기에 App ID 적용
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appleID)&country=kr") else {
            completion(nil)
            return
        }
        
        // 비동기 네트워크 요청
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching app store version: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreVersion = results.first?["version"] as? String {
                    completion(appStoreVersion) // 최신 버전 반환
                } else {
                    completion(nil)
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume() // 네트워크 요청 시작
    }
    
    // 앱스토어로 이동
    func openAppStore() {
        guard let url = URL(string: AppStoreCheck.appStoreOpenUrlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

