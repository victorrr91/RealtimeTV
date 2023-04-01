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

    var currentTimeSeconds: Float = 0
    var totalTimeSeconds: Float = 0

    var playerViewModel: VideoPlayerViewModel? = nil

    private var movieUrl: URL? = nil

    let player = AVPlayer()
    private let playerView = PlayerView()

    private let bgView: UIView = {
        let view = UIView()
        view.alpha = 0.4
        view.backgroundColor = .black
        return view
    }()

    private let videoControlView = UIView()

    private let timeSlider: UISlider = {
        let timeSlider = UISlider()
        timeSlider.maximumTrackTintColor = .gray
        timeSlider.minimumTrackTintColor = .red
        timeSlider.thumbTintColor = .red

        timeSlider.addTarget(self, action: #selector(timeSliderDidChange(_:)), for: .touchUpInside)
        return timeSlider
    }()

    private let startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemGray2
        return label
    }()

    private let onAirButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        button.titleLabel?.textColor = .systemGray2
        button.addTarget(self, action: #selector(didTapOnAirButton), for: .touchUpInside)
        return button
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return button
    }()

    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 60)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        button.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        return button
    }()

    private lazy var rewindButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward.15"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapRewindButton), for: .touchUpInside)
        return button
    }()

    private lazy var forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.15"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapforwardButton), for: .touchUpInside)
        return button
    }()

    private lazy var fullScreenButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapfullScreenButton), for: .touchUpInside)
        return button
    }()

    private lazy var minimizeScreenButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
        button.tintColor = .white
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
        guard let movieUrl = URL(string: data.urlString) else { return }

        self.movieUrl = movieUrl
        let newAsset = AVAsset(url: movieUrl)

        self.player.replaceCurrentItem(with: AVPlayerItem(asset: newAsset))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindingPlayerController()
        view.backgroundColor = .systemBackground

        setupViewsForPotrait()

        guard let movieUrl = movieUrl else { return }
        let asset = AVURLAsset(url: movieUrl)

        loadPropertyValues(forAsset: asset)

        setRecognizer()
    }



    override func viewWillAppear(_ animated: Bool) {
        player.play()

        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        player.pause()

        super.viewWillDisappear(animated)
    }

    //MARK: Set animations
    func setRecognizer() {
        let tapOnce = UITapGestureRecognizer(target: self, action: #selector(didTapOnce))
        tapOnce.numberOfTapsRequired = 1

        let tapTwice = UITapGestureRecognizer(target: self, action: #selector(didTapTwice))
        tapTwice.numberOfTapsRequired = 2

        tapOnce.require(toFail: tapTwice)

        playerView.addGestureRecognizer(tapOnce)
        playerView.addGestureRecognizer(tapTwice)

        let controlTapOnce = UITapGestureRecognizer(target: self, action: #selector(didTapOnce))

        videoControlView.addGestureRecognizer(controlTapOnce)
    }

    @objc
    func didTapOnce() {
        let newValue = !(playerViewModel?.shouldShowControl.value ?? true)
        playerViewModel?.shouldShowControl.accept(newValue)
    }

    @objc
    func didTapTwice() {
        print("tap twice!")
    }

    func hideVideoControl() {
        self.videoControlView.fadeOut(0.3)
    }

    func showVideoControl() {
        self.videoControlView.fadeIn(0.3)
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
            onAirButton,
            playPauseButton,
            rewindButton,
            forwardButton,
            fullScreenButton,
        ]

        views.forEach { videoControlView.addSubview($0)}

        let iconSize: Float = 30

        playerView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(320)
        }

        videoControlView.snp.makeConstraints {
            $0.edges.equalTo(playerView)
        }

        bgView.snp.makeConstraints {
            $0.edges.equalTo(videoControlView)
        }

        playPauseButton.snp.makeConstraints {
            $0.centerX.centerY.equalTo(videoControlView)
            $0.width.height.equalTo(iconSize)
        }

        rewindButton.snp.makeConstraints {
            $0.centerY.equalTo(playPauseButton)
            $0.trailing.equalTo(playPauseButton.snp.leading).inset(-50)
            $0.width.height.equalTo(iconSize)
        }

        forwardButton.snp.makeConstraints {
            $0.centerY.equalTo(playPauseButton)
            $0.leading.equalTo(playPauseButton.snp.trailing).offset(50)
            $0.width.height.equalTo(iconSize)
        }

        timeSlider.snp.makeConstraints {
            $0.leading.trailing.equalTo(videoControlView)
            $0.bottom.equalTo(videoControlView).inset(8)
        }

        startTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(videoControlView).inset(16)
            $0.bottom.equalTo(timeSlider.snp.top).inset(-8)
        }

        onAirButton.snp.makeConstraints {
            $0.leading.equalTo(startTimeLabel.snp.trailing).offset(16)
            $0.centerY.equalTo(startTimeLabel)
        }

        fullScreenButton.snp.makeConstraints {
            $0.trailing.equalTo(videoControlView).inset(8)
            $0.bottom.equalTo(timeSlider.snp.top).inset(-4)
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
            onAirButton,
            playPauseButton,
            rewindButton,
            forwardButton,
            minimizeScreenButton,
            closeButton
        ]
        views.forEach { videoControlView.addSubview($0)}

        let iconSize: Float = 40

        playerView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        videoControlView.snp.makeConstraints {
            $0.edges.equalTo(playerView)
        }

        bgView.snp.makeConstraints {
            $0.edges.equalTo(videoControlView)
        }

        playPauseButton.snp.makeConstraints {
            $0.centerX.centerY.equalTo(videoControlView)
            $0.width.height.equalTo(iconSize)
        }

        rewindButton.snp.remakeConstraints {
            $0.centerY.equalTo(playPauseButton)
            $0.trailing.equalTo(playPauseButton.snp.leading).inset(-80)
            $0.width.height.equalTo(iconSize)
        }

        forwardButton.snp.remakeConstraints {
            $0.centerY.equalTo(playPauseButton)
            $0.leading.equalTo(playPauseButton.snp.trailing).offset(80)
            $0.width.height.equalTo(iconSize)
        }

        timeSlider.snp.makeConstraints {
            $0.leading.trailing.equalTo(videoControlView)
            $0.bottom.equalTo(videoControlView).inset(8)
        }

        startTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(videoControlView).inset(16)
            $0.bottom.equalTo(timeSlider.snp.top).inset(-8)
        }

        onAirButton.snp.remakeConstraints {
            $0.leading.equalTo(videoControlView).inset(16)
            $0.centerY.equalTo(startTimeLabel)
        }

        minimizeScreenButton.snp.makeConstraints {
            $0.trailing.equalTo(videoControlView).inset(8)
            $0.bottom.equalTo(timeSlider.snp.top).inset(-4)
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
        currentTimeSeconds = sender.value
        timeSlider.value = self.currentTimeSeconds
        let newTime = CMTime(seconds: Double(currentTimeSeconds), preferredTimescale: 600)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    @objc
    func didTapRewindButton() {
        currentTimeSeconds -= 15
        if currentTimeSeconds < 0 {
            currentTimeSeconds = 0
        }
        timeSlider.value = self.currentTimeSeconds

        let newTime = CMTime(seconds: Double(currentTimeSeconds), preferredTimescale: 600)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    @objc
    func didTapforwardButton() {
        currentTimeSeconds += 15
        timeSlider.value = self.currentTimeSeconds

        let newTime = CMTime(seconds: Double(currentTimeSeconds), preferredTimescale: 600)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    @objc
    func didTapOnAirButton() {
        currentTimeSeconds = totalTimeSeconds
        timeSlider.value = self.currentTimeSeconds

        let newTime = CMTime(seconds: Double(currentTimeSeconds), preferredTimescale: 600)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
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

extension VideoPlayerViewController {

    func bindingPlayerController(viewModel: VideoPlayerViewModel = VideoPlayerViewModel()) {
        playerViewModel = viewModel

        playPauseButton.rx.tap
            .bind(onNext: { _ in
                viewModel.controlButtonTapped.accept(true)
            })
            .disposed(by: disposeBag)

        rewindButton.rx.tap
            .bind(onNext: { _ in
                viewModel.controlButtonTapped.accept(true)
            })
            .disposed(by: disposeBag)

        forwardButton.rx.tap
            .bind(onNext: { _ in
                viewModel.controlButtonTapped.accept(true)
            })
            .disposed(by: disposeBag)

        fullScreenButton.rx.tap
            .bind(onNext: { _ in
                viewModel.controlButtonTapped.accept(true)
            })
            .disposed(by: disposeBag)

        minimizeScreenButton.rx.tap
            .bind(onNext: { _ in
                viewModel.controlButtonTapped.accept(true)
            })
            .disposed(by: disposeBag)

        viewModel.shouldShowControl // Bool
            .bind(to: self.rx.videoControlVisibilty)
            .disposed(by: disposeBag)


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
                print(timeElapsed)
                self.currentTimeSeconds += 0.25
                self.totalTimeSeconds += 0.25
                self.timeSlider.maximumValue = self.totalTimeSeconds
                self.timeSlider.value = self.currentTimeSeconds

                let time = self.totalTimeSeconds - self.currentTimeSeconds
                if time == 0 {
                    self.startTimeLabel.isHidden = true
                    self.onAirButton.snp.remakeConstraints {
                        $0.leading.equalTo(self.videoControlView).inset(16)
                        $0.centerY.equalTo(self.startTimeLabel)
                    }
                    self.onAirButton.setTitle("🔴 실시간", for: .normal)
                } else {
                    self.startTimeLabel.isHidden = false
                    self.startTimeLabel.text = "-\(self.createTimeString(time: time))"
                    self.onAirButton.snp.remakeConstraints {
                        $0.leading.equalTo(self.startTimeLabel.snp.trailing).offset(16)
                        $0.centerY.equalTo(self.startTimeLabel)
                    }
                    self.onAirButton.setTitle("⚪️ 실시간", for: .normal)
                }

            }).disposed(by: disposeBag)

        viewModel.isLandscape.subscribe(onNext: { [weak self] isLandscapeValue in
            if isLandscapeValue {
                self?.setupViewsForLandScape()
            } else {
                self?.setupViewsForPotrait()
            }
        })
        .disposed(by: disposeBag)
    }

    func loadPropertyValues(forAsset newAsset: AVURLAsset) {
        let assetKeysRequiredToPlay = [
            "playable",
            "hasProtectedContent"
        ]

        newAsset.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) {
            DispatchQueue.main.async {
                if self.validateValues(forKeys: assetKeysRequiredToPlay, forAsset: newAsset) {
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

private extension Reactive where Base: VideoPlayerViewController {
    var videoControlVisibilty: Binder<Bool> {
        return Binder(base) { vc, shouldShow in
            if shouldShow {
                vc.showVideoControl()
            } else {
                vc.hideVideoControl()
            }
        }
    }
}
