//
//  VideoListViewCell.swift
//  RealtimeVideo_Tutorial
//
//  Created by Victor Lee on 2023/03/24.
//

import UIKit
import SnapKit

final class VideoListViewCell: UITableViewCell {

    private let thumbnailImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(data: Video) {
        titleLabel.text = data.title
        descriptionLabel.text = data.description
        thumbnailImage.image = UIImage(named: data.image)
    }

    private func setupViews() {
        contentView.addSubview(thumbnailImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)

        thumbnailImage.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.top.equalToSuperview()
            $0.width.equalTo(108)
            $0.height.equalTo(72)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImage.snp.trailing).offset(8)
            $0.top.equalToSuperview().inset(4)
            $0.trailing.equalToSuperview().inset(12)
        }

        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().inset(12)
        }
    }
}
