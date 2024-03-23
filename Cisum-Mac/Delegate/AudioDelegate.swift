import AVKit
import Foundation
import OSLog
import MediaPlayer

class AudioDelegate: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static var audioManager: AudioManager = AudioManager.shared
    static var shared: AudioDelegate = AudioDelegate()
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 没有播放完，被打断了
        if !flag {
            AppConfig.logger.audioManager.debugEvent("播放被打断，更新为暂停状态")
            AudioDelegate.audioManager.pause()
            return
        }
        
        if AudioDelegate.audioManager.isLooping {
            AppConfig.logger.audioManager.debugEvent("播放完成，再次播放当前曲目")
            AudioDelegate.audioManager.play()
            return
        }
        
        AppConfig.logger.audioManager.debugEvent("播放完成，自动播放下一曲")
        AudioDelegate.audioManager.next()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        AppConfig.logger.app.e("audioPlayerDecodeErrorDidOccur")
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        AppConfig.logger.app.debugEvent("audioPlayerBeginInterruption")
        AudioDelegate.audioManager.pause()
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        AppConfig.logger.app.debugEvent("audioPlayerEndInterruption")
        AudioDelegate.audioManager.play()
    }
}
