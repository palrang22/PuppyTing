//
//  Pet.swift
//  PuppyTing
//
//  Created by 박승환 on 9/8/24.
//

import Foundation

struct Pet: Codable {
    let id: String
    let userId: String
    let name: String
    let age: Int
    let petImage: String
    let tag: [String]
    
    init(id: String, userId: String, name: String, age: Int, petImage: String, tag: [String]) {
        self.id = id
        self.userId = userId
        self.name = name
        self.age = age
        self.petImage = petImage
        self.tag = tag
    }
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let userId = dictionary["userId"] as? String,
              let name = dictionary["name"] as? String,
              let age = dictionary["age"] as? Int,
              let petImage = dictionary["petImage"] as? String,
              let tag = dictionary["tag"] as? [String] else { return nil }
        
        self.id = id
        self.userId = userId
        self.name = name
        self.age = age
        self.petImage = petImage
        self.tag = tag
    }
    
    var dictionray: [String: Any] {
        return [
            "id": id,
            "userId": userId,
            "name" : name,
            "age": age,
            "petImage": petImage,
            "tag": tag
        ]
    }
    
}
