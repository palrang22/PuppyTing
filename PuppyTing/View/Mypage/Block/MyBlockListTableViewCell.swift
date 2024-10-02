import UIKit

import SnapKit

protocol MyBlockListTableViewCellDelegate: AnyObject {
    func didTapUnblockButton(for member: Member)
}

class MyBlockListTableViewCell: UITableViewCell {
    
    static let identifier = "MyBlockListTableViewCell"
    
    weak var delegate: MyBlockListTableViewCellDelegate?
    private var member: Member?
    
    private let profileImageView: UIImageView = {
        let profileImage = UIImageView()
        profileImage.image = UIImage(named: "defaultProfileImage")
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.backgroundColor = .clear
        profileImage.tintColor = .black
        profileImage.layer.cornerRadius = 30
        profileImage.layer.masksToBounds = true
        return profileImage
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let unblockButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("차단 해제", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = UIColor.puppyPurple.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.puppyPurple.withAlphaComponent(1)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [profileImageView, nameLabel, unblockButton].forEach { contentView.addSubview($0) }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(60)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
            $0.centerY.equalTo(profileImageView.snp.centerY)
        }
        
        unblockButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(44)
        }
        
        unblockButton.addTarget(self, action: #selector(unblockButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with member: Member) {
        self.member = member
        nameLabel.text = member.nickname
        
        // 프로필 이미지 로드
        if !member.profileImage.isEmpty {
            loadImage(from: member.profileImage)
        } else {
            profileImageView.image = UIImage(named: "defaultProfileImage") // 기본 프로필 이미지 사용
        }
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("이미지 로드 실패: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }
    
    @objc private func unblockButtonTapped() {
        guard let member = member else { return }
        delegate?.didTapUnblockButton(for: member)
    }
}
