import Foundation
import MagicKit

import SwiftUI

extension Config {
    static var getBackground: Color {
        #if os(macOS)
            Color(.controlBackgroundColor)
        #else
            Color(.systemBackground)
        #endif
    }

    static var isDesktop = MagicApp.isDesktop
    static var isNotDesktop = MagicApp.isNotDesktop
    static var isiOS = MagicApp.isiOS

    @AppStorage("UI.ShowDB")
    static var showDB: Bool = false

    static func setShowDB(_ value: Bool) {
        Config.showDB = value
    }

    /// 开发时如果不想显示背景，改成true
    static var noBackground = true

    /// 生产环境一定不会显示背景
    static func background(_ color: Color = .red) -> Color {
        Config.debug && !noBackground ? color.opacity(0.3) : Color.clear
    }

    /// 上半部分播放控制的最小高度
    static var controlViewMinHeight: CGFloat = Self.minHeight
    static var databaseViewHeightMin: CGFloat = 200
    static var minWidth: CGFloat = 350
    static var minHeight: CGFloat = 250
    static var defaultHeight: CGFloat = 360

    /// 大于此高度，可展示封面图
    static var minHeightToShowAlbum: CGFloat = 450

    #if os(macOS)
        static var canResize = true
    #else
        static var canResize = false
    #endif
}
