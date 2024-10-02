//
//  SearchedAddressTableViewCell.swift
//  PuppyTing
//
//  Created by 김승희 on 8/29/24.
//

import UIKit

import SnapKit

class SearchedAddressTableViewCell: UITableViewCell {
    static let id = "searchAddressTableViewCell"
    
    private let spotLabel: UILabel = {
        let label = UILabel()
        label.text = "장소"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "주소주소주소주소주소주소주소주소주소"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        [spotLabel, addressLabel]
            .forEach { stackView.addArrangedSubview($0) }
        [stackView]
            .forEach { contentView.addSubview($0) }
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    func config(spot: String, address: String) {
        spotLabel.text = spot
        addressLabel.text = address
    }
    
}
