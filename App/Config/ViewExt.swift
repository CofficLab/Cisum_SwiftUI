import Foundation
import SwiftUI

// MARK: 视图配置

extension AppConfig {
    static var rootBackground: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            BackgroundView.type2A
        }
    }
    /// 上半部分播放控制的最小高度
    static var controlViewMinHeight: CGFloat = Self.minHeight
    static var databaseViewHeightMin: CGFloat = 200
    static var minWidth: CGFloat = 350
    static var minHeight: CGFloat = 320
    static var defaultHeight: CGFloat = 360
    #if os(macOS)
    static var canResize = true
    #else
    static var canResize = false
    #endif
    static var getBackground: Color {
        #if os(macOS)
        Color(.controlBackgroundColor)
        #else
        Color(.systemBackground)
        #endif
    }
}
