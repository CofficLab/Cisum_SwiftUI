import SwiftUI
import Foundation

protocol SuperRoot: Identifiable, View {
    var iconName: String { get }
    var title: String { get }
    var description: String { get }
    var poster: any View { get }

    func getDisk() -> (any Disk)?
}

extension SuperRoot {
    var id: String {
        return String(describing: Self.self)
    }

    var isAudioApp: Bool {
        return self is AudioRoot
    }

    var isVideoApp: Bool {
        return self is VideoLayout
    }

    var isBookApp: Bool {
        return self is BookRoot
    }
}
