import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

// 管理播放器的播放、暂停、上一曲、下一曲等操作
class AudioManager: NSObject, ObservableObject {
    @ObservedObject var dbManager: DBManager

    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isLooping: Bool = false
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var audios: [AudioModel] = []
    @Published var audio = AudioModel.empty
    @Published var list = PlayList([])

    static var preview = AudioManager(dbManager: DBManager.preview)
    private var player: AVAudioPlayer = .init()
    private var listener: AnyCancellable?

    init(dbManager: DBManager) {
        os_log("🚩 初始化 AudioManager")

        self.dbManager = dbManager
        audios = dbManager.audios

        super.init()

        list = PlayList(audios)
        listener = dbManager.$audios.sink { newValue in
            os_log("🍋 AudioManager::DatabaseManger.audios.count changed to \(newValue.count)")
            self.audios = newValue
            self.list = PlayList(self.audios)

            if !self.isValid() && self.audios.count > 0 {
                os_log("🍋 AudioManager::当前播放的已经无效，切换到下一曲")
                do {
                    let message = try self.next()
                    os_log("🍋 AudioManager:: ⬇️ \(message)")
                } catch let e {
                    os_log("‼️ AudioManager::\(e.localizedDescription)")
                }
            }

            if self.audios.count == 0 {
                os_log("🍋 AudioManager::no audio, reset")
                self.reset()
            }
        }

        if audios.count > 0 {
            os_log("初始化Player")
            audio = audios.first!
            os_log("初始化的曲目：\(self.audio.title, privacy: .public)")
            updatePlayer()
        }
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
        AppConfig.logger.audioManager.info("replay()")

        updatePlayer()
        play()
    }

    func play() {
        os_log("🔊 AudioManager::play")
        if list.audios.count == 0 {
            os_log("列表为空，忽略")
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
        os_log("🍋 AudioManager::Stop")
        player.stop()
        player.currentTime = 0
        isPlaying = false
    }

    func togglePlayPause() throws -> String {
        if audios.count == 0 {
            return "播放列表为空"
        }

        if audio.getiCloudState() == .Downloading {
            return "正在从 iCloud 下载"
        }

        if audio.isEmpty() {
            return try next()
        }

        if player.isPlaying {
            pause()
            return ""
        } else {
            play()

            return ""
        }
    }

    func toggleLoop() {
        player.numberOfLoops = player.numberOfLoops == 0 ? -1 : 0
        isLooping = player.numberOfLoops != 0
    }

    /// 跳到上一首，manual=true表示由用户触发
    func prev(manual: Bool = false) throws -> String {
        os_log("🔊 AudioManager::prev ⬆️")

        // 用户触发，但曲库仅一首，发出提示
        if list.audios.count == 1 && manual {
            throw SmartError.NoPrevAudio
        }

        try audio = list.prev()

        updatePlayer()
        return "上一曲：\(audio.title)"
    }

    /// 跳到下一首，manual=true表示由用户触发
    func next(manual: Bool = false) throws -> String {
        os_log("🔊 AudioManager::next ⬇️")

        // 用户触发，但曲库仅一首，发出提示
        if list.audios.count == 1 && manual {
            throw SmartError.NoNextAudio
        }

        try audio = list.next()

        updatePlayer()
        return "下一曲：\(audio.title)"
    }

    func play(_ audio: AudioModel) {
        if list.audios.contains([audio]) {
            os_log("曲库中包含要播放的：\(audio.title)")
            self.audio = audio
            updatePlayer()
            play()
        } else {
            os_log("曲库中不包含要播放的：\(audio.title)")
        }
    }

    private func makePlayer(url: URL?) -> AVAudioPlayer {
        os_log("🚩 AudioManager::初始化播放器")
        
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
            os_log("初始化播放器失败 \n\(error)")

            return AVAudioPlayer()
        }
    }

    private func updateMediaPlayer() {
        MediaPlayerManager.setNowPlayingInfo(audioManager: self)
    }

    private func updatePlayer() {
        AppConfig.mainQueue.async {
            os_log("🍋 AudioManager::Update")
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
        if audios.isEmpty {
            return false
        }

        // 列表不空，当前 AudioModel 却为空
        if !audios.isEmpty && audio == AudioModel.empty {
            return false
        }

        // 已经不在列表中了
        if !audios.contains(where: { $0 == self.audio }) {
            return false
        }

        return true
    }

    private func reset() {
        stop()
        audio = AudioModel.empty
        player = AVAudioPlayer()
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 没有播放完，被打断了
        if !flag {
            AppConfig.logger.audioManager.info("播放被打断，更新为暂停状态")
            pause()
            return
        }

        if isLooping {
            AppConfig.logger.audioManager.info("播放完成，再次播放当前曲目")
            play()
            return
        }

        os_log("🍋 AudioManager::播放完成，自动播放下一曲")
        do {
            let message = try next(manual: false)
            os_log("🍋 AudioManager::\(message)")
        } catch let e {
            os_log("‼️ AudioManager::\(e.localizedDescription)")
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        AppConfig.logger.audioManager.info("audioPlayerDecodeErrorDidOccur")
    }

    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        AppConfig.logger.audioManager.info("audioPlayerBeginInterruption")
        pause()
    }

    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        AppConfig.logger.audioManager.info("audioPlayerEndInterruption")
        play()
    }
}
