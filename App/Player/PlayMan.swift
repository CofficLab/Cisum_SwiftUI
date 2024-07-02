import AVKit
import MediaPlayer
import Foundation
import OSLog
import SwiftUI

/* 负责
      接收用户播放控制事件
      接收系统播放控制事件
      对接系统媒体中心
 */

class PlayMan: NSObject, ObservableObject {
    // MARK: 成员

    static var label = "💃 PlayMan::"
    
    var label: String { Logger.isMain + Self.label }
    var audioWorker: AudioWorker
    var videoWorker: VideoWorker
    var verbose = false
    var queue = DispatchQueue(label: "PlayMan", qos: .userInteractive)
    var worker: PlayWorker {
        guard let asset = asset, asset.isNotFolder() else {
            return audioWorker
        }
        
        return asset.isVideo() ? videoWorker : audioWorker
    }
    
    @Published var asset: PlayAsset?
    @Published var mode: PlayMode = .Order

    var isAudioWorker: Bool { ((self.worker as? AudioWorker) != nil)}
    var isVideoWorker: Bool { ((self.worker as? VideoWorker) != nil) }
    var duration: TimeInterval { worker.duration }
    var currentTime: TimeInterval { worker.currentTime }
    var leftTime: TimeInterval { duration - currentTime }
    var state: PlayState { worker.state }
    var currentTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: currentTime) ?? "0:00"
    }
    var leftTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: leftTime) ?? "0:00"
    }
    
    // MARK: 告诉我如何获取播放资源
    
    var onGetPrevOf: (_ asset: PlayAsset?) -> PlayAsset? = { asset in
        os_log("\(PlayMan.label)GetPrevOf -> \(asset?.title ?? "nil")")
        return nil
    }
    
    var onGetNextOf: (_ asset: PlayAsset?) -> PlayAsset? = { asset in
        os_log("\(PlayMan.label)GetNextOf -> \(asset?.title ?? "nil")")
        return nil
    }
    
    var onGetChildren: (_ asset: PlayAsset) -> [PlayAsset] = { asset in
        os_log("\(PlayMan.label)GetChildrenOf -> \(asset.title)")
        return []
    }

    // MARK: 对外传递事件

    var onStateChange: (_ state: PlayState) -> Void = { state in
        os_log("\(PlayMan.label)播放器状态已变为 \(state.des)")
    }
    
    var onToggleLike: () -> Void = {
        os_log("\(PlayMan.label)ToggleLike")
    }
    
    var onToggleMode: () -> Void = {
        os_log("\(PlayMan.label)ToggleMode")
    }
    
    // MARK: 初始化
    
    init(verbose: Bool = true) {
        
        self.audioWorker = AudioWorker()
        self.videoWorker = VideoWorker()
        
        super.init()
        
        self.audioWorker.onGetNextOf = onGetNextOf
        self.audioWorker.onGetPrevOf = onGetPrevOf
        self.audioWorker.onStateChange = { state in
            self.setPlayingInfo()
            self.asset = state.getAsset()
            self.onStateChange(state)
            
            if state.isFinished {
                os_log("\(self.label)播放完成，自动播放下一个")
                self.next()
            }
        }
        
        self.videoWorker.onGetNextOf = onGetNextOf
        self.videoWorker.onGetPrevOf = onGetPrevOf
        self.videoWorker.onStateChange = { state in
            self.setPlayingInfo()
            self.asset = state.getAsset()
            self.onStateChange(state)
            
            if state.isFinished {
                os_log("\(self.label)播放完成，自动播放下一个")
                self.next()
            }
        }
        
        Task {
            onCommand()
        }
    }
}

// MARK: 播放模式

extension PlayMan {
    func switchMode(verbose: Bool = true) {
        mode = mode.switchMode()
        Config.setCurrentMode(mode)
        onToggleMode()
    }
}

// MARK: 播放控制

extension PlayMan {
    func toggleLike() {
        self.worker.toggleLike()
    }
    
    func goto(_ time: TimeInterval) {
        self.worker.goto(time)
        setPlayingInfo()
    }

    func prepare(_ asset: PlayAsset?) {
        self.worker.prepare(asset)
    }

    // MARK: Play
    
    func play(_ asset: PlayAsset, reason: String) {
        os_log("\(self.label)Play \(asset.fileName) (\(asset.isAudio() ? "Audio" : "Video")) 🐛 \(reason)")
        
        if asset.isFolder() {
            guard let first = self.onGetChildren(asset).first else {
                return self.worker.setError(SmartError.NoNextAudio, asset: asset)
            }
            
            self.asset = first
        } else {
            self.asset = asset
        }
        
        self.worker.play(self.asset!, reason: reason)
    }

    func play() {
        self.worker.play()
    }

    func resume() {
        os_log("\(self.label)Resume while current is \(self.state.des)")
        
        guard let asset = self.asset else {
            return
        }
        
        if asset.isFolder() {
            guard let first = self.onGetChildren(asset).first else {
                return self.worker.setError(SmartError.NoNextAudio, asset: asset)
            }
            
            self.asset = first
            self.worker.play(self.asset!, reason: "Resum")
        } else {
            self.worker.resume()
        }
    }

    func pause() {
        self.worker.pause()
    }

    func stop() {
        self.worker.stop()
    }

    func toggle() {
        if isPlaying {
            self.pause()
        } else {
            self.resume()
        }
    }
    
    // MARK: Prev
    
    func prev() {
        self.worker.prev()
    }
    
    // MARK: Next
    
    func next() {
        if let next = self.onGetNextOf(self.asset) {
            self.play(next, reason: "Next")
        } else {
            os_log("\(self.label)Next of (\(self.asset?.title ?? "nil")) is nil, stop")
            self.stop()
        }
    }
}

// MARK: 播放状态

extension PlayMan {
    var isReady: Bool {
        self.state.isReady
    }

    var isPlaying: Bool {
        self.state.isPlaying
    }
    
    var isStopped: Bool {
        self.state.isStopped
    }
    
    var isNotPlaying: Bool {
        !isPlaying
    }
}

// MARK: 媒体中心

extension PlayMan {
    var c: MPRemoteCommandCenter {
        MPRemoteCommandCenter.shared()
    }

    private func setPlayingInfo(verbose: Bool = true) {
        let center = MPNowPlayingInfoCenter.default()
        let artist = "Cisum"
        let title = asset?.fileName ?? ""
        let duration: TimeInterval = self.duration
        let currentTime: TimeInterval = self.currentTime
        let image = asset?.getMediaCenterImage() ?? PlayAsset.defaultImage
        
        if verbose {
            os_log("\(self.label)📱📱📱 Update -> \(self.state.des)")
            os_log("\(self.label)📱📱📱 Update -> Title: \(title)")
            os_log("\(self.label)📱📱📱 Update -> Duration: \(duration)")
            os_log("\(self.label)📱📱📱 Update -> Playing: \(self.isPlaying)")
        }

        center.playbackState = isPlaying ? .playing : .paused
        center.playbackState = isStopped ? .stopped : .paused
        center.nowPlayingInfo = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: image.size, requestHandler: { size in
                #if os(macOS)
                    image.size = size
                #endif

                return image
            }),
        ]

        let like = asset?.like ?? false
        if verbose {
            os_log("\(self.label)setPlayingInfo like -> \(like)")
        }
        c.likeCommand.isActive = like
    }

    // 接收控制中心的指令
    func onCommand() {
        c.nextTrackCommand.addTarget { _ in
            self.next()

            return .success
        }

        c.previousTrackCommand.addTarget { _ in
            self.prev()
            
            return .success
        }

        c.pauseCommand.addTarget { _ in
            self.pause()

            return .success
        }

        c.playCommand.addTarget { _ in
            os_log("\(Logger.isMain)\(self.label)播放")
            self.resume()

            return .success
        }

        c.stopCommand.addTarget { _ in
            os_log("\(Logger.isMain)\(self.label)停止")

            self.worker.stop()

            return .success
        }

        // MARK: Like
        
        c.likeCommand.addTarget { event in
            os_log("\(self.label)点击了喜欢按钮")
            
            self.toggleLike()
            
            self.c.likeCommand.isActive = self.asset?.like ?? false
            self.c.dislikeCommand.isActive = self.asset?.notLike ?? true

            return .success
        }

        c.ratingCommand.addTarget { _ in
            os_log("\(Logger.isMain)评分")

            return .success
        }

        c.changeRepeatModeCommand.addTarget { _ in
            os_log("\(Logger.isMain)changeRepeatModeCommand")

            return .success
        }

        c.changePlaybackPositionCommand.addTarget { e in
            os_log("\(Logger.isMain)\(self.label)changePlaybackPositionCommand")
            guard let event = e as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }

            let positionTime = event.positionTime // 获取当前的播放进度时间

            // 在这里处理当前的播放进度时间
            os_log("Current playback position: \(positionTime)")
            self.goto(positionTime)

            return .success
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
