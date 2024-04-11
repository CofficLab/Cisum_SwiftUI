import AVKit
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

class MediaPlayerManager: ObservableObject {
    var audioManager: AudioManager

    init(audioManager: AudioManager) {
        self.audioManager = audioManager
        onCommand()
    }
    
    static func setPlayingInfo(_ smartPlayer: SmartPlayer) {
        os_log("\(Logger.isMain)🍋 MediaPlayerManager::Update")
        let audio = smartPlayer.audio
        let player = smartPlayer.player
        let isPlaying = player.isPlaying
        let duration = player.duration
        let currentTime = player.currentTime
        let center = MPNowPlayingInfoCenter.default()

        guard let audio = audio else {
            return
        }

        #if os(iOS)
            let image = audio.getUIImage()

            center.nowPlayingInfo = [
                MPMediaItemPropertyTitle: audio.title,
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: image),
                MPMediaItemPropertyArtist: "乐音APP",
                MPMediaItemPropertyPlaybackDuration: duration,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            ]
        #else
            center.playbackState = isPlaying ? .playing : .paused
            center.nowPlayingInfo = [
                MPMediaItemPropertyTitle: audio.title,
                MPMediaItemPropertyArtist: "乐音APP",
                MPMediaItemPropertyPlaybackDuration: duration,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            ]
        #endif
    }

    static func setNowPlayingInfo(audioManager: AudioManager) {
        os_log("\(Logger.isMain)🍋 MediaPlayerManager::Update")
        let audio = audioManager.audio
        let player = audioManager.player
        let isPlaying = player.isPlaying
        let duration = player.duration
        let currentTime = player.currentTime
        let center = MPNowPlayingInfoCenter.default()

        guard let audio = audio else {
            return
        }

        #if os(iOS)
            let image = audio.getUIImage()

            center.nowPlayingInfo = [
                MPMediaItemPropertyTitle: audio.title,
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: image),
                MPMediaItemPropertyArtist: "乐音APP",
                MPMediaItemPropertyPlaybackDuration: duration,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            ]
        #else
            center.playbackState = isPlaying ? .playing : .paused
            center.nowPlayingInfo = [
                MPMediaItemPropertyTitle: audio.title,
                MPMediaItemPropertyArtist: "乐音APP",
                MPMediaItemPropertyPlaybackDuration: duration,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            ]
        #endif
    }

    // 接收控制中心的指令
    private func onCommand() {
        let c = MPRemoteCommandCenter.shared()

        c.nextTrackCommand.addTarget { _ in
            os_log("\(Logger.isMain)🍋 MediaPlayerManager::下一首")
            do {
                try self.audioManager.next(manual: true)
                return .success
            } catch let e {
                os_log("\(Logger.isMain)MediaPlayerManager::\(e.localizedDescription)")
                return .noActionableNowPlayingItem
            }
        }

        c.previousTrackCommand.addTarget { _ in
            os_log("\(Logger.isMain)上一首")
            do {
                try self.audioManager.prev()
                os_log("\(Logger.isMain)MediaPlayerManager::pre")
                return .success
            } catch let e {
                os_log("\(Logger.isMain)MediaPlayerManager::\(e.localizedDescription)")
                return .noActionableNowPlayingItem
            }
        }

        c.pauseCommand.addTarget { _ in
            os_log("\(Logger.isMain)🍋 MediaPlayerManger::暂停")
            self.audioManager.pause()

            return .success
        }

        c.playCommand.addTarget { _ in
            os_log("\(Logger.isMain)播放")
            self.audioManager.resume()

            return .success
        }

        c.stopCommand.addTarget { _ in
            os_log("\(Logger.isMain)停止")

            self.audioManager.stop()

            return .success
        }

        c.likeCommand.addTarget { _ in
            os_log("\(Logger.isMain)喜欢")

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
            os_log("\(Logger.isMain)🍎 changePlaybackPositionCommand")
            guard let event = e as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }

            let positionTime = event.positionTime // 获取当前的播放进度时间

            // 在这里处理当前的播放进度时间
            print("Current playback position: \(positionTime)")
            self.audioManager.gotoTime(time: positionTime)

            return .success
        }
    }
}
