import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

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

// 管理播放器的播放、暂停、上一曲、下一曲等操作
class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @ObservedObject var databaseManager: DatabaseManager

    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isLooping: Bool = false
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var audios: [AudioModel] = []
    @Published var audio = AudioModel.empty
    @Published var playMode: PlayMode = .Random

    static var preview = AudioManager(databaseManager: DatabaseManager.preview)
    private var player: AVAudioPlayer = AVAudioPlayer()
    private var listener: AnyCancellable?

    init(databaseManager: DatabaseManager) {
        AppConfig.logger.audioManager.info("初始化 AudioManager")

        self.databaseManager = databaseManager
        audios = databaseManager.audios

        super.init()

        listener = databaseManager.$audios.sink { newValue in
            AppConfig.logger.audioManager.notice("检测到 DatabaseManger.audios 变了，数量变成了 \(newValue.count)")
            self.audios = newValue
            AppConfig.logger.audioManager.notice("当前曲目数量：\(self.audios.count)")

            if !self.isValid() && self.audios.count > 0 {
                AppConfig.logger.audioManager.info("当前播放的已经无效，切换到下一曲")
                self.next({ _ in })
            }

            if self.audios.count == 0 {
                AppConfig.logger.audioManager.info("列表已经空了，重置播放器")
                self.reset()
            }
        }

        if audios.count > 0 {
            AppConfig.logger.audioManager.info("初始化Player")
            audio = audios.first!
            AppConfig.logger.audioManager.info("初始化的曲目：\(self.audio.title, privacy: .public)")
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
        AppConfig.logger.audioManager.info("play()")
        if audios.count == 0 {
            AppConfig.logger.audioManager.info("列表为空，忽略")
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
        AppConfig.logger.audioManager.info("stop()")
        player.stop()
        player.currentTime = 0
        isPlaying = false
    }

    func togglePlayPause(_ callback: @escaping (_ message: String) -> Void) {
        if audios.count == 0 {
            callback("播放列表为空")
            return
        }

        if audio.getiCloudState() == .Downloading {
            callback("正在从 iCloud 下载")
            return
        }

        if player.isPlaying {
            callback("")
            pause()
        } else {
            callback("")
            play()
        }
    }

    func switchPlayMode(_ callback: @escaping (_ mode: PlayMode) -> Void) {
        switch playMode {
        case .Order:
            playMode = .Random
        case .Loop:
            playMode = .Order
        case .Random:
            playMode = .Loop
        }

        callback(playMode)
    }

    func toggleLoop() {
        player.numberOfLoops = player.numberOfLoops == 0 ? -1 : 0
        isLooping = player.numberOfLoops != 0
    }

    func prev(_ callback: @escaping (_ message: String) -> Void) {
        AppConfig.logger.audioManager.info("上一曲")

        if audios.count == 0 {
            callback("播放列表为空")
        } else {
            switch playMode {
            case .Loop:
                let index = audios.firstIndex(of: audio)!
                audio = audios[index - 1 >= 0 ? index - 1 : audios.count - 1]
                AppConfig.logger.audioManager.debug("单曲循环模式手动触发上一曲，上一曲是: \(self.audio.title, privacy: .public)")
            case .Random:
                audio = randomExcludeCurrent()
                AppConfig.logger.audioManager.debug("随机模式，上一曲是: \(self.audio.title, privacy: .public)")
                break
            case .Order:
                let index = audios.firstIndex(of: audio)!
                audio = audios[index - 1 >= 0 ? index - 1 : audios.count - 1]
                AppConfig.logger.audioManager.debug("顺序模式，上一曲是: \(self.audio.title, privacy: .public)")
                break
            }

            updatePlayer()
//            callback("上一曲：\(audio.title)")
            callback("")
        }
    }

    func next(_ callback: @escaping (_ message: String) -> Void, manual: Bool = true) {
        AppConfig.logger.audioManager.info("下一曲")

        if audios.count == 0 {
            AppConfig.logger.audioManager.warning("列表为空")
            callback("播放列表为空")
        } else {
            switch playMode {
            case .Loop:
                if manual {
                    let index = audios.firstIndex(of: audio)!
                    audio = audios[index + 1 >= audios.count ? 0 : index + 1]
                    AppConfig.logger.audioManager.debug("单曲循环模式手动触发下一曲，下一曲是: \(self.audio.title, privacy: .public)")
                } else {
                    AppConfig.logger.audioManager.debug("单曲循环模式自动触发下一曲，下一曲是: 不变")
                }
            case .Random:
                audio = randomExcludeCurrent()
                AppConfig.logger.audioManager.debug("随机模式，下一曲是: \(self.audio.title, privacy: .public)")
                break
            case .Order:
                let index = audios.firstIndex(of: audio)!
                audio = audios[index + 1 >= audios.count ? 0 : index + 1]
                AppConfig.logger.audioManager.debug("顺序模式，下一曲是: \(self.audio.title, privacy: .public)")
                break
            }

            updatePlayer()
//            callback("下一曲：\(audio.title)")
            callback("")
        }
    }

    func playFile(url: URL) {
        let audioModel = AudioModel(url)
        if audios.contains([audioModel]) {
            AppConfig.logger.audioManager.info("曲库中包含要播放的：\(url.lastPathComponent)")
            audio = audioModel
            updatePlayer()
            play()
        } else {
            AppConfig.logger.audioManager.info("曲库中不包含要播放的：\(url.lastPathComponent)")
        }
    }

    private func makePlayer(url: URL) -> AVAudioPlayer {
        AppConfig.logger.audioManager.info("初始化播放器")
        do {
            #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
            let player = try AVAudioPlayer(contentsOf: url)

            return player
        } catch {
            AppConfig.logger.audioManager.error("初始化播放器失败 \n\(error)")

            return AVAudioPlayer()
        }
    }

    private func makeEmptyPlayer() -> AVAudioPlayer {
        return AVAudioPlayer()
    }

    private func updateMediaPlayer() {
        MediaPlayerManager.setNowPlayingInfo(audioManager: self)
    }

    private func updatePlayer() {
        AppConfig.bgQueue.async {
            var player = AVAudioPlayer()
            if self.audio == AudioModel.empty {
                player = self.makeEmptyPlayer()
            } else {
                player = self.makePlayer(url: self.audio.url)
            }

            AppConfig.mainQueue.async {
                AppConfig.logger.audioManager.debug("在主进程更新 AudioManager 数据")
                self.player = player
                self.player.delegate = self
                self.duration = self.player.duration

                self.updateMediaPlayer()

                if self.isPlaying {
                    self.player.play()
                }
            }
        }
    }

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

        AppConfig.logger.audioManager.info("播放完成，自动播放下一曲")
        next({ _ in }, manual: false)
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

    private func randomExcludeCurrent() -> AudioModel {
        if audios.count == 1 {
            AppConfig.logger.audioManager.debug("只有一条，随机选一条就是第一条")
            return audios.first!
        }

        let result = (audios.filter { $0 != audio }).randomElement()!
        AppConfig.logger.audioManager.debug("共 \(self.audios.count, privacy: .public) 条，随机选一条: \(result.url.lastPathComponent, privacy: .public)")

        return result
    }
}
