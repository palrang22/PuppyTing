//
//  UIViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/28/24.
//

import UIKit

import Lottie
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
    
    // 자동으로 사라지는 Alert 메서드 - jgh
    func autoDismissAlertWithTimer(title: String? = nil, message: String, duration: TimeInterval = 2.0) { // title은 원하는대로 생략가능(제목이 애매한것들이 있을까봐 넣었습니다.) duration은 원하는대로 조정가능 따로 지정하지 않으면 2초뒤에 사라짐
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { _ in
            alert.dismiss(animated: true, completion: nil)
        })
    }
    
    // 로딩 인디케이터 관련 메서드 - ksh
    func showLoadingIndicator() {
        
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.white
        backgroundView.alpha = 1.0
        backgroundView.tag = 998
        
        let animationView = LottieAnimationView(name: "PuppytingLoading")
        animationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.tag = 999
        
        self.view.addSubview(backgroundView)
        self.view.addSubview(animationView)
    }
    
    func showLoadingIndicatorWithoutBackground() {

        let animationView = LottieAnimationView(name: "PuppytingLoading")
        animationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.tag = 999
        
        self.view.addSubview(animationView)
    }
        
    func hideLoadingIndicator() {
        if let animationView = self.view.viewWithTag(999) as? LottieAnimationView {
            animationView.stop()
            animationView.removeFromSuperview()
        }
        if let backgroundView = self.view.viewWithTag(998) {
            backgroundView.removeFromSuperview()
        }
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
