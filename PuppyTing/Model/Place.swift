//
//  Place.swift
//  PuppyTing
//
//  Created by 김승희 on 9/1/24.
//

import Foundation

struct KakaoLocalSearchResponse: Codable {
    let documents: [Place]
}

struct Place: Codable {
    let placeName: String
    let roadAddressName: String
    let x: String
    let y: String
    let distance: String?
    
    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case roadAddressName = "road_address_name"
        case x, y, distance
    }
}
