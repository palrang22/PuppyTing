import Foundation

import RxSwift

class BlockListViewModel {
    
    private let disposeBag = DisposeBag()
    private let databaseManager = FireStoreDatabaseManager.shared
    
    private let _blockedUsers = BehaviorSubject<[Member]>(value: [])
    var blockedUsers: Observable<[Member]> {
        return _blockedUsers.asObservable()
    }
    
    func fetchBlockedUsers() {
        databaseManager.getBlockedUsers()
            .subscribe(onSuccess: { [weak self] members in
                self?._blockedUsers.onNext(members)
            }, onFailure: { error in
                print("차단된 사용자 목록 가져오기 실패: \(error)")
            }).disposed(by: disposeBag)
    }
}
