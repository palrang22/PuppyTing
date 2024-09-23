//
//  LoginMessage.swift
//  PuppyTing
//
//  Created by 박승환 on 9/23/24.
//

import Foundation

struct LoginMessage {
    let loginSuccess = "로그인 성공"
    let loginSuccessMessage = "로그인이 완료되었습니다."
    let socialLoginSuccess = "소셜 로그인 성공"
}

struct LoginFailMessage {
    let loginFail = "로그인 실패"
    let socialLoginFail = "소셜 로그인 실패"
    let emailVerificationFailMessage = "이메일 인증에 실패했습니다."
    let invalidCredentialMessage = "이메일 혹은 비밀번호가 잘못되었습니다."
    let otherFailMessage = "알 수 없는 이유로 로그인에 실패했습니다.\n다시 로그인을 시도해주세요."
}

struct SignUpMessage {
    let signUpSuccess = "회원가입 성공"
    let signUpSuccessMessage = "회원가입이 완료되었습니다.\n등록하신 이메일을 확인하신 이후 로그인을 진행해주세요."
}

struct SignUpFailMessage {
    let signUpFail = "회원가입 실패"
    let createFailMessage = "회원가입에 실패했습니다.\n회원가입을 다시 시도해주세요."
    let sendEmailFailMessage = "이메일 전송에 실패했습니다.\n관리자에게 문의를 해주세요."
    let otherFailMessage = "알 수 없는 이유로 회원가입에 실패했습니다.\n회원가입을 다시 시도해주세요."
}

struct FindPasswordMessage {
    let findPasswordSuccess = "비밀번호 재설정"
    let findPasswordSuccessMessage = "등록하신 이메일을 확인해주세요.\n이메일을 확인 후 비밀번호 재설정을 진행해주세요."
}


struct FindPasswordFailMessage {
    let findPasswordFail = "비밀번호 재설정 실패"
    let invalidEmailMessage = "존재하지 않는 이메일 입니다.\n다시 확인후 시도해주세요."
    let otherFailMessage = "알 수 없는 이유로 비밀번호 재설정에 실패했습니다.\n다시 시도해주세요."
}
