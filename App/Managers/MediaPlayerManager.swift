import AVKit
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

class MediaPlayerManager: ObservableObject {
    static var label = "📱 MediaPlayerManager::"

    var label: String { MediaPlayerManager.label }
    var audioManager: AudioManager
    var player: SmartPlayer { audioManager.player }

    init(audioManager: AudioManager) {
        self.audioManager = audioManager
        onCommand()
    }

    static func setPlayingInfo(_ smartPlayer: SmartPlayer) {
        let audio = smartPlayer.audio
        let player = smartPlayer.player
        let isPlaying = player.isPlaying
        let duration = player.duration
        let currentTime = player.currentTime
        let center = MPNowPlayingInfoCenter.default()
        
        os_log("\(Logger.isMain)\(MediaPlayerManager.label)Update -> \(smartPlayer.state.des) -> \(audio?.title ?? "-")")
        
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
            os_log("\(Logger.isMain)\(self.label)下一首")
            self.audioManager.next(manual: true)
            return .success
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
            os_log("\(Logger.isMain)\(self.label)暂停")
            self.player.pause()

            return .success
        }

        c.playCommand.addTarget { _ in
            os_log("\(Logger.isMain)播放")
            self.player.resume()

            return .success
        }

        c.stopCommand.addTarget { _ in
            os_log("\(Logger.isMain)停止")

            self.player.stop()

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
            os_log("\(Logger.isMain)\(self.label)changePlaybackPositionCommand")
            guard let event = e as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }

            let positionTime = event.positionTime // 获取当前的播放进度时间

            // 在这里处理当前的播放进度时间
            print("Current playback position: \(positionTime)")
            self.player.gotoTime(time: positionTime)

            return .success
        }
    }
}
