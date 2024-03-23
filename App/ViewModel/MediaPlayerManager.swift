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
        AppConfig.logger.mediaPlayerManager.info("更新 MediaPlayer")
        let audio = audioManager.audio
        let center = MPNowPlayingInfoCenter.default()

        #if os(iOS)
            audio.getAudioMeta { metaData in
                let image = metaData.uiImage

                center.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: audioManager.audio.title,
                    MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: image.size) { _ -> UIImage in
                        image
                    },
                    MPMediaItemPropertyArtist: "乐音APP",
                    MPMediaItemPropertyPlaybackDuration: audioManager.duration,
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: audioManager.currentTime(),
                ]
            }
        #else
            audio.getAudioMeta { _ in
                center.playbackState = audioManager.isPlaying ? .playing : .paused
                center.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: audioManager.audio.title,
                    MPMediaItemPropertyArtist: "乐音APP",
                    MPMediaItemPropertyPlaybackDuration: audioManager.duration,
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: audioManager.currentTime(),
                ]
            }
        #endif
    }

    // 接收控制中心的指令
    private func onCommand() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.nextTrackCommand.addTarget { _ in
            AppConfig.logger.mediaPlayerManager.info("下一首")
            self.audioManager.next({ _ in })

            return .success
        }

        commandCenter.previousTrackCommand.addTarget { _ in
            AppConfig.logger.mediaPlayerManager.info("上一首")
            self.audioManager.prev({ _ in })

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
