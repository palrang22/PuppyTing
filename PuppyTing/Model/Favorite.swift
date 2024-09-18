//
//  Favorite.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/13/24.
//

import Foundation

struct Favorite {
    let uuid: String?
    let nickname: String
    let profileImageURL: String?
    
    init(data: [String: Any]) {
        self.uuid = data["uuid"] as? String ?? ""
        self.nickname = data["nickname"] as? String ?? "알 수 없음"
        self.profileImageURL = data["profileImage"] as? String
    }
}

