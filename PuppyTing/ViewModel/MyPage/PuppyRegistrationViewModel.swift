//
//  PuppyVRegistrationViewModel.swift
//  PuppyTing
//
//  Created by 박승환 on 9/8/24.
//

import Foundation
import UIKit

import RxSwift

class PuppyRegistrationViewModel {
    
    private let disposeBag = DisposeBag()
    
    let imageSubject = PublishSubject<String>()
    let petSubject = PublishSubject<Pet>()
    
    func updateImage(image: UIImage) {
        FirebaseStorageManager.shared.uploadImage(image: image).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] imageUrl in
            self?.imageSubject.onNext(imageUrl)
        }).disposed(by: disposeBag)
    }
    
    func createPet(userId: String, name: String, age: Int, petImage: String, tag: [String]) {
        FireStoreDatabaseManager.shared.createPuppy(userId: userId, name: name, age: age, petImage: petImage, tag: tag).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] pet in
            self?.petSubject.onNext(pet)
        }).disposed(by: disposeBag)
    }
    
}
