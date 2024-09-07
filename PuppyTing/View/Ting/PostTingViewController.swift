//
//  PostTingViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/28/24.
//

import CoreLocation
import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class PostTingViewController: UIViewController {
    
    var placeName: String?
    var roadAddressName: String?
    var coordinate: CLLocationCoordinate2D?
    
    var addressSubject = PublishSubject<(String?, String?, CLLocationCoordinate2D?)>()
    
    private let kakaoMapViewController = KakaoMapViewController()
    private let disposeBag = DisposeBag()
    
    //MARK: UI Component 선언
    private lazy var addMapButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "장소 추가"
        config.image = UIImage(systemName: "location.fill.viewfinder")
        config.imagePadding = 10
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .puppyPurple
        config.cornerStyle = .large
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(addMapButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = "언제, 어디서 산책하실 건가요? 산책 일정을 공유하는 퍼피팅 친구를 만나보세요!"
        textView.textColor = .gray
        textView.font = .systemFont(ofSize: 16, weight: .medium)
        textView.delegate = self
        return textView
    }()
    
    // 지도 컨테이너 뷰 (처음에는 숨김)
    private let mapViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.isHidden = true
        return view
    }()

    //MARK: View 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad called")
        setUI()
        setConstraints()
        setupKeyboardDismissRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear called")
        textView.becomeFirstResponder()
    }
    
    //MARK: 메서드
    @objc
    private func addButtonTapped() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("유저 정보가 없습니다.")
            return
        }
        let coordinate = self.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let content = textView.text ?? "내용 없음"
        let model = TingFeedModel(userid: userID,
                                  postid: "",
                                  location: coordinate,
                                  content: content,
                                  time: Date())
        let viewModel = PostingViewModel()
        viewModel.create(collection: "tingFeeds", model: model)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func addMapButtonTapped() {
        let searchAddressVC = SearchAddressViewController()
        
        // SearchAddressViewController가 데이터 방출 시 처리할 구독 설정
        searchAddressVC.mapDataSubject
            .subscribe(onNext: { [weak self] placeName, roadAddressName, coordinate in
                guard let self = self else { return }
                
                // 받은 데이터를 PostTingViewController에 반영
                self.placeName = placeName
                self.roadAddressName = roadAddressName
                self.coordinate = coordinate
                
                // 디버깅용 print 로그
                print("받은 데이터: \(placeName ?? "없음"), \(roadAddressName ?? "없음"), 좌표: \(coordinate?.latitude ?? 0), \(coordinate?.longitude ?? 0)")
                
                // UI 업데이트 - 장소, 주소, 좌표를 지도나 화면에 표시하는 등의 작업
                self.updateMapView()
            }).disposed(by: disposeBag)
        
        // 네비게이션 스택에 SearchAddressViewController 추가
        self.navigationController?.pushViewController(searchAddressVC, animated: true)
    }

    // UI 업데이트 함수 추가
    private func updateMapView() {
        // 지도 컨테이너를 보이도록 설정
        mapViewContainer.isHidden = false
        
        // KakaoMapViewController가 이미 추가되어 있지 않다면 추가
        if kakaoMapViewController.parent == nil {
            // KakaoMapViewController를 자식 뷰 컨트롤러로 추가
            addChild(kakaoMapViewController)
            mapViewContainer.addSubview(kakaoMapViewController.view)
            
            // 제약 조건 설정 (SnapKit 사용)
            kakaoMapViewController.view.snp.makeConstraints { make in
                make.edges.equalToSuperview() // mapViewContainer의 경계에 맞춤
            }
            
            // 자식 뷰 컨트롤러로 이동 완료 처리
            kakaoMapViewController.didMove(toParent: self)
            
            print("KakaoMapViewController가 성공적으로 추가되었습니다.")
        }
        
        // 좌표 설정 및 POI 추가
        if let coordinate = coordinate {
            kakaoMapViewController.setCoordinate(coordinate)
            kakaoMapViewController.addPoi(at: coordinate)
            print("좌표 설정 및 POI 추가 완료: \(coordinate.latitude), \(coordinate.longitude)")
        } else {
            print("좌표가 설정되지 않았습니다.")
        }
    }



    //MARK: UI 설정 및 제약조건 등
    private func setUI() {
        let addButton = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(addButtonTapped))
        view.backgroundColor = .white
        self.navigationItem.title = "퍼피팅 찾기"
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.rightBarButtonItem?.tintColor = .puppyPurple
    }
    
    private func setConstraints() {
        [addMapButton, textView, mapViewContainer]
            .forEach { view.addSubview($0) }
        
        addMapButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(44)
            $0.width.equalTo(100)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(addMapButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        mapViewContainer.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(200)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
}

extension PostTingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
        textView.textColor = .gray
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "언제, 어디서 산책하실 건가요? 산책 일정을 공유하는 퍼피팅 친구를 만나보세요!"
            textView.textColor = .gray
        }
    }
}
