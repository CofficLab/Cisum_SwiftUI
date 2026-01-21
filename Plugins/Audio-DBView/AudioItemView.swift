import Foundation
import MagicKit
import OSLog
import SwiftUI

/// 音频列表项视图组件
/// 用于在 AudioList 中展示单个音频文件
struct AudioItemView: View, Equatable, SuperLog {
    nonisolated static let emoji = "🎵"
    nonisolated static let verbose = true

    let url: URL

    /// 文件大小显示文本
    @State private var sizeText: String = ""

    nonisolated static func == (lhs: AudioItemView, rhs: AudioItemView) -> Bool {
        lhs.url == rhs.url
    }

    init(_ url: URL) {
        self.url = url
    }
}

// MARK: - View

extension AudioItemView {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 头像部分
            url.makeAvatarView(verbose: Self.verbose && true)
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
                    Text(sizeText.isEmpty ? "..." : sizeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .tag(url as URL?)
        .onAppear(perform: handleOnAppear)
    }
}

// MARK: - Event Handler

extension AudioItemView {
    /// 处理视图出现事件
    private func handleOnAppear() {
        Task {
            await loadFileSize()
        }
    }
}

// MARK: - Action

extension AudioItemView {
    /// 在后台加载文件大小
    private func loadFileSize() async {
        Task.detached(priority: .background) {
            let size = await Task.detached(priority: .background) {
                url.getSizeReadable()
            }.value

            await MainActor.run {
                sizeText = size
            }
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
