import RxSwift

import FirebaseAuth

class MyFeedManageViewModel { // kkh
    let feedsSubject = BehaviorSubject<[TingFeedModel]>(value: [])
    private let disposeBag = DisposeBag()
    
    func fetchFeeds() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("사용자 인증 실패")
            return
        }

        FireStoreDatabaseManager.shared.fetchFeeds(forUserId: currentUserId)
            .subscribe(onSuccess: { [weak self] feeds in
                print("Fetched feeds for user \(currentUserId): \(feeds)")
                self?.feedsSubject.onNext(feeds)
            }, onError: { error in
                print("Error fetching feeds: \(error)")
            })
            .disposed(by: disposeBag)
    }
}
