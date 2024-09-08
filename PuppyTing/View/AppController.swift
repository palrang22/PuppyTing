//
//  AppController.swift
//  PuppyTing
//
//  Created by 박승환 on 9/5/24.
//

import Foundation
import UIKit

import FirebaseAuth
import FirebaseAuthInternal
import FirebaseCore

final class AppController {
    static let shared = AppController()
    
    var isPasswordUpdating = false
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        FirebaseApp.configure()
    }
    
    private var window: UIWindow!
    
    private var rootViewController: UIViewController? {
        didSet {
            window.rootViewController = rootViewController
        }
    }
    
    func show(in window: UIWindow) {
        self.window = window
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
        
        checkLoginStatus()
        removeAuthStateListener()
    }
    
    private func checkLoginStatus() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                if user.isEmailVerified {
                    self.setHome()
                } else {
                    self.routeToLogin()
                }
            } else {
                self.routeToLogin()
            }
        }
    }
    
    private func removeAuthStateListener() {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func setHome() {
        let homeVC = TabBarController()
        rootViewController = homeVC
    }
    
    private func routeToLogin() {
        rootViewController = UINavigationController(rootViewController: LoginViewController())
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            routeToLogin()
        } catch {
            print("로그아웃 실패")
        }
    }
    
}
