//
//  ChatModel.swift
//  PuppyTing
//
//  Created by 박승환 on 9/5/24.
//

import Foundation

struct ChatRoom {
    let id: String
    let name: String
    let users: [String]
    let lastChat: ChatMessage?
}

struct ChatMessage {
    let id: String
    let senderId: String
    let text: String
    let timestamp: TimeInterval
}
