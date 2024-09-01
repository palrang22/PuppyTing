//
//  SearchAddressViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/29/24.
//

import CoreLocation
import MapKit
import UIKit

import SnapKit

class SearchAddressViewController: UIViewController {
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
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
        setDelegate()
    }
    
    private func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        locationManager.delegate = self
        searchCompleter.delegate = self
    }
    
    //MARK: UI 설정 및 레이아웃
    private func setUI() {
        setupKeyboardDismissRecognizer()
        view.backgroundColor = .white
    }
    
    private func setVisibility() {
        if searchResults.isEmpty {
            tableView.isHidden = true
            findLabel.isHidden = false
        } else {
            tableView.isHidden = false
            findLabel.isHidden = true
        }
    }
    
    private func setConstraints() {
        [searchBar, findLabel, tableView]
            .forEach { view.addSubview($0) }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
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
        if let location = locations.last {
            currentLocation = location
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            searchCompleter.region = region
            print("현재 위치 기반으로 검색: \(region)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("현재위치 오류: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("사용자가 위치 접근을 허용하지 않았습니다.")
        case .notDetermined:
            print("위치 서비스 권한이 아직 결정되지 않았습니다.")
            self.locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
    }
}

extension SearchAddressViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        print("검색결과: \(searchResults)")
        setVisibility()
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        print("결과 업데이트 오류")
    }
}

extension SearchAddressViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchCompleter.queryFragment = searchBar.text ?? ""
        print("검색버튼 눌림")
        print("검색어: \"\(searchCompleter.queryFragment)\"")
        searchBar.resignFirstResponder()
    }
}

extension SearchAddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension SearchAddressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchedAddressTableViewCell.id, for: indexPath) as? SearchedAddressTableViewCell else {
            return UITableViewCell()
        }
        let item = searchResults[indexPath.row]
        let address = item.subtitle.isEmpty ? "" : item.subtitle
        cell.config(spot: item.title, address: address)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
}
