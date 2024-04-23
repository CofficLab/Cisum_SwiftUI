import AVKit
import Foundation
import OSLog
import SwiftUI

class SmartPlayer: NSObject {
    // MARK: 成员

    static var label = "💿 SmartPlayer::"
    var label: String { SmartPlayer.label }
    var player = AVAudioPlayer()
    var audio: Audio?

    // MARK: 状态改变时

    var state: State = .Stopped {
        didSet {
            os_log("\(Logger.isMain)\(self.label)State changed \(oldValue.des) -> \(self.state.des)")
            onStateChange(state)

            switch self.state {
            case .Ready(let audio):
                if let audio = audio {
                    do {
                        self.audio = audio
                        try self.player = makePlayer(audio)
                        self.player.prepareToPlay()
                    } catch {
                        return setError(error)
                    }
                } else {
                    self.audio = audio
                    return setError(SmartError.NoAudioInList)
                }
            case .Playing(let audio):
                // 说明是恢复播放
                if self.player.currentTime > 0 {
                    self.player.play()
                    return
                }
                
                self.audio = audio
                
                do {
                    self.audio = audio
                    try self.player = makePlayer(audio)
                    self.player.prepareToPlay()
                    self.player.play()
                } catch {
                    self.state = .Error(error)
                }
            case .Paused:
                self.player.pause()
            case .Stopped:
                player.stop()
                player.currentTime = 0
            case .Finished:
                player.stop()
            case .Error:
                player = makeEmptyPlayer()
            }

            Task {
                MediaPlayerManager.setPlayingInfo(self)
            }
        }
    }

    var duration: TimeInterval { player.duration }
    var currentTime: TimeInterval { player.currentTime }
    var leftTime: TimeInterval { duration - currentTime }
    var currentTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: currentTime) ?? "0:00"
    }

    var leftTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: leftTime) ?? "0:00"
    }

    // MARK: 对外传递事件

    var onStateChange: (_ state: State) -> Void = { state in
        os_log("\(SmartPlayer.label)播放器状态已变为 \(state.des)")
    }
}

// MARK: 播放控制

extension SmartPlayer {
    func goto(_ time: TimeInterval) {
        player.currentTime = time
    }

    func prepare(_ audio: Audio?, play: Bool = false) {
        state = .Ready(audio)

        if audio != nil, play, self.isReady {
            resume()
        }
    }

    func play(_ audio: Audio, reason: String) {
        os_log("\(Logger.isMain)\(self.label)play \(audio.title) 🐛 \(reason)")
        state = .Playing(audio)
    }

    func play() {
        os_log("\(Logger.isMain)\(self.label)Play")
        resume()
    }

    func resume() {
        os_log("\(Logger.isMain)\(self.label)Resume while current is \(self.state.des)")
        switch state {
        case .Playing, .Error:
            break
        case .Ready, .Paused, .Stopped, .Finished:
            state = .Playing(self.audio!)
        }
    }

    func pause() {
        os_log("\(Logger.isMain)\(self.label)Pause")
        state = .Paused
    }

    func stop() {
        os_log("\(Logger.isMain)\(self.label)Stop")
        state = .Stopped
    }

    func toggle() {
        isPlaying ? pause() : resume()
    }
}

// MARK: 控制 AVAudioPlayer

extension SmartPlayer {
    func makeEmptyPlayer() -> AVAudioPlayer {
        AVAudioPlayer()
    }

    func makePlayer(_ audio: Audio?) throws -> AVAudioPlayer {
        guard let audio = audio else {
            return AVAudioPlayer()
        }

        if audio.isNotExists {
            throw SmartError.NotExists
        }

        if audio.isDownloading {
            throw SmartError.Downloading
        }

        // 未下载的情况
        guard audio.isDownloaded else {
            throw SmartError.NotDownloaded
        }

        // 格式不支持
        guard audio.isSupported else {
            os_log("\(Logger.isMain)\(SmartPlayer.label)格式不支持 \(audio.title) \(audio.ext)")
            throw SmartError.FormatNotSupported(audio.ext)
        }

        do {
            #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
            player = try AVAudioPlayer(contentsOf: audio.url)
        } catch {
            os_log("\(Logger.isMain)初始化播放器失败 ->\(audio.title)->\(error)")
            player = AVAudioPlayer()
        }

        player.delegate = self

        return player
    }
}

// MARK: 播放状态

extension SmartPlayer {
    enum State {
        case Ready(Audio?)
        case Playing(Audio)
        case Paused
        case Stopped
        case Finished
        case Error(Error)

        var des: String {
            switch self {
            case .Ready(let audio):
                "准备播放 \(audio?.title ?? "nil")"
            case .Error(let error):
                "错误：\(error.localizedDescription)"
            default:
                String(describing: self)
            }
        }
    }

    func setError(_ e: Error) {
        self.state = .Error(e)
    }

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
}

// MARK: 接收系统事件

extension SmartPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 没有播放完，被打断了
        if !flag {
            os_log("\(Logger.isMain)\(self.label)播放被打断，更新为暂停状态")
            return pause()
        }

        os_log("\(Logger.isMain)\(self.label)播放完成")
        state = .Finished
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
