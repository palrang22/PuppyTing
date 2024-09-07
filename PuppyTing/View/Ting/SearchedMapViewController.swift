//
//  SearchedMapViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/29/24.
//

import CoreLocation
import UIKit

import KakaoMapsSDK
import RxCocoa
import RxSwift
import SnapKit

class SearchedMapViewController: UIViewController {
    
    let mapDataSubject = PublishSubject<(String?, String?, CLLocationCoordinate2D?)>()
    private let disposeBag = DisposeBag()
    
    var placeName: String?
    var roadAddressName: String?
    var coordinate: CLLocationCoordinate2D?
    
    private let kakaoMapViewController = KakaoMapViewController()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "closeButton"), for: .normal)
        return button
    }()
    
    private lazy var selectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .puppyPurple
        button.setTitle("여기로 지정", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        return button
    }()
    
    private let addressView: UIView = {
        let view = AddressView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(kakaoMapViewController.view)
        setConstraints()
        configMapInfo()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kakaoMapViewController.activateEngine()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kakaoMapViewController.pauseEngine()
    }
    
    func configMapInfo() {
        if let placeName = placeName, let roadAddressName = roadAddressName {
            (addressView as? AddressView)?.config(placeName: placeName, roadAddressName: roadAddressName)
        }

        if let coordinate = coordinate {
            kakaoMapViewController.setCoordinate(coordinate)
            kakaoMapViewController.addPoi(at: coordinate)
        }
    }
    
    func bind() {
        closeButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        selectButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.mapDataSubject.onNext((self.placeName, self.roadAddressName, self.coordinate))
                self.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
    }
    
    private func setConstraints() {
        [kakaoMapViewController.view, closeButton, addressView, selectButton].forEach { view.addSubview($0) }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        addressView.snp.makeConstraints {
            $0.bottom.equalTo(selectButton.snp.top).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(100)
        }
        
        selectButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.height.equalTo(44)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        kakaoMapViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
