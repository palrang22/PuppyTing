//
//  SearchedMapViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/29/24.
//

import CoreLocation
import UIKit

import KakaoMapsSDK
import SnapKit

class SearchedMapViewController: UIViewController, MapControllerDelegate {
    
    var placeName: String?
    var roadAddressName: String?
    var coordinate: CLLocationCoordinate2D?
    
    private var mapController: KMController?
    private var mapContainer: KMViewContainer?
    private var _observerAdded: Bool = false
    private var _auth: Bool = false
    private var _appear: Bool = false
    
    private lazy var selectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .puppyPurple
        button.setTitle("여기로 지정", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.addTarget(self, action: #selector(backToPost), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setConstraints()
    }
    
    deinit {
        // 맵 엔진 정지 및 리소스 해제
        mapController?.pauseEngine()
        mapController?.resetEngine()
    }
    
    private func setupMapView() {
        // 맵 컨테이너 초기화 및 추가
        mapContainer = KMViewContainer(frame: self.view.bounds)
        if let mapContainer = mapContainer {
            self.view.addSubview(mapContainer)
        }
        
        // KMController 생성 및 초기화
        mapController = KMController(viewContainer: mapContainer!)
        mapController?.delegate = self
        
        // 엔진 준비
        mapController?.prepareEngine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        _appear = true
        
        if mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _appear = false
        mapController?.pauseEngine()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObservers()
        mapController?.resetEngine()
    }
    
    func addViews() {
        guard let coordinate = coordinate else {
            print("좌표값 없음")
            return
        }
        
        let mapPoint = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        let mapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: mapPoint, defaultLevel: 17)
        mapController?.addView(mapviewInfo)
    }
    
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("MapView 추가 성공: \(viewName), \(viewInfoName)")
        createLabelLayer()
        createPoiStyle()
        
        // 지도 뷰가 성공적으로 로드되었으니 이제 POI를 추가
        guard let coordinate = coordinate else {
            print("좌표값 없음")
            return
        }
        
        let mapPoint = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        addSelectedLocationPoi(at: mapPoint)
    }

    
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("MapView 추가 실패: \(viewName), \(viewInfoName)")
    }
    
    private func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        _observerAdded = true
    }
    
    private func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        
        _observerAdded = false
    }
    
    @objc
    private func willResignActive(){
        mapController?.pauseEngine()
    }
    
    @objc
    private func didBecomeActive(){
        mapController?.activateEngine()
    }
    
    @objc
    private func backToPost() {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("popToPostView"), object: nil)
        print("버튼 눌림")
    }
    
    //MARK: - POI 관련 메서드들
    
    // Poi 생성을 위한 LabelLayer 생성
    func createLabelLayer() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
        _ = manager.addLabelLayer(option: layerOption)
    }
    
    // Poi 표시 스타일 생성
    func createPoiStyle() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        
        // "poiMarker" 이미지가 존재하는지 확인
        guard let iconImage = UIImage(named: "poiMarker") else {
            print("poiMarker 이미지가 없습니다.")
            return
        }
        
        let iconStyle = PoiIconStyle(symbol: iconImage, anchorPoint: CGPoint(x: 0.0, y: 0.5))
        let poiStyle = PoiStyle(styleID: "DefaultStyle", styles: [
            PerLevelPoiStyle(iconStyle: iconStyle, level: 5)
        ])
        manager.addPoiStyle(poiStyle)
    }
    
    // 선택된 위치에 POI 추가
    func addSelectedLocationPoi(at mapPoint: MapPoint) {
        guard let view = mapController?.getView("mapview") as? KakaoMap else {
            print("MapView가 로드되지 않았습니다.")
            return
        }
        let manager = view.getLabelManager()
        guard let layer = manager.getLabelLayer(layerID: "PoiLayer") else {
            print("POI Layer가 생성되지 않았습니다.")
            return
        }
        
        let poiOption = PoiOptions(styleID: "DefaultStyle")
        poiOption.rank = 0
        if let poi = layer.addPoi(option: poiOption, at: mapPoint) {
            poi.show()
            print("POI 추가 성공")
        } else {
            print("POI 추가 실패")
        }
    }
    
    private func setConstraints() {
        [selectButton].forEach { view.addSubview($0) }
        
        selectButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(44)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
