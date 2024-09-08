import Foundation

import RxSwift

class MyPageViewModel {
    private let disposeBag = DisposeBag()
    
    let memberSubject = PublishSubject<Member>()
    let petListSubject = PublishSubject<[Pet]>()
    
    func findMember(uuid: String) {
        FireStoreDatabaseManager.shared.findMemeber(uuid: uuid).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] member in
            self?.memberSubject.onNext(member)
        }).disposed(by: disposeBag)
    }
    
    func findPetList(uuid: String) {
        FireStoreDatabaseManager.shared.findPetList(userId: uuid).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] petList in
            self?.petListSubject.onNext(petList)
        }).disposed(by: disposeBag)
    }
    
}
