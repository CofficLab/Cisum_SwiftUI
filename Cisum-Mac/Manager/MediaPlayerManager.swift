import AVKit
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

class MediaPlayerManager {
    static func setNowPlayingInfo(audioManager: AudioManager) {
        AppConfig.logger.mediaPlayerManager.debugEvent("更新")
//        let image = UIImage(named: "beach")!
//
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
//            MPMediaItemPropertyTitle: audioManager.title,
//            MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: image.size) { _ -> UIImage in
//                image
//            },
//            MPMediaItemPropertyArtist: "乐音APP",
//            MPMediaItemPropertyPlaybackDuration: audioManager.duration,
//            MPNowPlayingInfoPropertyElapsedPlaybackTime: audioManager.currentTime()
//        ]
    }

    // 接收控制中心的指令
    static func onCommand() {
        let commandCenter = MPRemoteCommandCenter.shared()
        let audioManager = AudioManager.shared

        commandCenter.nextTrackCommand.addTarget { _ in
            AppConfig.logger.app.debugEvent("下一首")
            audioManager.next()

            return .success
        }

        commandCenter.previousTrackCommand.addTarget { _ in
            AppConfig.logger.app.debugEvent("上一首")
            audioManager.prev()

            return .success
        }

        commandCenter.pauseCommand.addTarget { _ in
            AppConfig.logger.app.debugEvent("暂停")
            audioManager.pause()

            return .success
        }

        commandCenter.playCommand.addTarget { _ in
            AppConfig.logger.app.debugEvent("播放")
            audioManager.play()

            return .success
        }
        
        commandCenter.stopCommand.addTarget { _ in
            AppConfig.logger.app.debugEvent("停止")
            
            audioManager.stop()
            
            return .success
        }
        
        commandCenter.likeCommand.addTarget { _ in
            AppConfig.logger.app.debugEvent("喜欢")
            
            return .success
        }
        
        commandCenter.ratingCommand.addTarget { _ in
            AppConfig.logger.app.debugEvent("评分")
            
            return .success
        }
        
        commandCenter.changeRepeatModeCommand.addTarget { _ in
            AppConfig.logger.app.debugEvent("changeRepeatModeCommand")
            
            return .success
        }
    }
}
