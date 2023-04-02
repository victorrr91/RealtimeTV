//
//  NotificationCenter+Rx.swift
//  RealtimeVideo_Tutorial
//
//  Created by Victor Lee on 2023/03/31.
//

import Foundation
import RxSwift
import UIKit

extension Reactive where Base : NotificationCenter {

    func isLandScape(_ name: Notification.Name?, object: AnyObject? = nil)
    -> Observable<Bool> {
        return notification(name)
            .map { _ in
                if  UIDevice.current.orientation.isLandscape {
                    return true
                } else if UIDevice.current.orientation == .portraitUpsideDown {
                    return true
                }
                return false
            }
    }
}
