import Foundation
import SwiftUI

// MARK: - StorageLocation

enum StorageLocation: String, Codable {
    case icloud
    case local
    case custom

    var emojiTitle: String {
        self.emoji + " " + self.title
    }

    var emoji: String {
        switch self {
        case .icloud: return "🌐"
        case .local: return "💾"
        case .custom: return "🔧"
        }
    }

    var title: String {
        switch self {
        case .icloud: return "iCloud"
        case .local: return "本地"
        case .custom: return "自定义"
        }
    }

    var description: String {
        switch self {
        case .icloud: return "使用iCloud存储数据"
        case .local: return "使用本地存储数据"
        case .custom: return "使用自定义存储数据"
        }
    }
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
