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
    private var coordinate: CLLocationCoordinate2D?  // 좌표를 저장하는 변수
    
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
        
        // KMController 생성 및 초기화
        mapController = KMController(viewContainer: mapContainer!)
        mapController?.delegate = self
        
        // 엔진 준비
        mapController?.prepareEngine()
        
        // 좌표가 이미 설정된 경우 지도를 생성
        if coordinate != nil {
            addViews()  // addViews는 파라미터 없이 좌표를 내부에서 사용
        }
    }

    
    // 좌표에 따라 지도를 생성하는 메서드
    func addViews() {
        let defaultPosition: MapPoint
        
        // 좌표가 설정되어 있으면 해당 좌표로 지도 중심을 설정
        if let coordinate = coordinate {
            defaultPosition = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        } else {
            // 기본 좌표 설정
            defaultPosition = MapPoint(longitude: 127.108678, latitude: 37.402001)
        }
        
        let mapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 17)
        mapController?.addView(mapviewInfo)
    }
    
    // 지도 생성이 성공했을 때 호출되는 delegate
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        createLabelLayer()
        createPoiStyle()
        
        print("MapView 추가 성공")
        if let coordinate = coordinate {
            addPoi(at: coordinate)
        }
    }
    
    // 지도 생성이 실패했을 때 호출되는 delegate
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("MapView 추가 실패")
    }
    
    // 좌표 설정 메서드: 외부에서 좌표를 받아와서 지도 생성
    public func setCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        
        // 지도 엔진이 준비된 상태에서만 addViews() 호출
        if mapController?.isEngineActive == true {
            addViews()  // 좌표가 설정되면 바로 지도 생성
        }
    }
    
    //MARK: POI
    
    func createLabelLayer() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        
        // POI 레이어 추가
        let layerOption = LabelLayerOptions(layerID: "PoiLayer",
                                            competitionType: .none,
                                            competitionUnit: .symbolFirst,
                                            orderType: .rank,
                                            zOrder: 100)
        _ = manager.addLabelLayer(option: layerOption)
    }
    
    func createPoiStyle() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        
        // "poiMarker" 이미지 스타일 추가
        guard let iconImage = UIImage(named: "poiMarker") else {
            print("poiMarker 이미지가 없습니다.")
            return
        }
        
        let iconStyle = PoiIconStyle(symbol: iconImage, anchorPoint: CGPoint(x: 0.0, y: 0.5))
        
        let poiStyle = PoiStyle(styleID: "DefaultStyle", styles: [
            PerLevelPoiStyle(iconStyle: iconStyle, level: 5)
        ])
        
        manager.addPoiStyle(poiStyle)
        print("POI 스타일 추가 성공")
    }
    
    // POI 추가 메서드
    public func addPoi(at coordinate: CLLocationCoordinate2D) {
        let mapPoint = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        addSelectedLocationPoi(at: mapPoint)
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
