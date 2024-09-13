import UIKit
import SnapKit

class MyBlockListTableViewCell: UITableViewCell {
    
    static let identifier = "MyBlockListTableViewCell"
    
    private let ProfileImageView: UIImageView = {
        let profileImage = UIImageView()
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.backgroundColor = .clear
        profileImage.tintColor = .black
        profileImage.image = UIImage(systemName: "person.crop.circle")
        profileImage.layer.cornerRadius = 30
        profileImage.layer.masksToBounds = true
        return profileImage
    }()
    
    private let NameLable: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private let BlockcancleButton: UIButton = {
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
    
    // 초기화 메서드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [ProfileImageView, NameLable, BlockcancleButton].forEach { contentView.addSubview($0) }
        
        ProfileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(60)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        NameLable.snp.makeConstraints {
            $0.leading.equalTo(ProfileImageView.snp.trailing).offset(10)
            $0.centerY.equalTo(ProfileImageView.snp.centerY)
        }
        
        BlockcancleButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(44)
        }
        
        BlockcancleButton.addTarget(self, action: #selector(blockCancelTapped), for: .touchUpInside)
           }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 셀 구성 함수(데이터 바인딩)
    func configure(with title: String, image: UIImage?) {
        ProfileImageView.image = image
        NameLable.text = title
    }
    
    @objc private func blockCancelTapped() {
        print("차단 해제 버튼이 눌렸습니다.")
    }
}
