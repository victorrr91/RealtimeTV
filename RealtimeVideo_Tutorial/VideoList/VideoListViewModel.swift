//
//  VideoListViewModel.swift
//  RealtimeVideo_Tutorial
//
//  Created by Victor Lee on 2023/04/01.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class VideoListViewModel {
    let disposeBag = DisposeBag()

    var cellData: BehaviorRelay<[Video]> = BehaviorRelay(value: [])
    var selectedVideo: Signal<Video>

    var selectedIndex = PublishRelay<Int>()

    init() {
        cellData.accept(Video.urlList)

        selectedVideo = selectedIndex
            .withLatestFrom(cellData) { $1[$0] }
            .asSignal(onErrorSignalWith: .empty())
    }
}
