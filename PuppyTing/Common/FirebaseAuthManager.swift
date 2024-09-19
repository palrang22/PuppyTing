//
//  FirebaseAuthManager.swift
//  PuppyTing
//
//  Created by 박승환 on 8/29/24.
//

import AuthenticationServices
import CryptoKit
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
    case ClientIdinvalidError
    case GoogleSignInFailError
    case TokeninvalidError
    case InvalidCredential // 이메일이나 비밀번호가 틀린지 정확히 알려주지 않기 위해서 유효하지 않은 자격증명 이라는 오류를 반환한다. - 이곳에는 이메일이 잘못되거나 형식에 맞지 않는 경우, 비밀번호가 틀렸을 경우, 사용자가 제공한 인증 토큰이나 자격 증명이 만료되거나 유효하지 않은 경우, 등등 많은 이유를 포함한다.
    case invalidEmailError
}

class FirebaseAuthManager {
    
    static let shared = FirebaseAuthManager()
    
    private var currentNonce: String?
    
    private init() {
        
    }
    
    func startAppleSignIn() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }
    
    func emailSignUp(email: String, pw: String) -> Single<User> {
        return Single<User>.create { single in
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
                        if error != nil {
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
        return Single<User>.create { single in
            Auth.auth().signIn(withEmail: email, password: pw) { result, error in
                if let error = error as NSError? {
                    if let errorCode = AuthErrorCode(rawValue: error.code) {
                        switch errorCode {
                        case .invalidCredential:
                            single(.failure(AuthError.InvalidCredential))
                        default:
                            single(.failure(error))
                        }
                    } else {
                        single(.failure(error))
                    }
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
        return Single<User>.create { single in
            guard let clientId = FirebaseApp.app()?.options.clientID else { 
                single(.failure(AuthError.ClientIdinvalidError))
                return Disposables.create()
            }
            let config = GIDConfiguration(clientID: clientId)
            GIDSignIn.sharedInstance.configuration = config
            
            GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
                guard error == nil else {
                    print("test1: \(String(describing: error))")
                    single(.failure(AuthError.GoogleSignInFailError))
                    return
                }
                
                guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                    single(.failure(AuthError.TokeninvalidError))
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                
                Auth.auth().signIn(with: credential) { result, error in
                    if error != nil {
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
    
    func appleSignIn(credential: ASAuthorizationAppleIDCredential) -> Single<User> {
        return Single.create { single in
            
            guard let nonce = self.currentNonce else {
                single(.failure(AuthError.CreateFailError))
                return Disposables.create()
            }
            
            guard let appleIdToken = credential.identityToken, let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
                single(.failure(AuthError.TokeninvalidError))
                return Disposables.create()
            }
            
            let appleCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            Auth.auth().signIn(with: appleCredential) { result, error in
                if let error = error {
                    single(.failure(error))
                } else if let result = result {
                    single(.success(result.user))
                } else {
                    single(.failure(AuthError.SignInFailError))
                }
            }
            return Disposables.create()
        }
    }
    
    func passwordReset(email: String) -> Single<Bool> {
        return Single.create { single in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error as NSError? {
                    if let errorCode = AuthErrorCode(rawValue: error.code) {
                        switch errorCode {
                        case .userNotFound:
                            single(.failure(AuthError.invalidEmailError))
                        default:
                            single(.failure(error))
                        }
                    } else {
                        single(.failure(error))
                    }
                } else {
                    single(.success(true))
                }
            }
            return Disposables.create()
        }
    }
    
    // 사용자 재인증 후 가능하도록 실행
    func passwordUpdate(oldPassword: String, newPassword: String) -> Single<Bool> {
        
        return Single.create { single in
            if let user = Auth.auth().currentUser {
                var email = ""
                if let currentEmail = user.email {
                    email = currentEmail
                }
                let password = oldPassword
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                user.reauthenticate(with: credential) { result, error in
                    if let error = error {
                        single(.failure(error))
                    } else {
                        user.updatePassword(to: newPassword) { error in
                            if let error = error {
                                single(.failure(error))
                            } else {
                                single(.success(true))
                            }
                        }
                    }
                }
            } else {
                single(.success(false))
            }
            return Disposables.create()
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
    
}
