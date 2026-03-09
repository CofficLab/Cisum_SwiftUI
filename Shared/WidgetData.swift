import Foundation
import MagicKit
import OSLog
import SwiftUI
import WidgetKit

struct WidgetData: Codable, SuperLog {
    static let suiteName = "group.com.yueyi.cisum"
    static let emoji = "🐶"
    static let verbose = false

    var title: String
    var artist: String
    var isPlaying: Bool
    var coverArtData: Data?

    static let empty = WidgetData(title: "Not Playing", artist: "Cisum", isPlaying: false, coverArtData: nil)

    struct Keys {
        static let data = "widgetData"
    }

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static func save(title: String, artist: String, isPlaying: Bool, coverArt: Data?) {
        let data = WidgetData(title: title, artist: artist, isPlaying: isPlaying, coverArtData: coverArt)
        if let encoded = try? JSONEncoder().encode(data) {
            sharedDefaults?.set(encoded, forKey: Keys.data)
            if Self.verbose {
                os_log("\(Self.t)💾 已保存小组件数据到 \(suiteName)：\(title) - \(artist)（播放中：\(isPlaying)）")
            }
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            os_log(.error, "\(Self.t)编码小组件数据失败")
        }
    }

    static func load() -> WidgetData {
        guard let data = sharedDefaults?.data(forKey: Keys.data),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            if Self.verbose {
                os_log("\(Self.t)从 \(suiteName) 加载小组件数据失败，返回空数据")
            }
            return .empty
        }
        if Self.verbose {
            os_log("\(Self.t)已加载小组件数据：\(decoded.title) - \(decoded.artist)")
        }
        return decoded
    }
}

extension Notification.Name {
    static let widgetPlayPause = Notification.Name("widgetPlayPause")
    static let widgetNext = Notification.Name("widgetNext")
    static let widgetPrevious = Notification.Name("widgetPrevious")
}
