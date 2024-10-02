//
//  Report.swift
//  PuppyTing
//
//  Created by t2023-m0072 on 9/16/24.
//

import Foundation

struct Report: Codable {
    let postId: String
    let reason: String
    let timeStamp: Date
    
    var dictionary: [String:Any] {
        return [
            "postId": postId,
            "reason": reason,
            "timeStamp": timeStamp
        ]
    }
}
