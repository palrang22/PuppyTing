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
    
    //MARK: Keyboard - ksh
    // 키보드 포커싱 해제 메서드
    func setupKeyboardDismissRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 키보드 높이 조절 메서드
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        guard let firstResponder = self.view.firstResponder else { return }
        let firstResponderFrame = firstResponder.convert(firstResponder.bounds, to: self.view)
        
        let bottomSpace = self.view.frame.height - (firstResponderFrame.origin.y + firstResponderFrame.height)
        
        if bottomSpace < keyboardHeight {
            let moveDistance = keyboardHeight - bottomSpace
            self.view.frame.origin.y = -moveDistance
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: Alert - ksh
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

extension UIView {
    var firstResponder: UIView? {
        if self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        return nil
    }
}
