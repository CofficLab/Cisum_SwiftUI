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
    let index: Int // 添加索引参数，用于分页加载检测

    nonisolated static func == (lhs: AudioItemView, rhs: AudioItemView) -> Bool {
        lhs.url == rhs.url && lhs.index == rhs.index
    }

    init(_ url: URL, index: Int = 0) {
        self.url = url
        self.index = index
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 头像部分 - MagicKit 内部使用全局监控器，无需手动管理
            url.makeAvatarView(verbose: Self.verbose)
                .magicSize(.init(width: 40, height: 40))
                .magicAvatarShape(.circle)
                .magicBackground(.blue.opacity(0.1))
                .magicDownloadMonitor(true)

            // 文件信息部分
            VStack(alignment: .leading, spacing: 4) {
                // Text(url.lastPathComponent)
                //     .font(.headline)
                //     .lineLimit(1)

                // HStack {
                //     Text(url.getSizeReadable())
                //         .font(.caption)
                //         .foregroundStyle(.secondary)

                //     if let status = url.magicFileStatus {
                //         Text(status)
                //             .font(.caption)
                //             .foregroundStyle(.secondary)
                //     }
                // }
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
