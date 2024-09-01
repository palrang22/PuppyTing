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
    
    private let locationManager = CLLocationManager()
    private let viewModel = TingViewModel()
    private let disposeBag = DisposeBag()
    
    //MARK: UI Components
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소명으로 검색"
        return searchBar
    }()
    
    private let findLabel: UILabel = {
        let label = UILabel()
        label.text = "구체적인 단어로 장소를 찾아보세요!\n예) 스타벅스 당산대로점"
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
        return tableView
    }()

    //MARK: View 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        setupLocationManager()
        bind()
    }
    
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
                self?.viewModel.searchPlaces(keyword: keyword)
                self?.searchBar.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        viewModel.items
            .subscribe(onNext: { [weak self] items in
                guard let self else { return }
                self.tableView.reloadData()
                self.tableView.isHidden = items.isEmpty
                self.findLabel.isHidden = !items.isEmpty
            }).disposed(by: disposeBag)
        
        viewModel.items
            .bind(to: tableView.rx.items(cellIdentifier: SearchedAddressTableViewCell.id,
                                         cellType: SearchedAddressTableViewCell.self)) {
                index, place, cell in
                cell.config(spot: place.placeName, address: place.roadAddressName)
            }.disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
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

//
//extension SearchAddressViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        
//    }
//}
//
extension SearchAddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
//
//extension SearchAddressViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchedAddressTableViewCell.id, for: indexPath) as? SearchedAddressTableViewCell else {
//            return UITableViewCell()
//        }
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 20
//    }
//}
