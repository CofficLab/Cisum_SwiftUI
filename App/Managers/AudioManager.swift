import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftData
import SwiftUI

/// 管理播放器的播放、暂停、上一曲、下一曲等操作
class AudioManager: NSObject, ObservableObject {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var duration: TimeInterval = 0
    @Published var audio: Audio?
    @Published var playerError: Error? = nil
    @Published var mode: PlayMode = .Order
    @Published var lastUpdatedAt: Date = .now

    private var player: AVAudioPlayer = .init()
    private var listener: AnyCancellable?
    private var bg = AppConfig.bgQueue
    private var main = AppConfig.mainQueue
    private var title: String { audio?.title ?? "[无]" }
    private var rootDir: URL = AppConfig.cloudDocumentsDir

    var db: DB?
    var isEmpty: Bool { audio == nil }
    var isCloudStorage: Bool { iCloudHelper.isCloudPath(url: rootDir) }

    override init() {
        super.init()
        db = DB(AppConfig.sharedModelContainer, onUpdated: {
            self.main.async {
                self.lastUpdatedAt = .now
            }
        })
    }

    func setCurrent(_ audio: Audio) {
        self.audio = audio
        try? updatePlayer()
    }

    func currentTime() -> TimeInterval {
        return player.currentTime
    }

    func currentTimeDisplay() -> String {
        return DateComponentsFormatter.positional.string(from: currentTime()) ?? "0:00"
    }

    func leftTime() -> TimeInterval {
        return player.duration - player.currentTime
    }

    func leftTimeDisplay() -> String {
        return DateComponentsFormatter.positional.string(from: leftTime()) ?? "0:00"
    }

    func gotoTime(time: TimeInterval) {
        player.currentTime = time
        updateMediaPlayer()
    }

    func replay() {
        os_log("\(Logger.isMain)🍋 AudioManager::replay()")

        do {
            try updatePlayer()
        } catch let e {
            self.playerError = e
            return
        }

        play()
    }

    // MARK: 播放

    func play(url: URL) {
        os_log("\(Logger.isMain)🔊 AudioManager::play")

        audio = Audio(url)

        play()
    }

    /// 播放当前的
    func play() {
        os_log("\(Logger.isMain)🔊 AudioManager::play")

        do {
            try updatePlayer()
        } catch {
            return
        }

        player.play()
        isPlaying = true

        updateMediaPlayer()
    }

    // MARK: 暂停

    func pause() {
        player.pause()
        isPlaying = false

        updateMediaPlayer()
    }

    // MARK: 停止

    func stop() {
        os_log("\(Logger.isMain)🍋 AudioManager::Stop")
        player.stop()
        player.currentTime = 0
        duration = 0
        isPlaying = false
    }

    // MARK: 切换

    func togglePlayPause() throws {
        guard let audio = audio else {
            throw SmartError.NoAudioInList
        }

        if isEmpty {
            throw SmartError.NoAudioInList
        }

        if audio.isDownloading {
            throw SmartError.Downloading
        }

        if player.isPlaying {
            pause()
        } else {
            play()
        }
    }

    // MARK: 播放模式

    func toggleLoop() {
        player.numberOfLoops = player.numberOfLoops == 0 ? -1 : 0
        mode = player.numberOfLoops != 0 ? .Order : .Loop
    }

    // MARK: 切换播放模式

    func switchMode(_ callback: @escaping (_ mode: PlayMode) -> Void) {
        switch mode {
        case .Order:
            mode = .Random
        case .Loop:
            mode = .Order
        case .Random:
            mode = .Loop
        }

        callback(mode)
    }

    // MARK: Prev

    /// 跳到上一首，manual=true表示由用户触发
    func prev(manual: Bool = false) throws -> String {
        os_log("\(Logger.isMain)🔊 AudioManager::prev ⬆️")

        try updatePlayer()
        return "上一曲：\(title)"
    }

    // MARK: Next

    /// 跳到下一首，manual=true表示由用户触发
    func next(manual: Bool = false) throws {
        os_log("\(Logger.isMain)🔊 AudioManager::next ⬇️ \(manual ? "手动触发" : "自动触发")")

        if mode == .Loop && manual == false {
            return
        }

//        if let item = playItem, let i = PlayItem.nextOf(context, item: item) {
//            self.audio = Audio(i.url)
//            self.playItem = i
//        } else {
//            self.audio = nil
//            self.playItem = nil
//        }

        try updatePlayer()
    }

    private func makePlayer(url: URL?) throws -> AVAudioPlayer {
        os_log("\(Logger.isMain)🚩 AudioManager::初始化播放器")

        guard let url = url else {
            return AVAudioPlayer()
        }

        let ext = url.pathExtension
        if !AppConfig.supportedExtensions.contains(ext) {
            throw SmartError.FormatNotSupported(ext)
        }

        do {
            #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
            let player = try AVAudioPlayer(contentsOf: url)

            return player
        } catch {
            os_log("\(Logger.isMain)初始化播放器失败 ->\(url.lastPathComponent)->\(error)")

            throw SmartError.PlayFailed
        }
    }

    private func updateMediaPlayer() {
        MediaPlayerManager.setNowPlayingInfo(audioManager: self)
    }

    private func updatePlayer() throws {
        guard let audio = audio else {
            return
        }

        do {
            playerError = nil
            let player = try makePlayer(url: audio.url)
            bg.async {
                os_log("\(Logger.isMain)🍋 AudioManager::UpdatePlayer")
                player.delegate = self
                let duration = self.player.duration

                self.updateMediaPlayer()

                self.main.async {
                    self.player = player
                    self.duration = duration

                    if self.isPlaying {
                        self.player.play()
                    }
                }
            }
        } catch let e {
            withAnimation {
                self.stop()
                self.playerError = nil
                main.asyncAfter(deadline: .now() + 0.3) {
                    self.playerError = e
                }
            }
            throw e
        }
    }

    // 当前的 Audio 是否有效
    private func isValid() -> Bool {
        // 列表为空
        if isEmpty {
            return false
        }

        guard let audio = audio else {
            return false
        }

        return true
    }

    private func reset() {
        stop()
        audio = nil
        player = AVAudioPlayer()
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 没有播放完，被打断了
        if !flag {
            os_log("\(Logger.isMain)🍋 AudioManager::播放被打断，更新为暂停状态")
            return pause()
        }

        os_log("\(Logger.isMain)🍋 AudioManager::播放完成，自动播放下一曲")
        do {
            try next(manual: false)
        } catch let e {
            os_log("\(Logger.isMain)‼️ AudioManager::\(e.localizedDescription)")
            self.playerError = e
        }
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
        play()
    }
}

extension AudioManager {
    enum PlayMode {
        case Order
        case Loop
        case Random

        var description: String {
            switch self {
            case .Order:
                return "顺序播放"
            case .Loop:
                return "单曲循环"
            case .Random:
                return "随机播放"
            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
