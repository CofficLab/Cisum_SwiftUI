import Foundation
import OSLog

class SuperAudioDelegateSample: SuperAudioDelegate {}

protocol SuperAudioDelegate {
    func onCoverUpdated()
}

extension SuperAudioDelegate {
    func onCoverUpdated() {
//        os_log("🍋 SuperAudioDelegate::onCoverUpdated")
    }
}

