//
//  PostTingViewController.swift
//  PuppyTing
//
//  Created by 김승희 on 8/28/24.
//

import CoreLocation
import UIKit

import FirebaseAuth
import PhotosUI
import RxCocoa
import RxSwift
import SnapKit

class PostTingViewController: UIViewController {
    
    var placeName: String?
    var roadAddressName: String?
    var coordinate: CLLocationCoordinate2D?
    var selectedImages = [UIImage]()
    
    var addressSubject = PublishSubject<(String?, String?, CLLocationCoordinate2D?)>()
    
    private let viewModel = PostingViewModel.shared
    private let kakaoMapViewController = KakaoMapViewController()
    private var textViewHeightConstraint: Constraint?
    private let disposeBag = DisposeBag()
    
    //MARK: UI Component 선언
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private lazy var addMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("장소", for: .normal)
        button.setImage(UIImage(systemName: "location.fill.viewfinder"), for: .normal)
        button.tintColor = .puppyPurple
        button.setTitleColor(.puppyPurple, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.puppyPurple.cgColor
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(addMapButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("사진", for: .normal)
        button.setImage(UIImage(systemName: "photo.badge.plus"), for: .normal)
        button.tintColor = .puppyPurple
        button.setTitleColor(.puppyPurple, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.puppyPurple.cgColor
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        return button
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = "언제, 어디서 산책하실 건가요? 산책 일정을 공유하는 퍼피팅 친구를 만나보세요!\n\n부적절하거나 불쾌감을 줄 수 있는 컨텐츠 작성 시 이용이 제한될 수 있습니다."
        textView.textColor = .gray
        textView.font = .systemFont(ofSize: 16, weight: .medium)
        textView.isScrollEnabled = false
        textView.delegate = self
        return textView
    }()
    
    private var imageStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .fill
        stack.layer.cornerRadius = 5
        stack.spacing = 10
        return stack
    }()
    
    private let imageScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()

    //MARK: View 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        setupKeyboardDismissRecognizer()
    }
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    //MARK: 메서드
    @objc
    private func addButtonTapped() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        if textView.text.isEmpty || textView.text == "언제, 어디서 산책하실 건가요? 산책 일정을 공유하는 퍼피팅 친구를 만나보세요!\n\n부적절하거나 불쾌감을 줄 수 있는 컨텐츠 작성 시 이용이 제한될 수 있습니다." {
            okAlert(title: "주의", message: "게시글 내용을 작성해주세요!")
            return
        }
        
        let coordinate = self.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let content = textView.text ?? "내용 없음"
        
        viewModel.uploadImages(images: selectedImages)
            .flatMapCompletable { [weak self] photoUrls in
                guard let self else { return .empty() }
                let model = TingFeedModel(userid: userID,
                                          postid: UUID().uuidString,
                                          location: coordinate,
                                          content: content,
                                          time: Date(),
                                          photoUrl: photoUrls)
                return self.viewModel.create(collection: "tingFeeds", model: model)
            }
            .subscribe(onCompleted: { [weak self] in
                self?.navigationController?.popViewController(animated: true)},
                       onError: { [weak self] error in
                self?.okAlert(title: "에러", message: "게시물 추가에 실패했습니다. 관리자에게 문의해주세요.")
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    private func addMapButtonTapped() {
        let searchAddressVC = SearchAddressViewController()

        searchAddressVC.mapDataSubject
            .subscribe(onNext: { [weak self] placeName, roadAddressName, coordinate in
                guard let self = self else { return }
                
                self.placeName = placeName
                self.roadAddressName = roadAddressName
                self.coordinate = coordinate
                
                print("받은 데이터: \(placeName ?? "없음"), \(roadAddressName ?? "없음"), 좌표: \(coordinate?.latitude ?? 0), \(coordinate?.longitude ?? 0)")

                if self.coordinate != nil {
                    self.addMapButton.setTitle("다시 설정", for: .normal)
                }
            }).disposed(by: disposeBag)
        
        self.navigationController?.pushViewController(searchAddressVC, animated: true)
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
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [addMapButton, addImageButton, textView, imageScrollView]
            .forEach { contentView.addSubview($0) }
        
        imageScrollView.addSubview(imageStack)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        imageStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        addMapButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(40)
            $0.width.equalTo(80)
        }
        
        addImageButton.snp.makeConstraints {
            $0.centerY.equalTo(addMapButton)
            $0.leading.equalTo(addMapButton.snp.trailing).offset(10)
            $0.height.equalTo(40)
            $0.width.equalTo(80)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(addMapButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            self.textViewHeightConstraint = $0.height.equalTo(200).constraint
        }
        
        imageScrollView.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(80)
            $0.bottom.equalToSuperview()
        }
    }
}

extension PostTingViewController: UITextViewDelegate {
    internal func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray {
            textView.text = nil
            textView.textColor = .black
            
        }
    }
    
    internal func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "언제, 어디서 산책하실 건가요? 산책 일정을 공유하는 퍼피팅 친구를 만나보세요!\n\n부적절하거나 불쾌감을 줄 수 있는 컨텐츠 작성 시 이용이 제한될 수 있습니다."
            textView.textColor = .gray
        }
    }
    
    private func bind() {
        textView.rx.text
            .subscribe(onNext: { [weak self] _ in
                self?.setTextViewHeight()
            })
            .disposed(by: disposeBag)
    }
    
    private func setTextViewHeight() {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        textViewHeightConstraint?.update(offset: size.height)
        view.layoutIfNeeded()
    }
}

extension PostTingViewController: PHPickerViewControllerDelegate {
    @objc func openImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10 // 10개까지 선택
        // config.filter = .images // 모든 사진과 동영상
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let dispatchGroup = DispatchGroup()
        var loadedImages = [UIImage]()
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    if let image = image as? UIImage, let self {
                        loadedImages.append(image)
                        DispatchQueue.main.async {
                            self.addImageToStackView(image: image)
                        }
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.selectedImages = loadedImages
        }
    }
    
    private func addImageToStackView(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.isUserInteractionEnabled = true
        imageView.snp.makeConstraints { $0.width.height.equalTo(80) }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapImageToRemove))
        imageView.addGestureRecognizer(tapGesture)
        
        imageStack.addArrangedSubview(imageView)
    }
    
    @objc private func tapImageToRemove(sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        
        print("tapped")
        
        imageStack.removeArrangedSubview(imageView)
        imageView.removeFromSuperview()
        
        if let idx = selectedImages.firstIndex(where: { $0 == imageView.image }) {
            selectedImages.remove(at: idx)
        }
    }
}
