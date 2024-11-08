import Foundation

import FirebaseFirestore
import RxCocoa
import RxSwift

class DetailTingViewModel {
    private let disposeBag = DisposeBag()
    
    let memberSubject = PublishSubject<Member>()
    let images: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    func findMember(uuid: String) {
        FireStoreDatabaseManager.shared.findMemeber(uuid: uuid).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] member in
            self?.memberSubject.onNext(member)
        }).disposed(by: disposeBag)
    }
    
    func fetchImages() {
        let imageUrls : [String] = []
        images.accept(imageUrls)
    }
}
