//
//  KakaoMapViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 9/4/24.
//

import CoreLocation
import UIKit

import KakaoMapsSDK

class KakaoMapViewController: UIViewController, MapControllerDelegate {
    
    var coordinate: CLLocationCoordinate2D?
    
    private var mapController: KMController?
    private var mapContainer: KMViewContainer?
    private var _observerAdded: Bool = false
    private var _auth: Bool = false
    private var _appear: Bool = false
    
    private let addressView: UIView = {
        let view = AddressView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        addViews()
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
        let mapPoint: MapPoint
        
        if let coordinate = coordinate {
            mapPoint = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        } else {
            mapPoint = MapPoint(longitude: 126.9053, latitude: 37.5044)
        }
        
        let mapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: mapPoint, defaultLevel: 17)
        mapController?.addView(mapviewInfo)
    }
    
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("MapView 추가 성공: \(viewName), \(viewInfoName)")
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
    
    // MARK: @objc 관련 메서드
    
    @objc
    private func willResignActive(){
        mapController?.pauseEngine()
    }
    
    @objc
    private func didBecomeActive(){
        mapController?.activateEngine()
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
//    
//    //MARK: 레이아웃
//    private func setConstraints() {
//        [
//    }
}

