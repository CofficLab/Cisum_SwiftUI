import Foundation
import SwiftUI
import SwiftData
import OSLog

enum ViewConfig {
    static var isDesktop: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }
    
    static var isNotDesktop: Bool { !isDesktop }
    
    @AppStorage("UI.ShowDB")
    static var showDB: Bool = false
    
    static func setShowDB(_ value: Bool) {
        //os_log("\(Logger.isMain)⚙️ AppConfig::setCurrentAudio \(audio.title)")
        ViewConfig.showDB = value
    }
}

// MARK: 背景

extension ViewConfig {
    /// 开发时如果不想显示背景，改成true
    static var noBackground = true
    
    /// 生产环境一定不会显示背景
    static func background(_ color: Color = .red) -> Color {
        AppConfig.debug && !noBackground ? color.opacity(0.3) : Color.clear
    }
}

// MARK: 响应式配置

extension ViewConfig {
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
    static var minHeight: CGFloat = 250
    static var defaultHeight: CGFloat = 360
    
    /// 大于此高度，可展示封面图
    static var minHeightToShowAlbum: CGFloat = 450
    
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

#Preview("App") {
    AppPreview()
}

#Preview("iPhone 15") {
    LayoutView(device: .iPhone_15)
}

#Preview("500") {
    LayoutView(width: 500)
}
