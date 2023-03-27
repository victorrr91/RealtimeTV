//
//  VideoPlayerViewController.swift
//  RealtimeVideo_Tutorial
//
//  Created by Victor Lee on 2023/03/24.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import SnapKit

class VideoPlayerViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private var isLandscape: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    private var movieUrl: URL? = nil

    let player = AVPlayer()
    private let playerView = PlayerView()

    private let bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()

    private let videoControlView = UIView()

    private let timeSlider: UISlider = {
        let timeSlider = UISlider()
        timeSlider.maximumTrackTintColor = .gray
        timeSlider.minimumTrackTintColor = .gray
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        timeSlider.setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: config), for: .normal)

        timeSlider.addTarget(self, action: #selector(timeSliderDidChange(_:)), for: .valueChanged)
        return timeSlider
    }()

    private let startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .systemGray6
        button.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return button
    }()

    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .gray
        button.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        return button
    }()

    private lazy var rewindButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward.15"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(didTapRewindButton), for: .touchUpInside)
        return button
    }()

    private lazy var forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.15"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(didTapforwardButton), for: .touchUpInside)
        return button
    }()

    private lazy var fullScreenButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(didTapfullScreenButton), for: .touchUpInside)
        return button
    }()

    private lazy var minimizeScreenButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(didTapminimizeScreenButton), for: .touchUpInside)
        return button
    }()

    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()

    func updatePlayerItem(data: Video) {
        guard let movieUrl = URL(string: data.urlString) else {
            return
        }

        self.movieUrl = movieUrl
        let newAsset = AVAsset(url: movieUrl)
        let newItem = AVPlayerItem(asset: newAsset)

        self.player.replaceCurrentItem(with: AVPlayerItem(asset: newAsset))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayerObservers()
        setupViewsForPotrait()

        guard let movieUrl = movieUrl else { return }
        let asset = AVURLAsset(url: movieUrl)

        loadPropertyValues(forAsset: asset)

        showVideoControl()

        setRecognizer()
    }



    override func viewWillAppear(_ animated: Bool) {
        player.play()

        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        player.pause()
        isLandscape.accept(false)

        super.viewWillDisappear(animated)
    }

    //MARK: Set animations
    func setRecognizer() {
        let tapOnce = UITapGestureRecognizer(target: self, action: #selector(didTapOnce))
        playerView.addGestureRecognizer(tapOnce)
    }

    @objc
    func didTapOnce() {
        showVideoControl()
    }

    func showVideoControl() {
        videoControlView.isHidden = false
        videoControlView.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.videoControlView.fadeOut(0.8)
        }
    }


    private func setupViewsForPotrait() {
        view.backgroundColor = .systemBackground
        view.subviews.forEach { $0.snp.removeConstraints() }
        view.subviews.forEach { $0.removeFromSuperview() }
        minimizeScreenButton.removeFromSuperview()

        view.addSubview(playerView)
        view.addSubview(videoControlView)
        let views = [
            bgView,
            closeButton,
            timeSlider,
            startTimeLabel,
            durationLabel,
            playPauseButton,
            rewindButton,
            forwardButton,
            fullScreenButton,
        ]

        views.forEach { videoControlView.addSubview($0)}

        let iconSize: Float = 20

        playerView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(240)
        }

        videoControlView.snp.makeConstraints {
            $0.edges.equalTo(playerView)
        }

        bgView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(videoControlView)
            $0.height.equalTo(40)
        }

        rewindButton.snp.makeConstraints {
            $0.leading.equalTo(videoControlView).inset(8)
            $0.bottom.equalTo(videoControlView).inset(12)
            $0.width.height.equalTo(iconSize)
        }
        playPauseButton.snp.makeConstraints {
            $0.leading.equalTo(rewindButton.snp.trailing).offset(4)
            $0.bottom.equalTo(rewindButton)
            $0.width.height.equalTo(iconSize)
        }

        forwardButton.snp.makeConstraints {
            $0.leading.equalTo(playPauseButton.snp.trailing).offset(4)
            $0.bottom.equalTo(rewindButton)
            $0.width.height.equalTo(iconSize)
        }

        timeSlider.snp.makeConstraints {
            $0.leading.equalTo(forwardButton.snp.trailing).offset(12)
            $0.centerY.equalTo(forwardButton)
            $0.trailing.equalTo(fullScreenButton.snp.leading).offset(-24)
        }

        startTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(timeSlider)
            $0.bottom.equalTo(videoControlView).inset(4)
        }

        durationLabel.snp.makeConstraints {
            $0.trailing.equalTo(timeSlider)
            $0.bottom.equalTo(videoControlView).inset(4)
        }

        fullScreenButton.snp.makeConstraints {
            $0.trailing.equalTo(videoControlView).inset(8)
            $0.bottom.equalTo(rewindButton)
            $0.width.height.equalTo(iconSize)
        }

        closeButton.snp.makeConstraints {
            $0.leading.top.equalTo(playerView).inset(8)
            $0.width.height.equalTo(30)
        }
    }

    private func setupViewsForLandScape() {
        view.backgroundColor = .black
        view.subviews.forEach { $0.snp.removeConstraints() }
        view.subviews.forEach { $0.removeFromSuperview() }
        fullScreenButton.removeFromSuperview()
        bgView.snp.removeConstraints()

        view.addSubview(playerView)
        view.addSubview(videoControlView)

        let views = [
            bgView,
            timeSlider,
            startTimeLabel,
            durationLabel,
            playPauseButton,
            rewindButton,
            forwardButton,
            minimizeScreenButton,
            closeButton
        ]
        views.forEach { videoControlView.addSubview($0)}

        let iconSize: Float = 30

        playerView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        videoControlView.snp.makeConstraints {
            $0.edges.equalTo(playerView)
        }
        bgView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(videoControlView)
            $0.height.equalTo(50)
        }

        rewindButton.snp.makeConstraints {
            $0.leading.equalTo(playerView).inset(16)
            $0.bottom.equalTo(playerView).inset(16)
            $0.width.height.equalTo(iconSize)
        }
        playPauseButton.snp.makeConstraints {
            $0.leading.equalTo(rewindButton.snp.trailing).offset(8)
            $0.bottom.equalTo(rewindButton)
            $0.width.height.equalTo(iconSize)
        }

        forwardButton.snp.makeConstraints {
            $0.leading.equalTo(playPauseButton.snp.trailing).offset(8)
            $0.bottom.equalTo(rewindButton)
            $0.width.height.equalTo(iconSize)
        }

        timeSlider.snp.makeConstraints {
            $0.leading.equalTo(forwardButton.snp.trailing).offset(16)
            $0.centerY.equalTo(forwardButton)
            $0.trailing.equalTo(minimizeScreenButton.snp.leading).offset(-48)
        }

        startTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(timeSlider)
            $0.bottom.equalTo(playerView).inset(4)
        }

        durationLabel.snp.makeConstraints {
            $0.trailing.equalTo(timeSlider)
            $0.bottom.equalTo(playerView).inset(4)
        }

        minimizeScreenButton.snp.makeConstraints {
            $0.trailing.equalTo(playerView).inset(16)
            $0.bottom.equalTo(rewindButton)
            $0.width.height.equalTo(iconSize)
        }

        closeButton.snp.makeConstraints {
            $0.leading.top.equalTo(playerView).inset(16)
            $0.width.height.equalTo(40)
        }
    }

    func setPlayPauseButtonImage() {
        var buttonImage: UIImage?

        switch self.player.timeControlStatus {
        case .playing:
            buttonImage = UIImage(systemName: "pause.fill")
        case .paused, .waitingToPlayAtSpecifiedRate:
            buttonImage = UIImage(systemName: "play.fill")
        @unknown default:
            buttonImage = UIImage(systemName: "pause.fill")
        }
        guard let image = buttonImage else { return }
        self.playPauseButton.setImage(image, for: .normal)
    }

    func readyToPlay() {
        guard let currentItem = player.currentItem else { return }
        let newDurationSeconds = Float(currentItem.duration.seconds)
        print(newDurationSeconds)

        let currentTime = Float(CMTimeGetSeconds(player.currentTime()))

        timeSlider.maximumValue = newDurationSeconds
        timeSlider.value = currentTime
    }
}


private extension VideoPlayerViewController {

    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }

    @objc
    func didTapPlayPauseButton() {
        switch player.timeControlStatus {
        case .playing:
            player.pause()
        case .paused:
            let currentItem = player.currentItem
            if currentItem?.currentTime() == currentItem?.duration {
                currentItem?.seek(to: .zero)
            }
            player.play()
        default:
            player.pause()
        }
    }

    @objc
    func timeSliderDidChange(_ sender: UISlider) {
        let newTime = CMTime(seconds: Double(sender.value), preferredTimescale: 600)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    @objc
    func didTapRewindButton() {
        if let currentTime = player.currentItem?.currentTime() {
            let newTime = currentTime - CMTime(value: 9000, timescale: 600)
            player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }

    @objc
    func didTapforwardButton() {
        if let currentTime = player.currentItem?.currentTime() {
            let newTime = currentTime + CMTime(value: 9000, timescale: 600)
            player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }

    @objc
    func didTapCloseButton() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        setNeedsUpdateOfSupportedInterfaceOrientations()
        self.dismiss(animated: true)
    }

    @objc
    func didTapfullScreenButton() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
        setNeedsUpdateOfSupportedInterfaceOrientations()
        setupViewsForLandScape()
    }

    @objc
    func didTapminimizeScreenButton() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        setNeedsUpdateOfSupportedInterfaceOrientations()
        setupViewsForPotrait()
    }
}

private extension VideoPlayerViewController {

    func setupPlayerObservers() {

        player.rx.timeControlStatus
            .subscribe(onNext: {_ in
                self.setPlayPauseButtonImage()
            })
            .disposed(by: disposeBag)

        let interval = CMTime(value: 1, timescale: 2)
        player.rx.periodicTimeObserver(interval: interval)
            .subscribe(onNext: { [weak self] time in
                guard let self = self else { return }
                let timeElapsed = Float(time.seconds)
                self.timeSlider.value = timeElapsed
                self.startTimeLabel.text = self.createTimeString(time: timeElapsed)
            }).disposed(by: disposeBag)

        player.rx.status
            .subscribe(onNext: { [weak self] isReady in
                if isReady {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        self?.readyToPlay()
                    }

                }
            }).disposed(by: disposeBag)

        NotificationCenter.default
            .rx.isLandScape(UIDevice.orientationDidChangeNotification)
            .subscribe(onNext: { [weak self] value in
                self?.isLandscape.accept(value)
            }).disposed(by: disposeBag)

        isLandscape.subscribe(onNext: { [weak self] isLandscapeValue in
            if isLandscapeValue {
                self?.setupViewsForLandScape()
            } else {
                self?.setupViewsForPotrait()
            }
        }).disposed(by: disposeBag)
    }

    func loadPropertyValues(forAsset newAsset: AVURLAsset) {
        let assetKeysRequiredToPlay = [
            "playable",
            "hasProtectedContent"
        ]

        newAsset.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) {
            DispatchQueue.main.async {
                if self.validateValues(forKeys: assetKeysRequiredToPlay, forAsset: newAsset) {
                    self.setupPlayerObservers()
                    self.playerView.player = self.player

                    self.playerView.playerLayer.videoGravity = .resizeAspect

                    let newItem = AVPlayerItem(asset: newAsset)

                    self.player.replaceCurrentItem(with: newItem)
                }
            }
        }
    }

    func validateValues(forKeys keys: [String], forAsset newAsset: AVAsset) -> Bool {
        for key in keys {
            var error: NSError?
            if newAsset.statusOfValue(forKey: key, error: &error) == .failed {
                let stringFormat = NSLocalizedString("The media failed to load the key \"%@\"",
                                                     comment: "You can't use this AVAsset because one of it's keys failed to load.")

                let message = String.localizedStringWithFormat(stringFormat, key)
                handleErrorWithMessage(message, error: error)

                return false
            }
        }

        if !newAsset.isPlayable || newAsset.hasProtectedContent {
            let message = NSLocalizedString("The media isn't playable or it contains protected content.",
                                            comment: "You can't use this AVAsset because it isn't playable or it contains protected content.")
            handleErrorWithMessage(message)
            return false
        }

        return true
    }

    func handleErrorWithMessage(_ message: String, error: Error? = nil) {
        if let err = error {
            print("Error occurred with message: \(message), error: \(err).")
        }
        let alertTitle = NSLocalizedString("Error", comment: "Alert title for errors")

        let alert = UIAlertController(title: alertTitle, message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        let alertActionTitle = NSLocalizedString("OK", comment: "OK on error alert")
        let alertAction = UIAlertAction(title: alertActionTitle, style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}


extension Reactive where Base : NotificationCenter {

    func isLandScape(_ name: Notification.Name?, object: AnyObject? = nil)
    -> Observable<Bool> {
        return notification(name)
            .map { _ in
                return UIDevice.current.orientation.isLandscape
            }
    }
}

