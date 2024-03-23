import AVKit
import Foundation
import OSLog
import MediaPlayer

class AudioDelegate: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioManager: AudioManager
    
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 没有播放完，被打断了
        if !flag {
            AppConfig.logger.audioManager.info("播放被打断，更新为暂停状态")
            audioManager.pause()
            return
        }
        
        if audioManager.isLooping {
            AppConfig.logger.audioManager.info("播放完成，再次播放当前曲目")
            audioManager.play()
            return
        }
        
        AppConfig.logger.audioManager.info("播放完成，自动播放下一曲")
        audioManager.next({_ in})
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        AppConfig.logger.audioManager.info("audioPlayerDecodeErrorDidOccur")
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        AppConfig.logger.audioManager.info("audioPlayerBeginInterruption")
        audioManager.pause()
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        AppConfig.logger.audioManager.info("audioPlayerEndInterruption")
        audioManager.play()
    }
}
