//
//  SearchAddressViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/29/24.
//

import MapKit
import UIKit

import SnapKit

class SearchAddressViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var searchResult = [MKMapItem]()
    
    //MARK: UI Components
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소명으로 검색"
        searchBar.delegate = self
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchedAddressTableViewCell.self, forCellReuseIdentifier: SearchedAddressTableViewCell.id)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        return tableView
    }()

    //MARK: View 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    //MARK: Mapkit Search 관련 메서드
    private func searchButtonTapped(searchBar: UISearchBar) {
        guard let searchText = searchBar.text,
              let location = locationManager.location,
              !searchText.isEmpty else { return }
        searchPlaces(searchText: searchText, location: location)
    }
    
    private func searchPlaces(searchText: String, location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self,
                  let response = response else {
                print("에러")
                return
            }
            searchResult = response.mapItems.prefix(20).map { $0 }
            setVisibility()
            tableView.reloadData()
            print(searchResult)
        }
    }
    
    //MARK: UI 설정 및 레이아웃
    private func setUI() {
        view.backgroundColor = .white
    }
    
    private func setVisibility() {
        if searchResult.isEmpty {
            tableView.isHidden = true
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
            $0.top.equalTo(searchBar)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension SearchAddressViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchButtonTapped(searchBar: searchBar)
        searchBar.resignFirstResponder()
    }
}

extension SearchAddressViewController: UITableViewDelegate {
    
}

extension SearchAddressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchedAddressTableViewCell.id, for: indexPath) as? SearchedAddressTableViewCell else {
            return UITableViewCell()
        }
        let item = searchResult[indexPath.row]
        cell.config(spot: item.name ?? "장소", address: item.placemark.title ?? "주소주소주소주소")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
}
