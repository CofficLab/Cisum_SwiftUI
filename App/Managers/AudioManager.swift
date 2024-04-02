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
    @Published var audio: Audio?
    @Published var playlist = PlayList([])
    @Published var playerError: Error? = nil

    private var player: AVAudioPlayer = .init()
    private var listener: AnyCancellable?
    private var bg = AppConfig.bgQueue
    private var main = AppConfig.mainQueue
    private var rootDir: URL = AppConfig.cloudDocumentsDir

    var db: DB
    var isEmpty: Bool { playlist.isEmpty }
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

        do {
            try updatePlayer()
        } catch let e {
            self.playerError = e
            return
        }

        play()
    }

    // MARK: 播放

    /// 播放指定的
    func play(_ id: Audio.ID) {
        do {
            try playlist.switchTo(id)
            self.audio = playlist.audio
            play()
        } catch let e {
            self.playerError = e
        }
    }

    /// 播放当前的
    func play() {
        os_log("\(Logger.isMain)🔊 AudioManager::play")
        if playlist.isEmpty {
            os_log("\(Logger.isMain)列表为空，忽略")
            return
        }

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
        
        if playlist.isEmpty {
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
        playlist.playMode = player.numberOfLoops != 0 ? .Order : .Loop
    }

    func switchMode(_ callback: @escaping (_ mode: PlayList.PlayMode) -> Void) {
        self.playlist.switchMode({ mode in
            callback(mode)
        })
    }
    
    // MARK: Prev

    /// 跳到上一首，manual=true表示由用户触发
    func prev(manual: Bool = false) throws -> String {
        os_log("\(Logger.isMain)🔊 AudioManager::prev ⬆️")

        // 用户触发，但曲库仅一首，发出提示
        if playlist.isEmpty && manual {
            throw SmartError.NoPrevAudio
        }

        try audio = playlist.prev()
        
        guard let audio = audio else {
            throw SmartError.NoPrevAudio
        }

        try updatePlayer()
        return "上一曲：\(audio.title)"
    }
    
    // MARK: Next

    /// 跳到下一首，manual=true表示由用户触发
    func next(manual: Bool = false) throws {
        os_log("\(Logger.isMain)🔊 AudioManager::next ⬇️ \(manual ? "手动触发" : "自动触发")")

        try audio = playlist.next(manual: manual)
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
        if playlist.isEmpty {
            return false
        }
        
        guard let audio = audio else {
            return false
        }

        // 已经不在列表中了
        if playlist.contains(audio.id) {
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

// MARK: 当数据库发生变化时

extension AudioManager {
    func onGet(_ audios: [Audio]) {
        bg.async {
            os_log("\(Logger.isMain)🍋 AudioManager::onGet \(audios.count)")
            self.playlist.merge(audios)
            self.main.sync {
                if self.audio == nil {
                    os_log("\(Logger.isMain)🍋 AudioManager::audio is empty, update")
                    self.audio = self.playlist.audio

                    do {
                        try self.updatePlayer()
                    } catch let e {
                        self.playerError = e
                    }
                }
            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
