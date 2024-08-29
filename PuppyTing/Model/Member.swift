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
    
    var dictionary: [String: Any] {
        return [
            "uuid": uuid,
            "email": email,
            "password": password,
            "nickname": nickname,
            "profileImage": profileImage,
            "footPrint": footPrint,
            "isSocial": isSocial
        ]
    }
}
