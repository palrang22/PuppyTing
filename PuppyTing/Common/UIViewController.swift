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
    
    // 키보드 이벤트 처리하는 Observable 반환하는 메서드
    func observeKeyboardHeight() -> Observable<CGFloat> {
        let willShowObservable = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                return keyboardFrame?.height ?? 0
            }
        
        let willHideObservable = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in
                return 0
            }
        
        return Observable.merge(willShowObservable, willHideObservable)
    }
    
    // 키보드에 맞게 뷰 위치를 조정하는 메서드
    func bindKeyboardHeightToViewAdjustment(disposeBag: DisposeBag) {
        observeKeyboardHeight()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] keyboardHeight in
                UIView.animate(withDuration: 0.3) {
                    self?.view.frame.origin.y = -keyboardHeight
                }
            })
            .disposed(by: disposeBag)
    }
}
