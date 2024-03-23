import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

// 管理播放器的播放、暂停、上一曲、下一曲等操作
class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioManager(databaseManager: DatabaseManager.shared)

    @ObservedObject var databaseManager: DatabaseManager

    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isLooping: Bool = false
    @Published private(set) var title: String = "标题未设置"
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var audios: [AudioModel] = []
    @Published private(set) var currentAudioModel: AudioModel = emptyAudioModel
    
    private var index: Int = 0
    private var player: AVAudioPlayer = AVAudioPlayer()
    private var listener: AnyCancellable?

    init(databaseManager: DatabaseManager) {
        AppConfig.logger.audioManager.debugSomething("初始化")

        self.databaseManager = databaseManager
        audios = databaseManager.audios

        super.init()

        listener = databaseManager.$audios.sink { newValue in
            self.audios = newValue
            
            if !(self.audios ~= [self.currentAudioModel]) {
                AppConfig.logger.audioManager.debugEvent("当前播放的已经不在列表中了，切换到下一曲")
                self.next()
            }
        }

        if audios.count > 0 {
            AppConfig.logger.audioManager.debugSomething("初始化Player")
            currentAudioModel = audios.first!
            updatePlayer()
        }
    }

    func currentTime() -> TimeInterval {
        return player.currentTime
    }

    func leftTime() -> TimeInterval {
        return player.duration - player.currentTime
    }

    func gotoTime(time: TimeInterval) {
        player.currentTime = time
        updateMediaPlayer()
    }

    func replay() {
        AppConfig.logger.audioManager.debugEvent("replay()")

        updatePlayer()
        play()
    }

    func play() {
        AppConfig.logger.audioManager.debugEvent("play()")
        if audios.count == 0 {
            AppConfig.logger.audioManager.debugEvent("列表为空，忽略")
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
        AppConfig.logger.audioManager.debugEvent("stop()")
        player.stop()
        player.currentTime = 0
        isPlaying = false
    }

    func togglePlayPause() {
        if player.isPlaying {
            pause()
        } else {
            play()
        }
    }

    func toggleLoop() {
        player.numberOfLoops = player.numberOfLoops == 0 ? -1 : 0
        isLooping = player.numberOfLoops != 0
    }

    func prev() {
        AppConfig.logger.audioManager.debugEvent("prev()")
        index = index == 0 ? audios.count - 1 : index - 1
        currentAudioModel = audios[index]

        updatePlayer()
    }

    func next() {
        AppConfig.logger.audioManager.debugEvent("next()")
        if audios.count == 0 {
            return
        }
        
        index = index + 1 >= audios.count ? 0 : index + 1
        currentAudioModel = audios[index]

        updatePlayer()
    }

    private func makePlayer(url: URL) -> AVAudioPlayer {
        AppConfig.logger.audioManager.debugSomething("播放： \(url.lastPathComponent)")
        do {
            let player = try AVAudioPlayer(contentsOf: url)

            return player
        } catch {
            AppConfig.logger.audioManager.e("初始化播放器失败 \n\(error)")

            return AVAudioPlayer()
        }
    }
    
    private func updateMediaPlayer() {
        MediaPlayerManager.setNowPlayingInfo(audioManager: self)
    }

    private func updatePlayer() {
        player = makePlayer(url: currentAudioModel.url)
        player.delegate = AudioDelegate.shared

        duration = player.duration
        title = currentAudioModel.title

        updateMediaPlayer()

        if isPlaying {
            player.play()
        }
    }
}
