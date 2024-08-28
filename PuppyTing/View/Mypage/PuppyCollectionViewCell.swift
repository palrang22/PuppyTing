import UIKit
import SnapKit

class PuppyCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PuppyCollectionViewCell"
    
    let puppyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    let puppyNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    let puppyInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    let puppyTagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .blue
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [puppyImageView, puppyNameLabel, puppyInfoLabel, puppyTagLabel].forEach { contentView.addSubview($0)
        }
        
        puppyImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.width.height.equalTo(100)
        }
        
        puppyNameLabel.snp.makeConstraints {
            $0.top.equalTo(puppyImageView.snp.top) // 강아지 이름 라벨을 이미지 뷰의 상단에 맞춥니다.
            $0.left.equalTo(puppyImageView.snp.right).offset(10)
            $0.right.equalToSuperview().offset(-10)
        }
        
        puppyInfoLabel.snp.makeConstraints {
            $0.centerY.equalTo(puppyImageView.snp.centerY) // 강아지 Info 라벨을 이미지 뷰의 수직 중심에 맞춥니다.
            $0.left.equalTo(puppyNameLabel.snp.left)
            $0.right.equalToSuperview().offset(-10)
        }
        
        puppyTagLabel.snp.makeConstraints {
            $0.bottom.equalTo(puppyImageView.snp.bottom) // 강아지 Tag 라벨을 이미지 뷰의 하단에 맞춥니다.
            $0.left.equalTo(puppyNameLabel.snp.left)
            $0.right.equalToSuperview().offset(-10)
        }
    }

    // 데이터 설정 메서드
    func configure(with puppy: (name: String, info: String, tag: String)) {
        puppyNameLabel.text = puppy.name
        puppyInfoLabel.text = puppy.info
        puppyTagLabel.text = puppy.tag
        puppyImageView.image = UIImage(systemName: "person.crop.circle") // 기본 이미지 설정
    }
}
