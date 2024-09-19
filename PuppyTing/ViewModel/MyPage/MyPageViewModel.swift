import Foundation

import FirebaseAuth
import FirebaseFirestore
import RxSwift

class MyPageViewModel {
    private let db = Firestore.firestore()
    
    let memberSubject = PublishSubject<Member>()
    let petListSubject = PublishSubject<[Pet]>()
    private let disposeBag = DisposeBag()
    let resultSubject = PublishSubject<Bool>()
    let errorSubject = PublishSubject<Error>()
    
    // 멤버 정보 가져오기
    func fetchMemberInfo(uuid: String) {
        FireStoreDatabaseManager.shared
            .findMemeber(uuid: uuid).observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] member in
                self?.memberSubject.onNext(member)
            }).disposed(by: disposeBag)
    }
    
    // 회원 탈퇴
    func leaveMember(uuid: String) {
        FireStoreDatabaseManager.shared.deleteDocument(from: "member", documentId: uuid).observe(on: MainScheduler.instance).subscribe(onSuccess: {
            self.resultSubject.onNext(true)
        }, onFailure: { error in
            self.errorSubject.onNext(error)
        }).disposed(by: disposeBag)
    }
    
    func deleteUser(user: User, vc: UIViewController) {
        FireStoreDatabaseManager.shared.findMember(uuid: user.uid) { member in
            if let providerID = user.providerData.first?.providerID {
                print(providerID)
                switch providerID {
                case GoogleAuthProviderID:
                    // Google 계정 삭제 처리
                    FirebaseAuthManager.shared.getGoogleCredentials(presentingViewController: vc)
                        .flatMap { credentials in
                            FirebaseAuthManager.shared.deleteUserWithGoogle(idToken: credentials.idToken, accessToken: credentials.accessToken)
                        }
                        .subscribe(onSuccess: { result in
                            self.leaveMember(uuid: user.uid)
                        }, onFailure: { error in
                            self.errorSubject.onNext(error)
                        })
                        .disposed(by: self.disposeBag)

                case "apple.com":
                    // Apple 계정 삭제 처리
                    FirebaseAuthManager.shared.getAppleCredentials()
                        .flatMap { credential in
                            FirebaseAuthManager.shared.deleteUserWithApple(appleCredential: credential)
                        }
                        .subscribe(onSuccess: { result in
                            self.leaveMember(uuid: user.uid)
                        }, onFailure: { error in
                            self.errorSubject.onNext(error)
                        })
                        .disposed(by: self.disposeBag)

                case EmailAuthProviderID:
                    // 이메일 계정 삭제 처리
                    let password = member.password // 비밀번호 입력을 받아야 합니다.
                    FirebaseAuthManager.shared.deleteUserWithEmail(password: password)
                        .subscribe(onSuccess: { result in
                            self.leaveMember(uuid: user.uid)
                        }, onFailure: { error in
                            self.errorSubject.onNext(error)
                        })
                        .disposed(by: self.disposeBag)
                default:
                    let error = NSError(domain: "지원되지 않는 로그인 제공자입니다.", code: -1, userInfo: nil)
                    self.errorSubject.onNext(error)
                }
            } else {
                let error = NSError(domain: "로그인 제공자를 확인할 수 없습니다.", code: -1, userInfo: nil)
                self.errorSubject.onNext(error)
            }
        }
    }
    
    // 가져온 멤버 문서 중 puppies 정보 가져오기
    func fetchMemberPets(memberId: String) -> Single<[Pet]> {
        return Single.create { single in
            let docRef = self.db.collection("member").document(memberId)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists, let data = document.data(), let puppies = data["puppies"] as? [String] {
                    print("불러온 강아지 ID 리스트: \(puppies)")
                    self.getPetsInfo(petIds: puppies)
                        .subscribe(onSuccess: { petsInfo in
                            single(.success(petsInfo))
                        }, onFailure: { error in
                            single(.failure(error))
                        }).disposed(by: self.disposeBag)
                } else if let error = error {
                    single(.failure(error))
                } else {
                    single(.success([]))
                }
            }
            return Disposables.create()
        }
    }

    // pet 컬렉션 중 가져온 petId 와 맞는 정보 탐색
    func getPetsInfo(petIds: [String]) -> Single<[Pet]> {
        return Single.create { single in
            var pets: [Pet] = []
            let dispatchGroup = DispatchGroup()
            
            for petId in petIds {
                dispatchGroup.enter()
                self.db.collection("pet").document(petId).getDocument { (document, error) in
                    if let document = document, document.exists, let data = document.data() {
                        print("불러온 강아지 데이터: \(data)")
                        if let id = data["id"] as? String,
                           let age = data["age"] as? Int,
                           let name = data["name"] as? String,
                           let petImage = data["petImage"] as? String,
                           let tag = data["tag"] as? [String],
                           let userId = data["userId"] as? String {
                            
                            let pet = Pet(id: id, userId: userId, name: name, age: age, petImage: petImage, tag: tag)
                            pets.append(pet)
                        }
                    } else {
                        print("Error fetching pet data for ID \(petId): \(error?.localizedDescription ?? "Unknown error")")
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if pets.isEmpty {
                    single(.success([]))
                } else {
                    single(.success(pets))
                }
            }
            return Disposables.create()
        }
    }
}
