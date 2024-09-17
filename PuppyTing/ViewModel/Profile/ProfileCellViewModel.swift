import RxSwift

class ProfileCellViewModel {
    private let disposeBag = DisposeBag()
    
    // 차단이 성공하거나 실패했을 때 뷰에 알리기 위한 Observable
    let blockSuccess = PublishSubject<Bool>()
    
    // 사용자 ID로 사용자를 차단하는 함수
    func blockUser(bookmarkId: String) {
        FireStoreDatabaseManager.shared.blockUser(userId: bookmarkId)
            .subscribe(onSuccess: {
                print("사용자 차단 완료")
                self.blockSuccess.onNext(true)
            }, onFailure: { error in
                print("사용자 차단 실패: \(error)")
                self.blockSuccess.onNext(false)
            }).disposed(by: disposeBag)
    }
}
