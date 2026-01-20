import Foundation
import MagicKit
import OSLog
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

    init(_ url: URL) {
        self.url = url
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 头像部分 - 添加延迟加载优化滚动性能
            url.makeAvatarView(verbose: Self.verbose)
                .magicSize(.init(width: 40, height: 40))
                .magicAvatarShape(.circle)
                .magicBackground(.blue.opacity(0.1))
                .magicDownloadMonitor(true)
                .magicLoadDelay(150) // 150ms 延迟，避免快速滚动时触发过多加载

            // 文件信息部分
            VStack(alignment: .leading, spacing: 4) {
                 Text(url.lastPathComponent)
                     .font(.headline)
                     .lineLimit(1)

                 HStack {
                     Text(url.getSizeReadable())
                         .font(.caption)
                         .foregroundStyle(.secondary)
                 }
            }

            Spacer()
        }
        .tag(url as URL?)
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
