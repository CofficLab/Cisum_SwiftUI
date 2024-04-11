import AVKit
import Foundation
import OSLog
import SwiftUI

class SmartPlayer: NSObject {
    var player = AVAudioPlayer()
    var audio: Audio?
    var state: State = .Stopped {
        didSet {
            self.onStateChange(self.state)
            Task {
                MediaPlayerManager.setPlayingInfo(self)
            }
        }
    }
    
    // MARK: 对外传递事件
    
    var onStateChange: (_ state: State)->Void = { state in
        os_log("🍋 🎵 SmartPlayer::播放器状态已变为 \(state.des)")
    }

    // MARK: 设置当前的

    @MainActor func setCurrent(_ audio: Audio, play: Bool? = nil, reason: String) {
        os_log("\(Logger.isMain)🍋 ✨ AudioManager::setCurrent to \(audio.title) 🐛 \(reason)")

        self.audio = audio
    }

    // MARK: 跳转到某个时间

    func gotoTime(time: TimeInterval) {
        player.currentTime = time
    }

    // MARK: 播放指定的

    @MainActor func play(_ audio: Audio, reason: String) {
        os_log("\(Logger.isMain)🔊 AudioManager::play \(audio.title)")

        setCurrent(audio, play: true, reason: reason)
    }

    func resume() {
        player.play()
        self.state = .Playing
    }

    // MARK: 暂停

    func pause() {
        player.pause()
        self.state = .Paused
    }

    // MARK: 停止

    func stop() {
        os_log("\(Logger.isMain)🍋 AudioManager::Stop")
        player.stop()
        player.currentTime = 0
        self.state = .Stopped
    }

    // MARK: 切换

    @MainActor func toggle() {
        if player.isPlaying {
            pause()
        } else {
            resume()
        }
    }
}

// MARK: 播放状态

extension SmartPlayer {
    enum State {
        case Playing
        case Paused
        case Stopped
        case Finished

        var des: String {
            String(describing: self)
        }
    }
}

// MARK: 接收系统事件

extension SmartPlayer: AVAudioPlayerDelegate {
    @MainActor func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 没有播放完，被打断了
        if !flag {
            os_log("\(Logger.isMain)🍋 AudioManager::播放被打断，更新为暂停状态")
            return pause()
        }

        os_log("\(Logger.isMain)🍋 AudioManager::播放完成")
        self.state = .Finished
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        os_log("\(Logger.isMain)audioPlayerDecodeErrorDidOccur")
    }

    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        os_log("\(Logger.isMain)🍋 AudioManager::audioPlayerBeginInterruption")
        pause()
    }

    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        os_log("\(Logger.isMain)🍋 AudioManager::audioPlayerEndInterruption")
        resume()
    }
}
