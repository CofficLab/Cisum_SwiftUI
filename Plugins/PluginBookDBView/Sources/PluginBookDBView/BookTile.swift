import CisumUI
import MagicKit
import OSLog
import PluginBook
import SwiftData
import SwiftUI

/**
 * 用途：展示从数据库读取的图书数据，以磁贴形式呈现图书封面和基本信息
 * 属性说明：
 *   - url: 图书的 URL 路径
 *   - title: 图书标题
 *   - childCount: 图书包含的音频文件数量
 *   - cover: 图书封面图片（异步加载）
 *   - state: 图书的播放状态（记录上次播放位置）
 * 使用场景：在图书列表中展示图书，支持显示封面、标题、文件数量和播放记录
 */
struct BookTile: View, SuperThread, SuperLog, Equatable {
    nonisolated static func == (lhs: BookTile, rhs: BookTile) -> Bool {
        lhs.url == rhs.url
    }

    @EnvironmentObject var repo: BookRepo
    @Environment(\.bookDBViewDependencies) private var dependencies

    @State private var lastPlayedTitle: String? = nil
    @State private var cover: Image? = nil
    @State private var tileSize: CGSize = .init(width: 150, height: 200)

    nonisolated static let emoji = "🖥️"
    private let verbose = false
    
    private var hasCover: Bool { cover != nil }
    private var noCover: Bool { cover == nil }
    
    var url: URL
    var title: String
    var childCount: Int

    var body: some View {
        ZStack {
            if let cover = cover {
                cover
            } else {
                CisumMagicBackground.deepForest.opacity(0.2)
            }

            HStack {
                Spacer()
                VStack {
                    Spacer()

                    if noCover {
                        Text(title).font(.title)
                    }

                    Spacer()

                    if childCount > 0, noCover {
                        Text("共 \(childCount)", tableName: "Book-DBView", bundle: .module)
                    }

                    Spacer()
                    if let lastPlayedTitle, noCover {
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "info")
                                Text("上次播放", tableName: "Book-DBView", bundle: .module)
                            }
                            Text(lastPlayedTitle)
                        }
                        .font(.footnote)
                        .padding()
                    }
                }
                Spacer()
            }
        }
        .frame(width: tileSize.width)
        .frame(height: tileSize.height)
        .onAppear(perform: onAppear)
    }
}

// MARK: - Action

extension BookTile {
    func updateCover() {
        if self.cover == nil {
            // 预先在主线程捕获必要的 Sendable 值，避免非 Sendable 的 self/book 跨 actor 逃逸
            let url = self.url
            let title = self.title
            let thumbnailSize = tileSize
            let repo = self.repo
            let logPrefix = self.t

            Task {
                if verbose {
                    os_log("\(logPrefix)开始获取封面图 \(title)")
                }

                let cover = await repo.getCover(for: url, thumbnailSize: thumbnailSize)
                await MainActor.run {
                    self.setCover(cover)
                }
            }
        }
    }

    func updateLastPlayedTitle() {
        let bookURL = self.url
        let dbRoot = dependencies.dbRoot
        let logPrefix = self.t

        Task.detached(priority: .background) {
            do {
                let container = try BookConfig.getContainer(dbRootURL: dbRoot)
                let context = ModelContext(container)
                let descriptor = BookState.descriptorOf(bookURL)
                let state = try context.fetch(descriptor).first
                let title = state?.currentURL?.lastPathComponent

                await MainActor.run {
                    self.setLastPlayedTitle(title)
                }
            } catch {
                if verbose {
                    os_log(.error, "\(logPrefix)读取书籍播放状态失败: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Setter

extension BookTile {
    @MainActor
    func setCover(_ cover: Image?) {
        self.cover = cover
    }

    @MainActor
    func setLastPlayedTitle(_ title: String?) {
        self.lastPlayedTitle = title
    }
}

// MARK: - Event Handler

extension BookTile {
    func onAppear() {
        self.updateCover()
        self.updateLastPlayedTitle()
    }
}

// MARK: - Preview

#if os(macOS)

#endif
