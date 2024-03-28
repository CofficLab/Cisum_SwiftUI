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

    static func setNowPlayingInfo(audioManager: AudioManager) {
        os_log("🍋 MediaPlayerManager::Update")
        let audio = audioManager.audio
        let center = MPNowPlayingInfoCenter.default()

        #if os(iOS)
            let image = audio.uiImage

            center.nowPlayingInfo = [
                MPMediaItemPropertyTitle: audioManager.audio.title,
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: image.size) { _ -> UIImage in
                    image
                },
                MPMediaItemPropertyArtist: "乐音APP",
                MPMediaItemPropertyPlaybackDuration: audioManager.duration,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: audioManager.currentTime(),
            ]
        #else
            center.playbackState = audioManager.isPlaying ? .playing : .paused
            center.nowPlayingInfo = [
                MPMediaItemPropertyTitle: audio.title,
                MPMediaItemPropertyArtist: "乐音APP",
                MPMediaItemPropertyPlaybackDuration: audioManager.duration,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: audioManager.currentTime(),
            ]
        #endif
    }

    // 接收控制中心的指令
    private func onCommand() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.nextTrackCommand.addTarget { _ in
            os_log("🍋 MediaPlayerManager::下一首")
            do {
                try self.audioManager.next()
                return .success
            } catch let e {
                os_log("MediaPlayerManager::\(e.localizedDescription)")
                return .noActionableNowPlayingItem
            }
        }

        commandCenter.previousTrackCommand.addTarget { _ in
            os_log("上一首")
            do {
                let message = try self.audioManager.prev()
                os_log("MediaPlayerManager::\(message)")
                return .success
            } catch let e {
                os_log("MediaPlayerManager::\(e.localizedDescription)")
                return .noActionableNowPlayingItem
            }
        }

        commandCenter.pauseCommand.addTarget { _ in
            os_log("🍋 MediaPlayerManger::暂停")
            self.audioManager.pause()

            return .success
        }

        commandCenter.playCommand.addTarget { _ in
            os_log("播放")
            self.audioManager.play()

            return .success
        }

        commandCenter.stopCommand.addTarget { _ in
            os_log("停止")

            self.audioManager.stop()

            return .success
        }

        commandCenter.likeCommand.addTarget { _ in
            os_log("喜欢")

            return .success
        }

        commandCenter.ratingCommand.addTarget { _ in
            os_log("评分")

            return .success
        }

        commandCenter.changeRepeatModeCommand.addTarget { _ in
            os_log("changeRepeatModeCommand")

            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { e in
            os_log("🍎 changePlaybackPositionCommand")
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
