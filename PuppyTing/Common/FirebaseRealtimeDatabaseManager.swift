//
//  FirebaseRealtimeDatabaseManager.swift
//  PuppyTing
//
//  Created by 박승환 on 9/5/24.
//

import Foundation

import FirebaseDatabase
import RxSwift

class FirebaseRealtimeDatabaseManager {
    
    static let shared = FirebaseRealtimeDatabaseManager()
    
    private init() {
        
    }
    
    private let databaseRef = Database.database().reference()
    
    func createChatRoom(name: String, users: [String]) -> Single<String> {
        return Single.create { single in
            let roomRef = self.databaseRef.child("chatRooms").childByAutoId()
            let roomId = roomRef.key ?? UUID().uuidString
            let roomData: [String: Any] = [
                "name": name,
                "users": users
            ]
            roomRef.setValue(roomData) { error, _ in
                if let error = error {
                    print("실패")
                    single(.failure(error))
                } else {
                    print("성공")
                    single(.success(roomId))
                }
            }
            return Disposables.create()
        }
    }
    
    // FCM 토큰을 Realtime Database에 저장하는 메서드 - ksh
    func saveFCMToken(userId: String, fcmToken: String) -> Single<Void> {
        return Single<Void>.create { single in
            let userRef = self.databaseRef.child("users").child(userId)
            
            // FCM 토큰을 저장하는 데이터 구조
            userRef.child("fcmToken").setValue(fcmToken) { error, _ in
                if let error = error {
                    single(.failure(error)) // 실패 시 에러 반환
                } else {
                    single(.success(())) // 성공 시 성공 반환
                }
            }
            
            return Disposables.create()
        }
    }
    
    // 모든 채팅방 목록을 가져오는 메서드
    func fetchChatRooms(userId: String) -> Observable<[ChatRoom]> {
        return Observable.create { observer in
            
            // 1. 차단한 유저 목록 가져오기
            FireStoreDatabaseManager.shared.getBlockedUsers(uuid: userId) { blockedUsers in
                // 2. 차단한 유저 목록을 가져온 후, 채팅방 데이터를 가져오기
                self.databaseRef.child("chatRooms").observe(.value) { snapshot in
                    var chatRooms: [ChatRoom] = []
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let dict = childSnapshot.value as? [String: Any],
                           let name = dict["name"] as? String,
                           let users = dict["users"] as? [String] {
                            // 3. 차단한 유저가 포함된 방은 제외
                            let isBlocked = users.contains { blockedUsers.contains($0) }
                            if isBlocked {
                                continue // 차단한 유저가 포함된 방이면 건너뜀
                            }
                            // 4. 채팅방의 마지막 메시지 처리
                            var lastChat: ChatMessage? = nil
                            if let messageSnapshot = childSnapshot
                                .childSnapshot(forPath: "messages")
                                .children.allObjects as? [DataSnapshot] {
                                if let lastMessageSnapshot = messageSnapshot.last,
                                   let messageDict = lastMessageSnapshot.value as? [String: Any],
                                   let senderId = messageDict["senderId"] as? String,
                                   let text = messageDict["text"] as? String,
                                   let timestamp = messageDict["timestamp"] as? TimeInterval {
                                    lastChat = ChatMessage(id: lastMessageSnapshot.key,
                                                           senderId: senderId,
                                                           text: text,
                                                           timestamp: timestamp)
                                }
                            }
                            // 5. 차단한 유저가 포함되지 않은 채팅방만 추가
                            if users.contains(userId) {
                                let room = ChatRoom(id: childSnapshot.key,
                                                    name: name,
                                                    users: users,
                                                    lastChat: lastChat)
                                chatRooms.append(room)
                            }
                        }
                    }
                    // 6. 마지막 채팅 시간으로 정렬
                    chatRooms.sort { (room1, room2) -> Bool in
                        guard let timestamp1 = room1.lastChat?.timestamp,
                              let timestamp2 = room2.lastChat?.timestamp else {
                            return false
                        }
                        return timestamp1 > timestamp2
                    }
                    
                    // 7. 필터링 및 정렬된 채팅방 목록 전달
                    observer.onNext(chatRooms)
                }
            }
            
            return Disposables.create {
                self.databaseRef.child("chatRooms").removeAllObservers()
            }
        }
    }

    
    // 특정 채팅방에 메시지를 전송하는 메서드
    func sendMessage(to roomId: String, senderId: String, text: String) -> Observable<Void> {
        return Observable.create { observer in
            let messageRef = self.databaseRef
                .child("chatRooms")
                .child(roomId)
                .child("messages")
                .childByAutoId() // 새로운 메시지의 참조 생성
            let messageData: [String: Any] = [
                "senderId": senderId,
                "text": text,
                "timestamp": Date().timeIntervalSince1970
            ]
            
            messageRef.setValue(messageData) { error, _ in
                if let error = error {
                    observer.onError(error) // 에러 발생 시 observer에 에러 전달
                } else {
                    observer.onNext(()) // 성공 시 완료 신호 전달
                    observer.onCompleted() // 작업 완료 신호
                }
            }
            
            return Disposables.create()
        }
    }
    
    func observeMessages(in roomId: String) -> Observable<ChatMessage> {
        return Observable.create { observer in
            let ref = self.databaseRef.child("chatRooms").child(roomId).child("messages") // 메시지 경로 참조
            
            ref.observe(.childAdded) { snapshot in
                if let dict = snapshot.value as? [String: Any],
                   let senderId = dict["senderId"] as? String,
                   let text = dict["text"] as? String,
                   let timestamp = dict["timestamp"] as? TimeInterval {
                    
                    let message = ChatMessage(id: snapshot.key,
                                              senderId: senderId,
                                              text: text,
                                              timestamp: timestamp) // 메시지 객체 생성
                    observer.onNext(message) // 새로운 메시지 전달
                }
            }
            
            return Disposables.create {
                ref.removeAllObservers() // 관찰자 제거
            }
        }
    }
    
    func checkIfChatRoomExists(userIds: [String], completion: @escaping (Bool, String?) -> Void) {
        // 모든 채팅방을 순회하며 두 사용자가 포함된 채팅방이 있는지 확인
        databaseRef.child("chatRooms").observeSingleEvent(of: .value, with: { snapshot in
            if let chatRooms = snapshot.value as? [String: Any] {
                for (chatRoomId, chatRoomData) in chatRooms {
                    if let chatRoomDetails = chatRoomData as? [String: Any],
                       let users = chatRoomDetails["users"] as? [String] {
                        
                        // 두 사용자가 모두 users 배열에 포함되어 있는지 확인
                        let usersSet = Set(users)
                        let checkSet = Set(userIds)
                        
                        if checkSet.isSubset(of: usersSet) {
                            // 두 사용자가 포함된 채팅방이 발견되면 true와 채팅방 ID 반환
                            completion(true, chatRoomId)
                            return  // 채팅방을 찾으면 더 이상 검색하지 않고 종료
                        }
                    }
                }
                // 두 사용자가 포함된 채팅방이 없을 경우 false와 nil 반환
                completion(false, nil)
            } else {
                // 데이터가 없을 경우 false와 nil 반환
                completion(false, nil)
            }
        }) { error in
            print("오류 발생: \(error.localizedDescription)")
            completion(false, nil)  // 오류 발생 시에도 false 반환
        }
    }
    
    func deleteChatRoom(roomId: String) -> Single<Void> {
        return Single<Void>.create { single in
            let roomRef = self.databaseRef.child("chatRooms").child(roomId)
            
            roomRef.removeValue { error, _ in
                if let error = error {
                    single(.failure(error)) // 에러 발생 시 실패 방출
                } else {
                    single(.success(())) // 성공 시 성공 이벤트 방출
                }
            }
            
            return Disposables.create()
        }
    }
    
}
