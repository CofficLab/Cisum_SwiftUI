import AVKit
import Foundation
import OSLog
import SwiftUI

class PlayMan: NSObject {
    // MARK: 成员

    static var label = "💿 SmartPlayer::"
    var label: String { Logger.isMain + Self.label }
    var player = AVAudioPlayer()
    var audio: Audio?
    var verbose = false
    var queue = DispatchQueue(label: "SmartPlayer", qos: .userInteractive)

    // MARK: 状态改变时

    var state: State = .Stopped {
        didSet {
            if verbose {
                os_log("\(Logger.isMain)\(self.label)State changed 「\(oldValue.des)」 -> 「\(self.state.des)」")
            }
            
            var e: Error? = nil
            
            self.audio = self.state.getAudio()

            switch state {
            case .Ready(_):
                do {
                    try player = makePlayer(self.audio)
                    player.prepareToPlay()
                } catch {
                    e = error
                }
            case let .Playing(audio):
                if let oldAudio = oldValue.getPausedAudio(), oldAudio.url == audio.url {
                    player.play()
                } else {
                    do {
                        self.audio = audio
                        try player = makePlayer(audio)
                        player.prepareToPlay()
                        player.play()
                    } catch {
                        e = error
                    }
                }
            case .Paused:
                player.pause()
            case .Stopped:
                player.stop()
                player.currentTime = 0
            case .Finished:
                player.stop()
            case .Error:
                player = makeEmptyPlayer()
            }
            
            self.onStateChange(state)
            
            if let ee = e {
                setError(ee, audio: self.audio)
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
        os_log("\(PlayMan.label)播放器状态已变为 \(state.des)")
    }
}

// MARK: 播放控制

extension PlayMan {
    func goto(_ time: TimeInterval) {
        player.currentTime = time
    }

    func prepare(_ audio: Audio?) {
        state = .Ready(audio)
    }

    func play(_ audio: Audio, reason: String) {
        os_log("\(self.label)play \(audio.title) 🐛 \(reason)")
        state = .Playing(audio)
    }

    func play() {
        os_log("\(self.label)Play")
        resume()
    }

    func resume() {
        os_log("\(self.label)Resume while current is \(self.state.des)")
        switch state {
        case .Playing, .Error:
            break
        case .Ready, .Paused, .Stopped, .Finished:
            state = .Playing(audio!)
        }
    }

    func pause() {
        os_log("\(self.label)Pause")
        state = .Paused(audio)
    }

    func stop() {
        os_log("\(self.label)Stop")
        state = .Stopped
    }

    func toggle() {
        isPlaying ? pause() : resume()
    }
}

// MARK: 控制 AVAudioPlayer

extension PlayMan {
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
            os_log("\(self.label)在下载 \(audio.title) ⚠️⚠️⚠️")
            throw SmartError.Downloading
        }

        // 未下载的情况
        guard audio.isDownloaded else {
            os_log("\(self.label)未下载 \(audio.title) ⚠️⚠️⚠️")
            throw SmartError.NotDownloaded
        }

        // 格式不支持
        guard audio.isSupported else {
            os_log("\(self.label)格式不支持 \(audio.title) \(audio.ext)")
            throw SmartError.FormatNotSupported(audio.ext)
        }

        do {
            #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
            player = try AVAudioPlayer(contentsOf: audio.url)
        } catch {
            os_log(.error, "\(self.label)初始化播放器失败 ->\(audio.title)->\(error)")
            player = AVAudioPlayer()
        }

        player.delegate = self

        return player
    }
}

// MARK: 播放状态

extension PlayMan {
    enum State {
        case Ready(Audio?)
        case Playing(Audio)
        case Paused(Audio?)
        case Stopped
        case Finished
        case Error(Error, Audio?)

        var des: String {
            switch self {
            case let .Ready(audio):
                "准备 \(audio?.title ?? "nil") 🚀🚀🚀"
            case let .Error(error, audio):
                "错误：\(error.localizedDescription) ⚠️⚠️⚠️ -> \(audio?.title ?? "-")"
            case let .Playing(audio):
                "播放 \(audio.title) 🔊🔊🔊"
            case let .Paused(audio):
                "暂停 \(audio?.title ?? "-") ⏸️⏸️⏸️"
            default:
                String(describing: self)
            }
        }

        func getPausedAudio() -> Audio? {
            switch self {
            case let .Paused(audio):
                return audio
            default:
                return nil
            }
        }
        
        func getAudio() -> Audio? {
            switch self {
            case .Ready(let audio):
                audio
            case .Playing(let audio):
                audio
            case .Paused(let audio):
                audio
            case .Error(_, let audio):
                audio
            case .Stopped,.Finished:
                nil
            }
        }
    }

    func setError(_ e: Error, audio: Audio?) {
        state = .Error(e, audio)
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

            os_log("\(Logger.isMain)\(self.label)播放完成")
            state = .Finished
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
