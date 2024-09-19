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
    
        func deletePuppy(petId: String, userId: String) -> Single<Void> { // kkh
            return Single.create { single in
                let petRef = self.db.collection("pet").document(petId)
                let memberRef = self.db.collection("member").document(userId)
                
                // 강아지 데이터 삭제
                petRef.delete { error in
                    if let error = error {
                        single(.failure(error))
                        return
                    }
                    
                    // 사용자의 강아지 목록에서 강아지 ID 제거
                    memberRef.updateData([
                        "puppies": FieldValue.arrayRemove([petId])
                    ]) { error in
                        if let error = error {
                            single(.failure(error))
                        } else {
                            single(.success(()))
                        }
                    }
                }
                return Disposables.create()
            }
        }
    }
