import UIKit
import SnapKit

class MyFeedTableViewCell: UITableViewCell {
    
    static let identifier = "MyFeedTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .lightGray
        label.numberOfLines = 0 // 여러 줄 허용
        return label
    }()
    
    // 초기화 메서드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [titleLabel, dateLabel, descriptionLabel].forEach { contentView.addSubview($0) }
     
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualTo(dateLabel.snp.leading).offset(-10)
        }

        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.lessThanOrEqualTo(100)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.left.equalTo(titleLabel)
            $0.right.equalTo(dateLabel.snp.right)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 셀 구성 함수 (데이터 바인딩)
    func configure(with title: String, description: String, datelabel: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        dateLabel.text = datelabel
    }
}
