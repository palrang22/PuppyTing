//
//  AppDelegate.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import UserNotifications
import UIKit

import FirebaseAuth
import FirebaseCore
import FirebaseDynamicLinks
import FirebaseMessaging
import GoogleSignIn
import KakaoMapsSDK
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //kakao
        SDKInitializer.InitSDK(appKey: "2be397d1ad8fcbf7a9d93e68c3f268b1")
        
        FirebaseApp.configure()
        
//        //알림 메서드 - ksh
//        UNUserNotificationCenter.current().delegate = self
//        
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(
//        options: authOptions, completionHandler: {_, _ in }
//        )
//        
//        application.registerForRemoteNotifications()
//        Messaging.messaging().delegate = self
        
        return true
    }
    
    // Google 인증 프로세스가 종료되었을 때 앱이 수신하는 URL 을 처리하는 역할
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        
        // 딥링크 관련 코드 사용 안함
//        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url), let deepLinkURL = dynamicLink.url {
//            handleDeepLink(deepLinkURL: deepLinkURL)  // Deep Link 처리
//            return true
//        } else {
//            return false
//        }
        return false
    }
    
//    func handleDeepLink(deepLinkURL: URL) {
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
//                        print("Email verified successfully.")
//                    }
//                }
//            }
//        } else {
//            print("Required query parameters (oobCode, mode) not found.")
//        }
//    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

//// MARK: 알림 Extension - ksh
//extension AppDelegate: UNUserNotificationCenterDelegate {
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//        print("Apple token: \(token)")
//
//        Messaging.messaging().apnsToken = deviceToken
//    }
//        
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Failed to register for remote notifications: \(error.localizedDescription)")
//    }
//        
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.banner, .sound, .badge])
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        completionHandler()
//    }
//        
//    func checkToken() {
//        Messaging.messaging().token { token, error in
//            if let error = error {
//                print("Error fetching FCM registration token: \(error)")
//            } else if let token = token {
//                print("FCM registration token: \(token)")
//            }
//        }
//    }
//}
//
//extension AppDelegate: MessagingDelegate {
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        guard let fcmToken = fcmToken else { return }
//        print("FCM 토큰: \(fcmToken)")
//        
//        // FCM 토큰을 사용자 DB에 저장
//        if let userId = Auth.auth().currentUser?.uid {
//            FirebaseRealtimeDatabaseManager.shared.saveFCMToken(userId: userId, fcmToken: fcmToken)
//                .subscribe(onSuccess: {
//                    print("FCM 토큰 저장 성공")
//                }, onFailure: { error in
//                    print("FCM 토큰 저장 실패: \(error.localizedDescription)")
//                })
//                .disposed(by: disposeBag)
//        }
//        
//        let dataDict: [String: String] = ["token": fcmToken]
//        NotificationCenter.default.post(
//            name: Notification.Name("FCMToken"),
//            object: nil,
//            userInfo: dataDict
//        )
//    }
//}
