//
//  ChatViewModel.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import Foundation

import RxCocoa
import RxSwift

class ChatViewModel {
    // 입력: 사용자가 보낸 메세지
    let messageText = PublishSubject<String>()
    // 출력: 메세지 리스트
    let messages = BehaviorRelay<[Message]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    init() {
        setupBindings()
        setupInitialMessages() // 초기 메세지 예시
    }
    
    // 초기 메세지 설정
    private func setupInitialMessages() {
        let initialMeesages: [Message] = [
            Message(isMyMessage: true, text: "안녕하세요!", date: "10:00"),
            Message(isMyMessage: false, text: "안녕하세요~ 반가워요!", date: "10:05"),
            Message(isMyMessage: true, text: "오늘 산책 가능하신가요?", date: "10:20"),
            Message(isMyMessage: false, text: "네 가능합니다!", date: "11:00"),
            Message(isMyMessage: true, text: "칸이 얼마나 긴지 알고싶지 않나요 저는 궁금하네요 하하하하하하하하하하하ㅏ하하하하하하하하하하핳ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ", date: "11:01"),
            Message(isMyMessage: false, text: "이상하네요!", date: "11:02"),
            Message(isMyMessage: false, text: "상대가 두번 말하면 이렇게", date: "11:02"),
            Message(isMyMessage: false, text: "채팅방 어떻게 나오는지 확인", date: "11:02"),
            Message(isMyMessage: false, text: "마지막 셀로 나오는지 확인하기 위한 대화 내요옹오오오오오오옹ㅇ오오오오오오옹ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ", date: "11:03"),
            Message(isMyMessage: true, text: "테스트 메세지 감사합니다", date: "11:04")
        ]
        messages.accept(initialMeesages)
    }
    
    private func setupBindings() {
        // 메세지가 입력되면 리스트에 추가
        messageText
            .filter { !$0.isEmpty } // 빈 메세지 필터링
            .subscribe(onNext: { [weak self] newMessage in
                guard let self = self else { return }
                let myMessage = Message(isMyMessage: true, text:newMessage, date: self.getCurrentTime())
                self.messages.accept(self.messages.value + [myMessage])
            })
            .disposed(by: disposeBag)
    }
    
    // 현재 시간을 문자열로 반환하는 함수
    private func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date())
    }
}

struct Message {
    let isMyMessage: Bool
    let text: String
    let date: String
}
