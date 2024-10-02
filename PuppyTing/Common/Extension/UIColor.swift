//
//  UIColor.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import UIKit

extension UIColor {
    static let puppyPurple = UIColor(red: 175/255, green: 151/255, blue: 255/255, alpha: 1)
    static let lightPuppyPurple = UIColor(red: 209/255, green: 192/255, blue: 255/255, alpha: 1)
    static let darkPuppyPurple = UIColor(red: 95/255, green: 76/255, blue: 183/255, alpha: 1)
    
    static var randomColor: UIColor {
        let red = CGFloat(arc4random_uniform(256)) / 255.0
        let green = CGFloat(arc4random_uniform(256)) / 255.0
        let blue = CGFloat(arc4random_uniform(256)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 0.5)
    }
}
