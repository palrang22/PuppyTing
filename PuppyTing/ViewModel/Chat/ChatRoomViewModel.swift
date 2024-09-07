//
//  ChatRoomViewModel.swift
//  PuppyTing
//
//  Created by 박승환 on 9/5/24.
//

import Foundation

import RxSwift

class ChatRoomViewModel {
    
    private let disposeBag = DisposeBag()
    
    // ViewModel의 Input 구조체
    struct Input {
        let fetchRooms: Observable<Void> // 채팅방 목록을 가져오는 Observable 이벤트
    }
    
    // ViewModel의 Output 구조체
    struct Output {
        let chatRooms: Observable<[ChatRoom]> // 채팅방 목록을 방출하는 Observable
    }
    
    let memberSubject = PublishSubject<Member>()
    
    // ViewModel의 Input을 받아 Output을 생성하는 메서드
    func transform(input: Input, userId: String) -> Output {
        let chatRooms = input.fetchRooms
            .flatMapLatest { [weak self] _ -> Observable<[ChatRoom]> in
                guard let self = self else {
                    print("test")
                    return Observable.just([]) } // self가 nil인 경우 빈 배열 반환
                return FirebaseRealtimeDatabaseManager.shared.fetchChatRooms(userId: userId)
                    .catchAndReturn([]) // 에러 발생 시 빈 배열 반환
            }
        
        return Output(chatRooms: chatRooms) // Output 반환
    }
    
    func findMember(uuid: String) {
        FireStoreDatabaseManager.shared.findMemeber(uuid: uuid).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] memeber in
            self?.memberSubject.onNext(memeber)
        }).disposed(by: disposeBag)
    }
    
}
