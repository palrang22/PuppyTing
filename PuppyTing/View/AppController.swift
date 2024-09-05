//
//  AppController.swift
//  PuppyTing
//
//  Created by 박승환 on 9/5/24.
//

import Foundation
import UIKit

import FirebaseAuth
import FirebaseCore

final class AppController {
    static let shared = AppController()
    
    private init() {
        FirebaseApp.configure()
        registerAuthStateDidChangeEvent()
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
        
        if Auth.auth().currentUser == nil {
            routeToLogin()
        }
    }
    
    private func registerAuthStateDidChangeEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(checkLogin), name: .AuthStateDidChange, object: nil)
    }
    
    @objc
    private func checkLogin() {
        if let user = Auth.auth().currentUser {
            print("user = \(user.email)")
            if user.isEmailVerified {
                setHome()
            } else {
                routeToLogin()
            }
        } else {
            routeToLogin()
        }
    }
    
    private func setHome() {
        let homeVC = TabBarController()
        rootViewController = homeVC
    }
    
    private func routeToLogin() {
        rootViewController = UINavigationController(rootViewController: LoginViewController())
    }
    
}
