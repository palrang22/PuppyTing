//
//  ChatViewModel.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import Foundation
import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift

class ChatViewModel {
    
    private let disposeBag = DisposeBag()
    
    // ViewModel의 Input 구조체
    struct Input {
        let roomId: String // 채팅방 ID
        let fetchMessages: Observable<Void> // 메시지를 가져오는 Observable 이벤트
        let sendMessage: Observable<String> // 메시지를 전송하는 Observable 이벤트
    }
    
    // ViewModel의 Output 구조체
    struct Output {
        let messages: Observable<[ChatMessage]> // 메시지 목록을 방출하는 Observable
        let messageSent: Observable<Void> // 메시지 전송 완료 이벤트
    }
    
    let memberSubject = PublishSubject<Member>()
    
    // ViewModel의 Input을 받아 Output을 생성하는 메서드
    func transform(input: Input) -> Output {
        let messages = input.fetchMessages
            .flatMapLatest { [weak self] _ -> Observable<[ChatMessage]> in
                guard let self = self else { return Observable.just([]) }
                return FirebaseRealtimeDatabaseManager.shared.observeMessages(in: input.roomId)
                    .scan([]) { (oldMessages, newMessage) in
                        var messages = oldMessages
                        
                        if let lastMessage = messages.last {
                            let lastDate = Date(timeIntervalSince1970: lastMessage.timestamp)
                            let newDate = Date(timeIntervalSince1970: newMessage.timestamp)
                            let calendar = Calendar.current
                            
                            // 날짜가 다르면 날짜 메시지를 추가
                            if !calendar.isDate(lastDate, inSameDayAs: newDate) {
                                let dateMessage = ChatMessage(
                                    id: UUID().uuidString,
                                    senderId: "date", // 특별한 ID로 표시 (ex. 날짜 메시지)
                                    text: newDate.toDateString(), // 날짜 형식으로 표시
                                    timestamp: newMessage.timestamp
                                )
                                messages.append(dateMessage)
                            }
                        } else {
                            // 첫 메시지라면 날짜 메시지를 추가
                            let dateMessage = ChatMessage(
                                id: UUID().uuidString,
                                senderId: "date",
                                text: Date(timeIntervalSince1970: newMessage.timestamp).toDateString(),
                                timestamp: newMessage.timestamp
                            )
                            messages.append(dateMessage)
                        }
                        
                        messages.append(newMessage)
                        return messages
                    }
                    .catchAndReturn([])
            }
        
        let messageSent = input.sendMessage
            .flatMapLatest { [weak self] text -> Observable<Void> in
                guard let self = self else { return Observable.just(()) } // self가 nil인 경우 빈 이벤트 반환
                return FirebaseRealtimeDatabaseManager.shared.sendMessage(to: input.roomId, senderId: Auth.auth().currentUser!.uid, text: text)
                    .catchAndReturn(()) // 에러 발생 시 빈 이벤트 반환
            }
        
        return Output(messages: messages, messageSent: messageSent) // Output 반환
    }
    
    func findMember(uuid: String) {
        FireStoreDatabaseManager.shared.findMemeber(uuid: uuid).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] memeber in
            self?.memberSubject.onNext(memeber)
        }).disposed(by: disposeBag)
    }
}
