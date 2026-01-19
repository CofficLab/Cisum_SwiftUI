import MagicKit
import SwiftUI

/// 音频列表项视图组件
/// 用于在 AudioList 中展示单个音频文件
struct AudioItemView: View, Equatable, SuperLog {
    nonisolated static let emoji = "🎵"
    nonisolated static let verbose = false

    let url: URL

    nonisolated static func == (lhs: AudioItemView, rhs: AudioItemView) -> Bool {
        lhs.url == rhs.url
    }

    // 本地进度状态，1.1 表示无进度/已完成
    @State private var progress: Double = 1.1
    // 延迟显示头像，避免同时加载大量缩略图
    @State private var showAvatarDelayed: Bool = false

    init(_ url: URL) {
        self.url = url
    }

    var body: some View {
        url.makeMediaView(verbose: Self.verbose)
            .magicAvatarDownloadProgress($progress)
            .magicPadding(horizontal: 0, vertical: 0)
            .magicVerbose(Self.verbose)
            .showAvatar(true)
            .magicHideActions()
            .tag(url as URL?)
            .onAudioDownloadProgress { eventURL, progress in
                guard eventURL == self.url else { return }
                self.progress = (progress >= 1.0) ? 1.1 : progress
            }
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
