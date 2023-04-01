//
//  VideoPlayerViewModel.swift
//  RealtimeVideo_Tutorial
//
//  Created by Victor Lee on 2023/03/31.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class VideoPlayerViewModel {

    let disposeBag = DisposeBag()
    
    var isLandscape: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var shouldShowControl: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    var controlButtonTapped: BehaviorRelay<Bool> = BehaviorRelay(value: true)

    init() {
        let clickEvent = Observable.merge(
            shouldShowControl.asObservable(),
            controlButtonTapped.asObservable()
        )

        clickEvent
            .filter{ $0 == true }
            .flatMapLatest { tapNumber -> Observable<Int> in
                return Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            }
            .filter { $0 == 2 }
            .map { _ in false }
            .bind(onNext: shouldShowControl.accept(_:))
            .disposed(by: disposeBag)

        NotificationCenter.default
            .rx.isLandScape(UIDevice.orientationDidChangeNotification)
            .subscribe(onNext: { [weak self] value in
                self?.isLandscape.accept(value)
            }).disposed(by: disposeBag)
    }
}
