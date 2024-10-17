//
//  AppStoreCheck.swift
//  PuppyTing
//
//  Created by 내꺼다 on 10/16/24.
//


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





//
//  SceneDelegate.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        AppController.shared.show(in: window)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    // 앱이 포그라운드로 돌아올 때 호출됨 - jgh
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        checkForUpdate()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // 앱 버전 업데이트 확인 메서드 - jgh
    private func checkForUpdate() {
        let appStoreCheck = AppStoreCheck()
        
        // 앱스토어 최신 버전 확인
        appStoreCheck.checkLatestVersion { appStoreVersion in
            guard let appStoreVersion = appStoreVersion else { return }
            
            // 현재 버전과 비교
            if let currentVersion = AppStoreCheck.appVersion, currentVersion.compare(appStoreVersion, options: .numeric) == .orderedAscending {
                // 최신 버전이 현재 버전보다 클 경우 업데이트 유도
                DispatchQueue.main.async {
                    self.promptForUpdate()
                }
            }
        }
    }
    
    // 업데이트 유도 알림
    private func promptForUpdate() {
        guard let window = self.window, let rootVC = window.rootViewController else { return }
        
        let alert = UIAlertController(title: "업데이트 필요", message: "새로운 버전의 퍼피팅으로 업데이트를 진행해 주세요.", preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "업데이트", style: .default) { _ in
            AppStoreCheck().openAppStore() // 앱스토어로 이동
        }
        let cancleAction = UIAlertAction(title: "나중에", style: .cancel, handler: nil)
        
        alert.addAction(updateAction)
        alert.addAction(cancleAction)
        
        rootVC.present(alert, animated: true, completion: nil)
    }
    
}


