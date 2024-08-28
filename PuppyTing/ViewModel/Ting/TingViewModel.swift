//
//  TingViewModel.swift
//  PuppyTing
//
//  Created by 김승희 on 8/26/24.
//

import UIKit

import RxSwift

//MARK: 로직 수정예정
class TingViewModel {
    let postButtonTapped = PublishSubject<Void>()
    let cellTapped = PublishSubject<IndexPath>()
}
