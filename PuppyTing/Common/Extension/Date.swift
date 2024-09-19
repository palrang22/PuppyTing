//
//  Date.swift
//  PuppyTing
//
//  Created by 박승환 on 9/9/24.
//

import Foundation

extension Date {
    func toDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
