import MagicKit
import SwiftUI

/// 音频列表项视图组件
/// 用于在 AudioList 中展示单个音频文件
struct AudioItemView: View, Equatable {
    let url: URL

    nonisolated static func == (lhs: AudioItemView, rhs: AudioItemView) -> Bool {
        lhs.url == rhs.url
    }

    // 本地进度状态，1.1 表示无进度/已完成
    @State private var progress: Double = 1.1

    init(_ url: URL) {
        self.url = url
    }

    var body: some View {
        url.makeMediaView()
            .magicAvatarDownloadProgress($progress)
            .magicPadding(horizontal: 0, vertical: 0)
            .magicVerbose(false)
            .showAvatar(true)
            .magicShowLogButtonInDebug()
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
