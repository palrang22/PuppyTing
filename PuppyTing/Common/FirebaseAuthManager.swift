//
//  FirebaseAuthManager.swift
//  PuppyTing
//
//  Created by 박승환 on 8/29/24.
//

import Foundation
import UIKit

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import RxSwift

enum AuthError: Error {
    case CreateFailError
    case SendEmailFailError
    case SignInFailError
    case EmailVerificationFailError
    case ClientIdInvaildError
    case GoogleSignInFailError
    case TokenInvaildError
}

class FirebaseAuthManager {
    
    static let shared = FirebaseAuthManager()
    
    private init() {
        
    }
    
    func emailSignUp(email: String, pw: String) -> Single<User> {
        return Single<User>.create { [weak self] single in
            Auth.auth().createUser(withEmail: email, password: pw) { result, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let result = result else {
                    single(.failure(AuthError.CreateFailError))
                    return
                }
                
                if !result.user.isEmailVerified {
                    Auth.auth().currentUser?.sendEmailVerification { error in
                        if let error = error {
                            single(.failure(AuthError.SendEmailFailError))
                            return
                        } else {
                            print("이메일 전송 성공")
                            single(.success(result.user))
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func emailSignIn(email: String, pw: String) -> Single<User> {
        return Single<User>.create { [weak self] single in
            Auth.auth().signIn(withEmail: email, password: pw) { [weak self] result, error in
                if let error = error {
                    print("에러 발생: \(error)")
                    single(.failure(AuthError.SignInFailError))
                }
                if let result = result {
                    if result.user.isEmailVerified {
                        single(.success(result.user))
                    } else {
                        single(.failure(AuthError.EmailVerificationFailError))
                    }
                } else {
                    single(.failure(AuthError.SignInFailError))
                }
            }
            return Disposables.create()
        }
    }
    
    func googleSignIn(viewController: UIViewController) -> Single<User> {
        return Single<User>.create { [weak self] single in
            guard let clientId = FirebaseApp.app()?.options.clientID else { 
                single(.failure(AuthError.ClientIdInvaildError))
                return Disposables.create()
            }
            let config = GIDConfiguration(clientID: clientId)
            GIDSignIn.sharedInstance.configuration = config
            
            GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [unowned self] result, error in
                guard error == nil else {
                    print("test1: \(String(describing: error))")
                    single(.failure(AuthError.GoogleSignInFailError))
                    return
                }
                
                guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                    single(.failure(AuthError.TokenInvaildError))
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                
                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        print("test2")
                        single(.failure(AuthError.GoogleSignInFailError))
                    }
                    if let result = result {
                        single(.success(result.user))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
}
