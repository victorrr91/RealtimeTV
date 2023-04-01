//
//  VideoListViewController.swift
//  RealtimeVideo_Tutorial
//
//  Created by Victor Lee on 2023/03/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class VideoListViewController: UIViewController {

    let disposeBag = DisposeBag()

    private lazy var videoListTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
        
        tableView.register(VideoListViewCell.self, forCellReuseIdentifier: "VideoListViewCell")

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        title = "생방송 채널"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func bind(viewModel: VideoListViewModel) {
        viewModel.cellData
            .bind(to: videoListTableView.rx.items) { tv, row, data in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "VideoListViewCell", for: IndexPath(row: row, section: 0))  as? VideoListViewCell else { return UITableViewCell() }
                cell.configureCell(data: data)
                return cell
            }
            .disposed(by: disposeBag)

        videoListTableView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.selectedIndex)
            .disposed(by: disposeBag)

        viewModel.selectedVideo
            .emit(to: self.rx.selectVideo)
            .disposed(by: disposeBag)
    }

    private func setupViews() {
        view.addSubview(videoListTableView)

        videoListTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
    }
}


extension Reactive where Base: VideoListViewController {

    var selectVideo: Binder<Video> {
        return Binder(base) { base, video in
            let playViewContronller = VideoPlayerViewController()
            playViewContronller.updatePlayerItem(data: video)

            playViewContronller.modalPresentationStyle = .fullScreen
            base.present(playViewContronller, animated: true)
        }
    }
}
