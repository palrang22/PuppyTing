//
//  KingFisherManager.swift
//  PuppyTing
//
//  Created by t2023-m0072 on 9/16/24.
//

import UIKit

import Kingfisher

class KingFisherManager {
    static let shared = KingFisherManager()

    private init() {}

    func loadProfileImage(urlString: String, into imageView: UIImageView, placeholder: UIImage? = UIImage(named: "defaultProfileImage")) {
        guard let url = URL(string: urlString) else {
            imageView.image = placeholder
            return
        }
        imageView.kf.setImage(with: url, placeholder: placeholder, options: [
            .cacheOriginalImage
        ])
    }
    
    func loadAnyImage(urlString: String, into imageView: UIImageView, placeholder: UIImage? = UIImage(named: "defaultAnyImage")) {
        guard let url = URL(string: urlString) else {
            imageView.image = placeholder
            return
        }
        imageView.kf.setImage(with: url, placeholder: placeholder, options: [
            .cacheOriginalImage
        ])
    }
    
    func retrieveImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                completion(.success(value.image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func clearCache() {
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
    }
}

