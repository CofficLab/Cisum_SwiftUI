import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

/// 管理播放器的播放、暂停、上一曲、下一曲等操作
class AudioManager: NSObject, ObservableObject {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var duration: TimeInterval = 0
    @Published var audio = Audio.empty
    @Published var playlist = PlayList([])
    @Published var audios: [Audio] = []

    private var player: AVAudioPlayer = .init()
    private var listener: AnyCancellable?
    private var bg = AppConfig.bgQueue
    private var main = AppConfig.mainQueue
    private var rootDir: URL = AppConfig.cloudDocumentsDir

    var db: DB
    var isEmpty: Bool { audios.isEmpty }
    var isCloudStorage: Bool { iCloudHelper.isCloudPath(url: rootDir) }

    override init() {
        os_log("\(Logger.isMain)🚩 初始化 AudioManager")

        db = DB()
        super.init()

        db.onGet = onGet
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

        updatePlayer()
        play()
    }

    func play() {
        os_log("\(Logger.isMain)🔊 AudioManager::play")
        if playlist.list.count == 0 {
            os_log("\(Logger.isMain)列表为空，忽略")
            return
        }
        player.play()
        isPlaying = true

        updateMediaPlayer()
    }

    func pause() {
        player.pause()
        isPlaying = false

        updateMediaPlayer()
    }

    func stop() {
        os_log("\(Logger.isMain)🍋 AudioManager::Stop")
        player.stop()
        player.currentTime = 0
        isPlaying = false
    }

    func togglePlayPause() throws {
        if playlist.list.count == 0 {
            throw SmartError.NoAudioInList
        }

        if audio.isDownloading {
            throw SmartError.Downloading
        }

        if audio.isEmpty() {
            try next()
        }

        if player.isPlaying {
            pause()
        } else {
            play()
        }
    }

    func toggleLoop() {
        player.numberOfLoops = player.numberOfLoops == 0 ? -1 : 0
        playlist.playMode = player.numberOfLoops != 0 ? .Order : .Loop
    }

    /// 跳到上一首，manual=true表示由用户触发
    func prev(manual: Bool = false) throws -> String {
        os_log("\(Logger.isMain)🔊 AudioManager::prev ⬆️")

        // 用户触发，但曲库仅一首，发出提示
        if playlist.list.count == 1 && manual {
            throw SmartError.NoPrevAudio
        }

        try audio = playlist.prev()

        updatePlayer()
        return "上一曲：\(audio.title)"
    }

    /// 跳到下一首，manual=true表示由用户触发
    func next(manual: Bool = false) throws {
        os_log("\(Logger.isMain)🔊 AudioManager::next ⬇️ \(manual ? "手动触发" : "自动触发")")

        try audio = playlist.next(manual: manual)
        updatePlayer()
    }

    func play(_ id: Audio.ID) {
        audio = playlist.find(id)
        updatePlayer()
        play()
    }

    private func makePlayer(url: URL?) -> AVAudioPlayer {
        os_log("\(Logger.isMain)🚩 AudioManager::初始化播放器")

        guard let url = url else {
            return AVAudioPlayer()
        }

        do {
            #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
            let player = try AVAudioPlayer(contentsOf: url)

            return player
        } catch {
            os_log("\(Logger.isMain)初始化播放器失败 \n\(error)")

            return AVAudioPlayer()
        }
    }

    private func updateMediaPlayer() {
        MediaPlayerManager.setNowPlayingInfo(audioManager: self)
    }

    private func updatePlayer() {
        main.async {
            os_log("\(Logger.isMain)🍋 AudioManager::UpdatePlayer")
            self.player = self.makePlayer(url: self.audio.getURL())
            self.player.delegate = self
            self.duration = self.player.duration

            self.updateMediaPlayer()

            if self.isPlaying {
                self.player.play()
            }
        }
    }

    // 当前的 AudioModel 是否有效
    private func isValid() -> Bool {
        // 列表为空
        if playlist.list.isEmpty {
            return false
        }

        // 列表不空，当前 AudioModel 却为空
        if !playlist.list.isEmpty && audio == Audio.empty {
            return false
        }

        // 已经不在列表中了
        if !playlist.list.contains(self.audio) {
            return false
        }

        return true
    }

    private func reset() {
        stop()
        audio = Audio.empty
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

// MARK: 当数据库发生变化时

extension AudioManager {
    func delete(urls: Set<URL>) async {
        await Audio.delete(urls: urls)
    }
    
    func onGet(_ audios: [Audio]) {
        bg.async {
            os_log("\(Logger.isMain)🍋 AudioManager::onGet \(audios.count)")
            self.main.sync {
                self.playlist.merge(audios)
                self.audios = self.playlist.list
                if self.audio.isEmpty() {
                    os_log("\(Logger.isMain)🍋 AudioManager::audio is empty, update")
                    self.audio = self.playlist.audio
                    self.updatePlayer()
                }
            }
        }
    }
}
