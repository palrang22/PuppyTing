//
//  AddressView.swift
//  PuppyTing
//
//  Created by 김승희 on 9/4/24.
//

import UIKit

import SnapKit

class AddressView: UIView {
    
    private let placeLabel: UILabel = {
        let label = UILabel()
        label.text = "장소이름"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let roadAddressLabel: UILabel = {
        let label = UILabel()
        label.text = "주소이름"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(placeName: String, roadAddressName: String) {
        placeLabel.text = placeName
        roadAddressLabel.text = roadAddressName
    }
    
    private func setupConstraints() {
        backgroundColor = .white
        
        [placeLabel, roadAddressLabel].forEach { stackView.addArrangedSubview($0) }
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
    }
}
