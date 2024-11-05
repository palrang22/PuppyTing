//
//  FirebaseStorageManager.swift
//  PuppyTing
//
//  Created by 박승환 on 9/7/24.
//

import Foundation
import UIKit

import FirebaseStorage
import RxSwift

class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    
    private init() {
        
    }
    
    func uploadImage(image: UIImage) -> Single<String> {
        return Single.create { single in
            // 1. Firebase Storage 참조 생성
            let storageRef = Storage.storage().reference()
            
            // 2. 이미지를 저장할 파일 경로 설정 (예: "images/unique_image_id.jpg")
            let imageID = UUID().uuidString
            let imageRef = storageRef.child("images/\(imageID).jpg")
            
            // 3. UIImage를 JPEG 데이터로 변환
            guard let imageData = image.jpegData(compressionQuality: 0.75) else {
                single(.failure(NSError(domain: "ImageConversionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to Data"])))
                return Disposables.create()
            }
            
            // 4. Firebase Storage에 이미지 업로드
            let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    single(.failure(error)) // 업로드 실패
                } else {
                    // 5. 업로드 성공 시, 다운로드 URL 가져오기
                    imageRef.downloadURL { url, error in
                        if let error = error {
                            single(.failure(error))
                        } else if let downloadURL = url {
                            single(.success(downloadURL.absoluteString))
                        }
                    }
                }
            }
            return Disposables.create {
                uploadTask.cancel() // 업로드 취소 가능
            }
        }
    }
    
}
