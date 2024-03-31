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
    os_log("\(Logger.isMain)🍋 MediaPlayerManager::Update")
    let audio = audioManager.audio
    let center = MPNowPlayingInfoCenter.default()

    #if os(iOS)
      let image = audio.uiImage

      center.nowPlayingInfo = [
        MPMediaItemPropertyTitle: audioManager.audio.title,
        MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: image),
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
      os_log("\(Logger.isMain)🍋 MediaPlayerManager::下一首")
      do {
        try self.audioManager.next()
        return .success
      } catch let e {
        os_log("\(Logger.isMain)MediaPlayerManager::\(e.localizedDescription)")
        return .noActionableNowPlayingItem
      }
    }

    commandCenter.previousTrackCommand.addTarget { _ in
      os_log("\(Logger.isMain)上一首")
      do {
        let message = try self.audioManager.prev()
        os_log("\(Logger.isMain)MediaPlayerManager::\(message)")
        return .success
      } catch let e {
        os_log("\(Logger.isMain)MediaPlayerManager::\(e.localizedDescription)")
        return .noActionableNowPlayingItem
      }
    }

    commandCenter.pauseCommand.addTarget { _ in
      os_log("\(Logger.isMain)🍋 MediaPlayerManger::暂停")
      self.audioManager.pause()

      return .success
    }

    commandCenter.playCommand.addTarget { _ in
      os_log("\(Logger.isMain)播放")
      self.audioManager.play()

      return .success
    }

    commandCenter.stopCommand.addTarget { _ in
      os_log("\(Logger.isMain)停止")

      self.audioManager.stop()

      return .success
    }

    commandCenter.likeCommand.addTarget { _ in
      os_log("\(Logger.isMain)喜欢")

      return .success
    }

    commandCenter.ratingCommand.addTarget { _ in
      os_log("\(Logger.isMain)评分")

      return .success
    }

    commandCenter.changeRepeatModeCommand.addTarget { _ in
      os_log("\(Logger.isMain)changeRepeatModeCommand")

      return .success
    }

    commandCenter.changePlaybackPositionCommand.addTarget { e in
      os_log("\(Logger.isMain)🍎 changePlaybackPositionCommand")
      guard let event = e as? MPChangePlaybackPositionCommandEvent else {
        return .commandFailed
      }

      let positionTime = event.positionTime  // 获取当前的播放进度时间

      // 在这里处理当前的播放进度时间
      print("Current playback position: \(positionTime)")
      self.audioManager.gotoTime(time: positionTime)

      return .success
    }
  }
}
