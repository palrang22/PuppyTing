import UIKit

import SnapKit

class PuppyCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    
    static let identifier = "PuppyCollectionViewCell"

    let puppyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        return imageView
    }()

    let puppyNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    let puppyInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    let puppyTagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI

    private func setupUI() {
        [puppyImageView, puppyNameLabel, puppyInfoLabel, puppyTagLabel].forEach { contentView.addSubview($0) }

        puppyImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.width.height.equalTo(100)
        }

        puppyNameLabel.snp.makeConstraints {
            $0.top.equalTo(puppyImageView.snp.top)
            $0.leading.equalTo(puppyImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }

        puppyInfoLabel.snp.makeConstraints {
            $0.centerY.equalTo(puppyImageView.snp.centerY)
            $0.leading.equalTo(puppyNameLabel.snp.leading)
            $0.trailing.equalToSuperview().offset(-10)
        }

        puppyTagLabel.snp.makeConstraints {
            $0.bottom.equalTo(puppyImageView.snp.bottom)
            $0.leading.equalTo(puppyNameLabel.snp.leading)
            $0.trailing.equalToSuperview().offset(-10)
        }
    }

    // MARK: - Configuration

    func configure(with puppy: (name: String, info: String, tag: String, image: UIImage?)) {
        puppyNameLabel.text = puppy.name
        puppyInfoLabel.text = puppy.info
        puppyTagLabel.text = puppy.tag
        puppyImageView.image = puppy.image ?? UIImage(systemName: "person.crop.circle")
    }
    
    func config(puppy: Pet) {
        puppyNameLabel.text = puppy.name
        puppyInfoLabel.text = "\(puppy.age)살"
        var tag = ""
        for i in puppy.tag {
            tag += "\(i), "
        }
        puppyTagLabel.text = tag
        fetchImage(url: puppy.petImage)
    }
    
    private func fetchImage(url: String) {
        NetworkManager.shared.fetchImage(url: url) { image in
            DispatchQueue.main.async {
                self.puppyImageView.image = image
            }
        }
    }
}
