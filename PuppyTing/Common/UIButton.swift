//
//  UIButton.swift
//  PuppyTing
//
//  Created by t2023-m0072 on 9/6/24.
//

import UIKit

extension UIButton {
    func makeTag(word: String, target: Any?, action: Selector) {
        self.setTitle("# \(word)", for: .normal)
        self.backgroundColor = .randomColor
        self.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.addTarget(target, action: action, for: .touchUpInside)
    }
}
