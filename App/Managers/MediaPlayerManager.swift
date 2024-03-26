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
            os_log("MediaPlayerManager::下一首")
            do {
                let message = try self.audioManager.next()
                os_log("MediaPlayerManager::\(message)")
                return .success
            } catch let e {
                os_log("MediaPlayerManager::\(e.localizedDescription)")
                return .noActionableNowPlayingItem
            }
        }

        commandCenter.previousTrackCommand.addTarget { _ in
            AppConfig.logger.mediaPlayerManager.info("上一首")
            self.audioManager.prev()

            return .success
        }

        commandCenter.pauseCommand.addTarget { _ in
            AppConfig.logger.mediaPlayerManager.info("暂停")
            self.audioManager.pause()

            return .success
        }

        commandCenter.playCommand.addTarget { _ in
            AppConfig.logger.mediaPlayerManager.info("播放")
            self.audioManager.play()

            return .success
        }

        commandCenter.stopCommand.addTarget { _ in
            AppConfig.logger.mediaPlayerManager.info("停止")

            self.audioManager.stop()

            return .success
        }

        commandCenter.likeCommand.addTarget { _ in
            AppConfig.logger.mediaPlayerManager.info("喜欢")

            return .success
        }

        commandCenter.ratingCommand.addTarget { _ in
            AppConfig.logger.mediaPlayerManager.info("评分")

            return .success
        }

        commandCenter.changeRepeatModeCommand.addTarget { _ in
            AppConfig.logger.mediaPlayerManager.info("changeRepeatModeCommand")

            return .success
        }
    }
}
