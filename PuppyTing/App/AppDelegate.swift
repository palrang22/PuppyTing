//
//  AppDelegate.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import UIKit

import FirebaseAuth
import FirebaseCore
import FirebaseDynamicLinks
import GoogleSignIn
import KakaoMapsSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //kakao
        SDKInitializer.InitSDK(appKey: "2be397d1ad8fcbf7a9d93e68c3f268b1")
        return true
    }
    
    // Google 인증 프로세스가 종료되었을 때 앱이 수신하는 URL 을 처리하는 역할
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("aaa")
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url), let deepLinkURL = dynamicLink.url {
            handleDeepLink(url: deepLinkURL)
            return true
        }
        return false
    }
    
    func handleDeepLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return }
        print("aa")
        if let oobCode = queryItems.first(where: { $0.name == "oobCode" })?.value {
            Auth.auth().applyActionCode(oobCode) { error in
                if let error = error {
                    print("error")
                } else {
                    print("이메일 인증 성공")
                }
            }
        }
    }
    
    
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

