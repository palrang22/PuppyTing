//
//  Member.swift
//  PuppyTing
//
//  Created by 박승환 on 8/29/24.
//

import Foundation

struct Member: Codable {
    let uuid: String
    let email: String
    let password: String
    let nickname: String
    let profileImage: String
    let footPrint: Int
    let isSocial: Bool
    let blockedUsers: [String]
    let bookMarkUsers: [String]
    let puppies: [String]
    
    // 기본 초기화
    init(uuid: String, email: String, password: String, nickname: String, profileImage: String, footPrint: Int, isSocial: Bool, blockedUsers: [String] = [], bookMarkUsers: [String] = [], puppies: [String] = []) {
        self.uuid = uuid
        self.email = email
        self.password = password
        self.nickname = nickname
        self.profileImage = profileImage
        self.footPrint = footPrint
        self.isSocial = isSocial
        self.blockedUsers = blockedUsers
        self.bookMarkUsers = bookMarkUsers
        self.puppies = puppies
    }
    
    // 딕셔너리에서 초기화
    init?(dictionary: [String: Any]) {
        guard let uuid = dictionary["uuid"] as? String,
              let email = dictionary["email"] as? String,
              let password = dictionary["password"] as? String,
              let nickname = dictionary["nickname"] as? String,
              let profileImage = dictionary["profileImage"] as? String,
              let footPrint = dictionary["footPrint"] as? Int,
              let isSocial = dictionary["isSocial"] as? Bool else { return nil }
        
        self.uuid = uuid
        self.email = email
        self.password = password
        self.nickname = nickname
        self.profileImage = profileImage
        self.footPrint = footPrint
        self.isSocial = isSocial
        self.blockedUsers = dictionary["blockedUsers"] as? [String] ?? []
        self.bookMarkUsers = dictionary["bookMarkUsers"] as? [String] ?? []
        self.puppies = dictionary["puppies"] as? [String] ?? []
    }
    
    // 딕셔너리로 변환
    var dictionary: [String: Any] {
        return [
            "uuid": uuid,
            "email": email,
            "password": password,
            "nickname": nickname,
            "profileImage": profileImage,
            "footPrint": footPrint,
            "isSocial": isSocial,
            "blockedUsers": blockedUsers,
            "bookMarkUsers": bookMarkUsers,
            "puppies": puppies
        ]
    }
}
