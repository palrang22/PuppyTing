//
//  ProfileViewModel.swift
//  PuppyTing
//
//  Created by 내꺼다 on 9/9/24.
//

import Foundation
import UIKit

import FirebaseAuth
import RxSwift

class ProfileViewModel {
    
    private let disposeBag = DisposeBag()
    
    // 강아지 정보 관련 BehaviorSubjects
    let petName = BehaviorSubject<String>(value: "강아지 이름")
    let petAge = BehaviorSubject<String>(value: "나이")
    let petTags = BehaviorSubject<String>(value: "태그")
    let petImage = BehaviorSubject<UIImage?>(value: UIImage(named: "defaultProfileImage"))
    
    // 즐겨찾기 및 발도장 관련 Subjects
    let bookmarkSuccess = PublishSubject<Void>()
    let bookmarkError = PublishSubject<Error>()
    let footPrintSuccess = PublishSubject<Void>()
    let footPrintError = PublishSubject<Error>()
    
    // 즐겨찾기 추가 메서드
    func addBookmark(bookmarkId: String) {
        FireStoreDatabaseManager.shared.addBookmark(forUserId: Auth.auth().currentUser?.uid ?? "", bookmarkId: bookmarkId)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.bookmarkSuccess.onNext(())
            }, onFailure: { [weak self] error in
                self?.bookmarkError.onNext(error)
            }).disposed(by: disposeBag)
    }
    
    // 사용자 차단 메서드
    func blockedUser(uuid: String) {
        FireStoreDatabaseManager.shared.blockUser(userId: uuid)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: {
                // 성공 처리
            }, onFailure: { error in
                // 실패 처리
            }).disposed(by: disposeBag)
    }
    
    // 발도장 추가 메서드
    func addFootPrint(footPrintId: String) {
        FireStoreDatabaseManager.shared.addFootPrint(toUserId: footPrintId)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.footPrintSuccess.onNext(())
            }, onFailure: { [weak self] error in
                self?.footPrintError.onNext(error)
            }).disposed(by: disposeBag)
    }
    
    // 유저 ID로 강아지 정보 가져오는 메서드
    func fetchPetsForUser(userId: String) {
        print("fetchPetsForUser called with userId: \(userId)") // 호출 확인용 로그
        FireStoreDatabaseManager.shared.fetchPetsByUserId(userId: userId)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] pets in
                if let firstPet = pets.first {
                    // 강아지 정보가 있을 때
                    self?.petName.onNext(firstPet.name)
                    self?.petAge.onNext("\(firstPet.age)살")
                    self?.petTags.onNext(firstPet.tag.joined(separator: ", "))
                    
                    // 이미지 URL을 통해 이미지 로드 후 BehaviorSubject 업데이트
                    if let imageUrl = URL(string: firstPet.petImage) {
                        URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                            if let data = data, let image = UIImage(data: data) {
                                self?.petImage.onNext(image)
                            } else {
                                print("Failed to load image data")
                                self?.petImage.onNext(UIImage(named: "defaultProfileImage"))
                            }
                        }.resume()
                    } else {
                        print("Invalid image URL")
                        self?.petImage.onNext(UIImage(named: "defaultProfileImage"))
                    }
                } else {
                    // 강아지 정보가 없을 때
                    print("No pets found for user")
                    self?.petName.onNext("강아지 없음")
                    self?.petAge.onNext("정보 없음")
                    self?.petTags.onNext("태그 없음")
                    self?.petImage.onNext(UIImage(named: "defaultProfileImage"))
                }
            }, onFailure: { error in
                // 오류 발생 시 처리
                print("Failed to fetch pet data: \(error.localizedDescription)")
                self.petName.onNext("강아지 없음")
                self.petAge.onNext("정보 없음")
                self.petTags.onNext("태그 없음")
                self.petImage.onNext(UIImage(named: "defaultProfileImage"))
            })
            .disposed(by: disposeBag)
    }
}
