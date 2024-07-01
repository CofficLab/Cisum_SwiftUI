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
    var audioWorker: AudioWorker = AudioWorker()
    var videoWorker: VideoWorker = VideoWorker()
    var verbose = false
    var queue = DispatchQueue(label: "PlayMan", qos: .userInteractive)
    var worker: PlayWorker {
        guard let asset = asset else {
            return audioWorker
        }
        
        return asset.isVideo() ? videoWorker : audioWorker
    }
    
    @Published var asset: PlayAsset?
    @Published var mode: PlayMode = .Order

    // MARK: 状态改变时

    var state: PlayState { worker.state }
    var duration: TimeInterval { worker.duration }
    var currentTime: TimeInterval { worker.currentTime }
    var leftTime: TimeInterval { duration - currentTime }
    var currentTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: currentTime) ?? "0:00"
    }

    var leftTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: leftTime) ?? "0:00"
    }

    // MARK: 对外传递事件

    var onStateChange: (_ state: PlayState) -> Void = { state in
        os_log("\(AudioWorker.label)播放器状态已变为 \(state.des)")
    }
    
    var onGetPrevOf: (_ asset: PlayAsset?) -> PlayAsset? = { asset in
        os_log("\(AudioWorker.label)GetPrevOf -> \(asset?.title ?? "nil")")
        return nil
    }
    
    var onGetNextOf: (_ asset: PlayAsset?) -> PlayAsset? = { asset in
        os_log("\(AudioWorker.label)GetNextOf -> \(asset?.title ?? "nil")")
        return nil
    }
    
    var onToggleLike: () -> Void = {
        os_log("\(AudioWorker.label)ToggleLike")
    }
    
    var onToggleMode: () -> Void = {
        os_log("\(AudioWorker.label)ToggleMode")
    }
    
    // MARK: 初始化
    
    init(verbose: Bool = true) {
        super.init()
        
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
    }

    func prepare(_ asset: PlayAsset?) {
        self.worker.prepare(asset)
    }

    // MARK: Play
    
    func play(_ asset: PlayAsset, reason: String) {
        os_log("\(self.label)Play \(asset.fileName) (\(asset.isAudio() ? "Audio" : "Video")) 🐛 \(reason)")
        self.asset = asset
        self.worker.play(asset, reason: reason)
    }

    func play() {
        self.worker.play()
    }

    func resume() {
        self.worker.resume()
    }

    func pause() {
        self.worker.pause()
    }

    func stop() {
        self.worker.stop()
    }

    func toggle() {
        self.worker.toggle()
    }
    
    // MARK: Prev
    
    func prev() {
        self.worker.prev()
    }
    
    // MARK: Next
    
    func next() {
        self.worker.next()
    }
}

// MARK: 播放状态

extension PlayMan {
    var isReady: Bool {
        if case .Ready = state {
            return true
        } else {
            return false
        }
    }

    var isPlaying: Bool {
        if case .Playing = state {
            return true
        } else {
            return false
        }
    }
    
    var isNotPlaying: Bool {
        !isPlaying
    }
}

// MARK: 接收系统事件

extension PlayMan: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        queue.sync {
            // 没有播放完，被打断了
            if !flag {
                os_log("\(Logger.isMain)\(self.label)播放被打断，更新为暂停状态")
                return pause()
            }

            if self.mode == .Loop {
                os_log("\(self.label)播放完成，单曲循环")
                if let asset = self.asset {
                    self.play(asset, reason: "单曲循环")
                } else {
                    self.next()
                }
            } else {
                os_log("\(self.label)播放完成，\(self.mode.description)")
                self.next()
            }
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        os_log("\(Logger.isMain)\(self.label)audioPlayerDecodeErrorDidOccur")
    }

    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        os_log("\(Logger.isMain)\(self.label)audioPlayerBeginInterruption")
        pause()
    }

    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        os_log("\(Logger.isMain)\(self.label)audioPlayerEndInterruption")
        resume()
    }
}

// MARK: 媒体中心

extension PlayMan {
    var c: MPRemoteCommandCenter {
        MPRemoteCommandCenter.shared()
    }

    private func setPlayingInfo(verbose: Bool = false) {
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
