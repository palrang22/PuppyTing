//
//  KakaoMapViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 9/4/24.
//

import CoreLocation
import UIKit

import KakaoMapsSDK
import RxCocoa
import RxSwift

class KakaoMapViewController: UIViewController, MapControllerDelegate {
    
    private var mapController: KMController?
    private var mapContainer: KMViewContainer?
    private var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setConstraints()
    }
    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        mapContainer?.removeFromSuperview()
        mapController = nil
    }
    
    private func setupMapView() {
        mapContainer = KMViewContainer(frame: self.view.bounds)
        
        // KMController 생성 및 초기화
        mapController = KMController(viewContainer: mapContainer!)
        mapController?.delegate = self
        
        // 엔진 준비
        mapController?.prepareEngine()
        
        // 좌표가 이미 설정된 경우 지도를 생성
        if coordinate != nil {
            addViews()
        }
    }
    
    func addViews() {
        let defaultPosition: MapPoint
        
        if let coordinate = coordinate {
            defaultPosition = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        } else {
            defaultPosition = MapPoint(longitude: 127.108678, latitude: 37.402001)
        }
        
        let mapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 17)
        mapController?.addView(mapviewInfo)
    }
    
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("MapView \(viewName) successfully added")
        createLabelLayer()
        createPoiStyle()
        
        if let coordinate = coordinate {
            addPoi(at: coordinate)
        }
    }
    
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("MapView \(viewName) failed to add")
    }
    
    public func setCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        print("Coordinate set: \(coordinate.latitude), \(coordinate.longitude)")
        
        if mapController?.isEngineActive == true {
            addViews()
        }
    }
    
    func createLabelLayer() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else {
            return
        }
        let manager = view.getLabelManager()
        let layerOption = LabelLayerOptions(layerID: "PoiLayer",
                                            competitionType: .none,
                                            competitionUnit: .symbolFirst,
                                            orderType: .rank,
                                            zOrder: 10000)
        _ = manager.addLabelLayer(option: layerOption)
    }
    
    func createPoiStyle() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else {
            return
        }
        let manager = view.getLabelManager()
        
        guard let iconImage = UIImage(named: "poiMarker") else {
            return
        }
        
        let iconStyle = PoiIconStyle(symbol: iconImage, anchorPoint: CGPoint(x: 0.0, y: 0.5))
        let poiStyle = PoiStyle(styleID: "DefaultStyle", styles: [PerLevelPoiStyle(iconStyle: iconStyle, level: 0)])
        manager.addPoiStyle(poiStyle)
    }
    
    func addPoi(at coordinate: CLLocationCoordinate2D) {
        print("Adding POI at coordinate: \(coordinate.latitude), \(coordinate.longitude)")
        let mapPoint = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        addSelectedLocationPoi(at: mapPoint)
    }
    
    func addSelectedLocationPoi(at mapPoint: MapPoint) {
        guard let view = mapController?.getView("mapview") as? KakaoMap else {
            return
        }
        let manager = view.getLabelManager()
        guard let layer = manager.getLabelLayer(layerID: "PoiLayer") else {
            return
        }
        
        let poiOption = PoiOptions(styleID: "DefaultStyle")
        poiOption.rank = 0
        if let poi = layer.addPoi(option: poiOption, at: mapPoint) {
            poi.show()
        } else {
            print("Failed to add POI")
        }
    }

    
    // 엔진 활성화
    public func activateEngine() {
        mapController?.activateEngine()
    }
    
    // 엔진 비활성화
    public func pauseEngine() {
        mapController?.pauseEngine()
    }
    
    // 엔진 리셋
    public func resetEngine() {
        mapController?.resetEngine()
    }
    
    private func setConstraints() {
        if let mapContainer = mapContainer {
            view.addSubview(mapContainer)
            mapContainer.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        } else {
            print("MapContainer 생성 실패")
        }
    }
}
