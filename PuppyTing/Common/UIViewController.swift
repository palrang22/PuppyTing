//
//  UIViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/28/24.
//

import UIKit

extension UIViewController {

    func setupKeyboardDismissRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
