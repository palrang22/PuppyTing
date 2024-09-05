import Foundation

import RxSwift

class MyPageViewModel {
    private let disposeBag = DisposeBag()
    
    let memberSubject = PublishSubject<Member>()
    
    func findMember(uuid: String) {
        FireStoreDatabaseManager.shared.findMemeber(uuid: uuid).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] member in
            self?.memberSubject.onNext(member)
        }).disposed(by: disposeBag)
    }
    
    
}
