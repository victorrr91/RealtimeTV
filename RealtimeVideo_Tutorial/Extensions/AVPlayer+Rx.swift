//
//  AVPlayer+Rx.swift
//  RealtimeVideo_Tutorial
//
//  Created by Victor Lee on 2023/03/24.
//

import AVFoundation
import RxSwift
import RxCocoa

extension Reactive where Base: AVPlayer {
    public var rate: Observable<Float> {
        return self.observe(Float.self, #keyPath(AVPlayer.rate))
            .map { $0 ?? 0 }
    }

    public var currentItem: Observable<AVPlayerItem?> {
        return observe(AVPlayerItem.self, #keyPath(AVPlayer.currentItem))
    }

    public var status: Observable<Bool> {
        return self.observe(AVPlayer.Status.self, #keyPath(AVPlayer.status))
            .compactMap { $0?.rawValue == 1 }
    }

    public var error: Observable<NSError?> {
        return self.observe(NSError.self, #keyPath(AVPlayer.error))
    }

    @available(iOS 10.0, tvOS 10.0, macOS 10.12, *)
    public var reasonForWaitingToPlay: Observable<AVPlayer.WaitingReason?> {
        return self.observe(AVPlayer.WaitingReason.self, #keyPath(AVPlayer.reasonForWaitingToPlay))
    }

    @available(iOS 10.0, tvOS 10.0, *, OSX 10.12, *)
    public var timeControlStatus: Observable<AVPlayer.TimeControlStatus> {
        return self.observe(AVPlayer.TimeControlStatus.self, #keyPath(AVPlayer.timeControlStatus))
            .map { $0 ?? .waitingToPlayAtSpecifiedRate }
    }

    public func periodicTimeObserver(interval: CMTime) -> Observable<CMTime> {
        return Observable.create { observer in
            let t = self.base.addPeriodicTimeObserver(forInterval: interval, queue: nil) { time in
                observer.onNext(time)
            }

            return Disposables.create { self.base.removeTimeObserver(t) }
        }
    }

    public func boundaryTimeObserver(times: [CMTime]) -> Observable<Void> {
        return Observable.create { observer in
            let timeValues = times.map() { NSValue(time: $0) }
            let t = self.base.addBoundaryTimeObserver(forTimes: timeValues, queue: nil) {
                observer.onNext(())
            }

            return Disposables.create { self.base.removeTimeObserver(t) }
        }
    }
}
