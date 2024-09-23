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

class FirebaseAuthManager: NSObject, ASAuthorizationControllerDelegate {
    
    static let shared = FirebaseAuthManager()
    
    private var currentNonce: String?
    
    private override init() {
        
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
    
    // 승환파크
    func memberDelete() -> Single<Bool> {
        return Single.create { single in
            let user = Auth.auth().currentUser
            user?.delete(completion: { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(true))
                }
            })
            return Disposables.create()
        }
    }
    
    // Apple 계정 삭제에 필요한 자격 증명 생성
   func getAppleCredentials() -> Single<AuthCredential> {
       return Single<AuthCredential>.create { single in
           let provider = ASAuthorizationAppleIDProvider()
           let request = provider.createRequest()
           request.requestedScopes = [.fullName, .email]

           let authorizationController = ASAuthorizationController(authorizationRequests: [request])
           authorizationController.delegate = self
           authorizationController.performRequests()

           self.handleAppleSignIn = { idToken, authorizationCode, error in
               if let error = error {
                   single(.failure(error))
                   return
               }
               
               guard let idToken = idToken, let authorizationCode = authorizationCode else {
                   single(.failure(NSError(domain: "Apple ID 토큰 또는 Authorization Code를 가져올 수 없습니다.", code: -1, userInfo: nil)))
                   return
               }
               let nonce = self.currentNonce ?? ""
               let appleCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: nonce, accessToken: authorizationCode)
               single(.success(appleCredential))
           }

           return Disposables.create()
       }
   }

   // Apple 계정 삭제 처리
   func deleteUserWithApple(appleCredential: AuthCredential) -> Single<Bool> {
       return Single<Bool>.create { single in
           guard let user = Auth.auth().currentUser else {
               single(.failure(NSError(domain: "User is nil", code: -1, userInfo: nil)))
               return Disposables.create()
           }

           // 재인증 후 삭제 처리
           user.reauthenticate(with: appleCredential) { authResult, error in
               if let error = error {
                   single(.failure(error))
               } else {
                   user.delete { error in
                       if let error = error {
                           single(.failure(error))
                       } else {
                           single(.success(true))  // 삭제 성공 시
                       }
                   }
               }
           }

           return Disposables.create()
       }
   }

   // Google 자격 증명 가져오기
    func getGoogleCredentials(presentingViewController: UIViewController) -> Single<(idToken: String, accessToken: String)> {
        return Single<(idToken: String, accessToken: String)>.create { single in
            // 현재 로그인된 사용자가 있는지 확인
            if let currentUser = GIDSignIn.sharedInstance.currentUser {
                guard let idToken = currentUser.idToken?.tokenString else {
                    single(.failure(NSError(domain: "Google ID 토큰을 가져올 수 없습니다.", code: -1, userInfo: nil)))
                    return Disposables.create()
                }
                let accessToken = currentUser.accessToken.tokenString
                single(.success((idToken, accessToken)))
            } else {
                // 로그인된 사용자가 없을 경우, Google 로그인 시도
                guard let clientID = FirebaseApp.app()?.options.clientID else {
                    single(.failure(NSError(domain: "Firebase ClientID가 없습니다.", code: -1, userInfo: nil)))
                    return Disposables.create()
                }
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
                    if let error = error {
                        single(.failure(error))
                        return
                    }
                    guard let signInResult = signInResult, let idToken = signInResult.user.idToken?.tokenString else {
                        single(.failure(NSError(domain: "Google 로그인 정보를 가져올 수 없습니다.", code: -1, userInfo: nil)))
                        return
                    }
                    let accessToken = signInResult.user.accessToken.tokenString
                    // 로그인 성공 후, 자격 증명 반환
                    single(.success((idToken, accessToken)))
                }
            }

            return Disposables.create()
        }
    }

   // Google 계정 삭제 처리
   func deleteUserWithGoogle(idToken: String, accessToken: String) -> Single<Bool> {
       return Single<Bool>.create { single in
           guard let user = Auth.auth().currentUser else {
               single(.failure(NSError(domain: "User is nil", code: -1, userInfo: nil)))
               return Disposables.create()
           }
           
           let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
           
           user.reauthenticate(with: credential) { authResult, error in
               if let error = error {
                   single(.failure(error))
               } else {
                   user.delete { error in
                       if let error = error {
                           single(.failure(error))
                       } else {
                           single(.success(true))
                       }
                   }
               }
           }

           return Disposables.create()
       }
   }

   // 이메일 계정 삭제 처리
   func deleteUserWithEmail(password: String) -> Single<Bool> {
       return Single<Bool>.create { single in
           guard let user = Auth.auth().currentUser, let email = user.email else {
               single(.failure(NSError(domain: "User or Email is nil", code: -1, userInfo: nil)))
               return Disposables.create()
           }

           let credential = EmailAuthProvider.credential(withEmail: email, password: password)
           
           user.reauthenticate(with: credential) { authResult, error in
               if let error = error {
                   single(.failure(error))
               } else {
                   user.delete { error in
                       if let error = error {
                           single(.failure(error))
                       } else {
                           single(.success(true))
                       }
                   }
               }
           }
           return Disposables.create()
       }
   }

   // Apple 로그인 성공 시 처리할 클로저
   private var handleAppleSignIn: ((String?, String?, Error?) -> Void)?
   
   func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
       if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
           let idToken = String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8)
           let authorizationCode = String(data: appleIDCredential.authorizationCode ?? Data(), encoding: .utf8)
           self.handleAppleSignIn?(idToken, authorizationCode, nil)
       }
   }

   func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
       self.handleAppleSignIn?(nil, nil, error)
   }
}
