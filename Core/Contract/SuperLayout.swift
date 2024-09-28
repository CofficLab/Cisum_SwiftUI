import SwiftUI
import Foundation

protocol SuperLayout: Identifiable {
    var id: String { get }
    var iconName: String { get }
    var icon: any View { get }
    var title: String { get }
    var description: String { get }
    var poster: any View { get }
    var rootView: any View { get }

    func boot()
    func getDisk() -> (any Disk)?
    func setCurrent(url: URL)
    func getCurrent() -> URL?
    func setCurrentPlayMode(mode: PlayMode)
    func getCurrentPlayMode() -> PlayMode?
}

extension SuperLayout {
    var isAudioApp: Bool {
        return self is AudioLayout
    }

    var isVideoApp: Bool {
        return self is VideoLayout
    }

    var isBookApp: Bool {
        return self is BookLayout
    }
}
