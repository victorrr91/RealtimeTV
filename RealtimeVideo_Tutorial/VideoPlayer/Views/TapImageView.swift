//
//  TapImageView.swift
//  RealtimeVideo_Tutorial
//
//  Created by Victor Lee on 2023/04/02.
//

import Foundation
import UIKit

enum IconType {
    case rewind
    case forward

    var iconName: UIImage {
        switch self {
        case .rewind: return UIImage(systemName: "gobackward.15")!
        case .forward: return UIImage(systemName: "goforward.15")!
        }
    }
}

class TapImageView: UIView {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0
        imageView.isHidden = true
        imageView.tintColor = .white
        return imageView
    }()

    init(iconType: IconType) {
        imageView.image = iconType.iconName
        super.init(frame: .zero)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(50)
        }
    }
}
