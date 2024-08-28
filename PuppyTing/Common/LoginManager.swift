//
//  LoginManager.swift
//  PuppyTing
//
//  Created by 박승환 on 8/27/24.
//

import Foundation

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

class LoginManager {
    
    
    init() {
        
    }
    
    // 퍼피팅 아이디로 회원가입
    func emailSignUp(email: String, password: String, nickname: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("에러 발생")
            }
            if let result = result {
                // 회원가입 성공
                if !result.user.isEmailVerified {
                    Auth.auth().currentUser?.sendEmailVerification(completion: { [weak self] error in
                        guard self != nil else { return }
                            if let error = error {
                                // 에러
                                print("-----Verify Email ERROR \(error.localizedDescription)-----")
                            } else {
                                // 이메일 전송에 성공
                                print("이메일 전송")
                            }
                        }
                    )
                }
                // 회원가입 디비에까지는 저장을 시켜둔다.
//                let member = Member(uuid: result.user.uid, email: email, password: password, nickname: nickname, profileImage: "더미이미지", dogGum: 0)
//                db.collection("user").document(member.uuid).setData(member.dictionary) { error in
//                    if let error = error {
//                        print("에러발생: \(error)")
//                    } else {
//                        print("회원가입 완료")
//                    }
//                }
            } else {
                // 회원가입 실패
            }
        }
    }
    
    // 퍼피팅 아이디로 로그인
    func emailSignIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("에러 발생")
            }
            if let result = result {
                if result.user.isEmailVerified {
                    // 로그인 성공
                } else {
                    // 이메일 인증 안됨
                }
            } else {
                // 로그인 실패
            }
        }
    }
    
    // 구글 간편 로그인
    func googleSignIn(viewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [unowned self] result, error in
            guard error == nil else { return }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    // 구글 로그인 실패
                }
                if let result = result {
                    // 구글 로그인 성공
                }
            }
        }
    }
    
    // 로그아웃
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            // 로그아웃 성공
        } catch let signOutError as NSError {
            // 로그아웃 실패
        }
        
    }
    
    
}
