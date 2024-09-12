//
//  PuppyVRegistrationViewModel.swift
//  PuppyTing
//
//  Created by 박승환 on 9/8/24.
//

import UIKit

import FirebaseFirestore
import RxSwift

class PuppyRegistrationViewModel {
    
    private let db = Firestore.firestore()
    
    let imageSubject = PublishSubject<String>()
    let petSubject = PublishSubject<Pet>()
    private let disposeBag = DisposeBag()
    
    func updateImage(image: UIImage) {
        FirebaseStorageManager.shared
            .uploadImage(image: image)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] imageUrl in
            self?.imageSubject.onNext(imageUrl)
        }).disposed(by: disposeBag)
    }
    
    func createPuppy(userId: String, name: String, age: Int, petImage: String, tag: [String]) -> Single<Pet> {
        return Single.create { single in
            let docRef = self.db.collection("pet").document()
            let petId = docRef.documentID
            
            let pet = Pet(id: petId, userId: userId, name: name, age: age, petImage: petImage, tag: tag)
            
            docRef.setData(pet.dictionary) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    let memberDocRef = self.db.collection("member").document(userId)
                    memberDocRef.updateData([
                        "puppies": FieldValue.arrayUnion([petId])
                    ]) { error in
                        if let error = error {
                            single(.failure(error))
                        } else {
                            single(.success(pet))
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func updatePuppy(petId: String, userId: String, name: String, age: Int, petImage: String, tag: [String]) -> Single<Pet> {
        return Single.create { single in
            let docRef = self.db.collection("pet").document(petId)
            
            let updatedPet = Pet(id: petId, userId: userId, name: name, age: age, petImage: petImage, tag: tag)
            
            docRef.setData(updatedPet.dictionary, merge: true) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(updatedPet))
                }
            }
            return Disposables.create()
        }
    }

}
