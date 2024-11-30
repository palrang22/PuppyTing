//
//  SearchAddressViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/29/24.
//

import CoreLocation
import UIKit

import RxCocoa
import RxSwift
import SnapKit

class SearchAddressViewController: UIViewController {
    let mapDataSubject = PublishSubject<(String?, String?, CLLocationCoordinate2D?)>()
    
    private let locationManager = CLLocationManager()
    private let viewModel = TingViewModel()
    private let disposeBag = DisposeBag()
    private var ifSearchButtonTapped = false
    
    //MARK: UI Components
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소명으로 검색"
        return searchBar
    }()
    
    private let findLabel: UILabel = {
        let label = UILabel()
        label.text = "2자 이상의 단어로 반경 10km 이내의 장소를 찾아보세요!\n예) 스타벅스 당산대로점"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchedAddressTableViewCell.self, forCellReuseIdentifier: SearchedAddressTableViewCell.id)
        tableView.isHidden = true
        tableView.isUserInteractionEnabled = true
        return tableView
    }()

    //MARK: View 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        setupLocationManager()
        bind()
        setGesture()
        NotificationCenter.default.addObserver(self, selector: #selector(popView), name: Notification.Name("popToPostView"), object: nil)
    }
    
    //MARK: Delegate
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK: ViewModel bind
    private func bind() {
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] keyword in
                self?.ifSearchButtonTapped = true
                self?.viewModel.searchPlaces(keyword: keyword)
                self?.searchBar.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        viewModel.items
            .subscribe(onNext: { [weak self] items in
                guard let self else { return }
                self.tableView.reloadData()
                self.tableView.isHidden = items.isEmpty
                self.findLabel.isHidden = !items.isEmpty
                
                if ifSearchButtonTapped && items.isEmpty {
                    okAlert(title: "검색결과 없음", message: "검색 결과가 없습니다. 2자 이상의 다른 키워드로 검색해보세요.")
                }
            }).disposed(by: disposeBag)
        
        viewModel.items
            .bind(to: tableView.rx.items(cellIdentifier: SearchedAddressTableViewCell.id,
                                         cellType: SearchedAddressTableViewCell.self)) {
                index, place, cell in
                cell.config(spot: place.placeName, address: place.roadAddressName)
            }.disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Place.self)
            .subscribe(onNext: { [weak self] place in
                guard let self = self else { return }
                self.searchBar.resignFirstResponder()
                
                let detailVC = SearchedMapViewController()
                detailVC.placeName = place.placeName
                detailVC.roadAddressName = place.roadAddressName
                if let latitude = Double(place.y), let longitude = Double(place.x) {
                    detailVC.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                
                // detailVC에서 방출된 데이터를 받아 처리
                detailVC.mapDataSubject
                    .subscribe(onNext: { [weak self] placeName, roadAddressName, coordinate in
                        guard let self = self else { return }
                        
                        // 받아온 데이터로 처리
                        if let coordinate = coordinate {
                            // 선택된 데이터를 상위 컨트롤러의 mapDataSubject로 방출
                            self.mapDataSubject.onNext((placeName, roadAddressName, coordinate))
                            // 화면 이동
                            self.navigationController?.popViewController(animated: true)
                        }
                    }).disposed(by: self.disposeBag)
                
                // detailVC를 fullScreen으로 모달 표시
                detailVC.modalPresentationStyle = .fullScreen
                self.present(detailVC, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func popView() {
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK: UI 설정 및 레이아웃
    private func setUI() {
        setupKeyboardDismissRecognizer()
        view.backgroundColor = .white
    }
    
    private func setConstraints() {
        [searchBar, findLabel, tableView]
            .forEach { view.addSubview($0) }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        findLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension SearchAddressViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        viewModel.updateLocation(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("현재 위치 가져올 수 없음")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("위치 서비스 접근이 제한되었습니다.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
    }
}

extension SearchAddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
