//
//  imageCollectionViewCell.swift
//  PuppyTing
//
//  Created by 김승희 on 11/7/24.
//

import UIKit

import Kingfisher
import SnapKit

class ImageCollectionViewCell: UICollectionViewCell {
    static let id = "imageCollectionViewCell"
    
    private let image : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with urlString: String) {
        KingFisherManager.shared.loadAnyImage(urlString: urlString, into: image)
    }
    
    private func setConstraints() {
        [ image ].forEach {
            contentView.addSubview($0)
        }
        image.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
