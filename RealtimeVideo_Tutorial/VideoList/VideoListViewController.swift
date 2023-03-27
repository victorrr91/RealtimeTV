//
//  VideoListViewController.swift
//  RealtimeVideo_Tutorial
//
//  Created by Victor Lee on 2023/03/23.
//

import UIKit
import SnapKit

struct Video {
    let urlString: String
    let title: String
    let description: String
    let image: String
}

class VideoListViewController: UIViewController {

    let urlList : [Video] = [
        Video(urlString: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8", title: "우주로 가는 여행", description: "달나라로 떠납니다", image: "video1"),
        Video(urlString: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8", title: "광고 시작", description: "30분 후 시작 예정", image: "video2"),
        Video(urlString: "https://res.cloudinary.com/dannykeane/video/upload/sp_full_hd/q_80:qmax_90,ac_none/v1/dk-memoji-dark.m3u8", title: "아바타", description: "하나씩 만들어드림 ㄱㄱ", image: "video3"),
        Video(urlString: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8", title: "네덜란드 애니 명작", description: "같이 봅시다", image: "video4")
    ]

    private lazy var videoListTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
        tableView.register(VideoListViewCell.self, forCellReuseIdentifier: "VideoListViewCell")

        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        view.addSubview(videoListTableView)

        videoListTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension VideoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urlList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "VideoListViewCell", for: indexPath
        ) as? VideoListViewCell else {
            return UITableViewCell()
        }
        let data = urlList[indexPath.row]
        cell.configureCell(data: data)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = urlList[indexPath.row]

        let playViewContronller = VideoPlayerViewController()
        playViewContronller.updatePlayerItem(data: data)

        playViewContronller.modalPresentationStyle = .fullScreen
        self.present(playViewContronller, animated: true)
    }
}
