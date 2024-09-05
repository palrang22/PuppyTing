//
//  UIViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/28/24.
//

import UIKit

import RxCocoa
import RxSwift

extension UIViewController {

    // 키보드 포커싱 해제 메서드
    func setupKeyboardDismissRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 확인버튼만 있는 Alert 메서드
    func okAlert(title: String, message: String, okActionTitle: String = "확인", okActionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okActionTitle, style: .default, handler: okActionHandler)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // 취소버튼이 있는 Alert 메서드
    func okAlertWithCancel(title: String, message: String, okActionTitle: String = "확인", cancelActionTitle: String = "취소", okActionHandler: ((UIAlertAction) -> Void)? = nil, cancelActionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okActionTitle, style: .default, handler: okActionHandler)
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: cancelActionHandler)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
