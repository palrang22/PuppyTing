//
//  PuppyCollectionViewCell.swift
//  PuppyTing
//
//  Created by 엔젤 on 9/26/24.
//

import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class ProfilePuppyCollectionViewCell: UICollectionViewCell {
    static let identifier = "ProfilePuppyCollectionViewCell"
    
    var viewModel: ProfileViewModel?
    var memberId: String?
    var petId: String? // 강아지 정보 찾기
    private let userId = Auth.auth().currentUser?.uid
    weak var parentViewController: UIViewController?
    private let disposeBag = DisposeBag()
    
    private let puppyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "defaultProfileImage")
        imageView.layer.cornerRadius = 30
        return imageView
    }()
    
    private let puppyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "강아지 이름"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let puppyAgeLabel: UILabel = {
        let label = UILabel()
        label.text = "나이"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()

    private let puppyTagLabel: UILabel = {
        let label = UILabel()
        label.text = "태그"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
//    private func bindViewModel() {
//        viewModel?.petName
//            .bind(to: puppyNameLabel.rx.text)
//            .disposed(by: disposeBag)
//        
//        viewModel?.petAge
//            .bind(to: puppyAgeLabel.rx.text)
//            .disposed(by: disposeBag)
//        
//        viewModel?.petTags
//            .bind(to: puppyTagLabel.rx.text)
//            .disposed(by: disposeBag)
//        
//        viewModel?.petImage
//            .subscribe(onNext: { [weak self] image in
//                self?.puppyImageView.image = image
//            }).disposed(by: disposeBag)
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConstarints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with pet: Pet) {
        puppyNameLabel.text = pet.name
        puppyAgeLabel.text = "\(pet.age)살"

        puppyTagLabel.text = pet.tag.joined(separator: ", ")
    
        if let url = URL(string: pet.petImage) {
            puppyImageView.kf.setImage(with: url, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            puppyImageView.image = UIImage(named: "defaultProfileImage")
        }
    }
    
    private func setConstarints() {
        [puppyImageView,
        puppyNameLabel,
        puppyAgeLabel,
        puppyTagLabel
        ].forEach{ contentView.addSubview($0) }
        
        puppyImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        puppyNameLabel.snp.makeConstraints {
            $0.top.equalTo(puppyImageView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        puppyAgeLabel.snp.makeConstraints {
            $0.top.equalTo(puppyNameLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        puppyTagLabel.snp.makeConstraints {
            $0.top.equalTo(puppyAgeLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
}
