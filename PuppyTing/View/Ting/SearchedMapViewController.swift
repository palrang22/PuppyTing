//
//  SearchedMapView.swift
//  PuppyTing
//
//  Created by 김승희 on 8/29/24.
//

import UIKit

import KakaoMapsSDK

class SearchedMapViewController: UIViewController, MapControllerDelegate {
    
    private var mapController: KMController?
    private var mapContainer: KMViewContainer?
    private var _observerAdded: Bool = false
    private var _auth: Bool = false
    private var _appear: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    deinit {
        // GPU 작업이 완료되기를 대기
        mapController?.pauseEngine()
        DispatchQueue.global().async {
            // GPU에서 모든 작업이 완료될 때까지 대기
            self.mapController?.resetEngine()
            DispatchQueue.main.async {
                self.mapContainer?.removeFromSuperview()
                self.mapController = nil
                self.mapContainer = nil
            }
        }
        print("deinit")
    }

    private func setupMapView() {
        // mapContainer를 초기화하고 이를 view에 추가
        mapContainer = KMViewContainer(frame: self.view.bounds)
        if let mapContainer = mapContainer {
            self.view.addSubview(mapContainer)
        }

        // KMController 생성 및 초기화
        mapController = KMController(viewContainer: mapContainer!)
        mapController?.delegate = self
        
        // Engine 준비
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !_appear {
            addViews()
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
        // 지도 뷰 추가 로직
        let defaultPosition = MapPoint(longitude: 127.108678, latitude: 37.402001)
        let mapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 7)
        
        mapController?.addView(mapviewInfo)
    }
    
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("MapView 추가 성공: \(viewName), \(viewInfoName)")
    }

    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("MapView 추가 실패: \(viewName), \(viewInfoName)")
    }

    func containerDidResized(_ size: CGSize) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        mapView.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
    }

    func viewWillDestroyed(_ view: ViewBase) {
        // 뷰가 삭제될 때 호출
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

    @objc private func willResignActive(){
        mapController?.pauseEngine()
    }

    @objc private func didBecomeActive(){
        mapController?.activateEngine()
    }

    private func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        
        UIView.animate(withDuration: 0.4,
                       delay: duration - 0.4,
                       options: .curveEaseOut,
                       animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
}
