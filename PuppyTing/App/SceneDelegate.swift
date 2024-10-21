//
//  SceneDelegate.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import UIKit

import FirebaseAuth
import FirebaseDynamicLinks
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        AppController.shared.show(in: window)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // NSUserActivity에서 webpageURL을 가져와서 Google Sign-In에 전달
        if let incomingURL = userActivity.webpageURL {
            if GIDSignIn.sharedInstance.handle(incomingURL) {
                return
            }
        }
    }

    
    // 딥링크 관련 코드 아직 사용 안함
    // AppDelegate 에서 처리를 할 필요가 없는건가..?
//    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
//        guard let incomingURL = userActivity.webpageURL else {
//            return
//        }
//        handleDeepLink(deepLinkURL: incomingURL)
//    }

//   func handleDeepLink(deepLinkURL: URL) {
//        // Deep Link URL에서 쿼리 파라미터 추출
//        guard let deepLinkComponents = URLComponents(url: deepLinkURL, resolvingAgainstBaseURL: false),
//              let deepLinkQueryItems = deepLinkComponents.queryItems else {
//            print("No query items in deep link URL")
//            return
//        }
//        
//        // 'oobCode'와 'mode' 파라미터를 추출
//        if let oobCode = deepLinkQueryItems.first(where: { $0.name == "oobCode" })?.value,
//           let mode = deepLinkQueryItems.first(where: { $0.name == "mode" })?.value {
//            
//            print("Mode: \(mode), oobCode: \(oobCode)") // 추출된 파라미터 출력
//
//            // 이메일 인증 처리
//            if mode == "verifyEmail" {
//                Auth.auth().applyActionCode(oobCode) { error in
//                    if let error = error {
//                        print("Error verifying email: \(error.localizedDescription)")
//                    } else {
//                        print("이메일 인증 완료")
//                        print("Email verified successfully.")
//                    }
//                }
//            }
//        } else {
//            print("Required query parameters (oobCode, mode) not found.")
//        }
//    }

    
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

