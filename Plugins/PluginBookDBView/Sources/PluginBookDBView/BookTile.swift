import CisumUI
import MagicKit
import OSLog
import PluginBook
import SwiftData
import SwiftUI

struct BookTileLoadIdentity: Equatable {
    let bookURL: URL
    let dbRoot: URL
    let stateRevision: Int
}

enum BookTileStateRefreshPolicy {
    static func shouldReloadTile(bookURL: URL, updatedBookURL: URL?) -> Bool {
        guard let updatedBookURL else { return false }
        return BookPlaybackOrdering.representsSameFile(bookURL, updatedBookURL)
    }

    static func nextRevision(after revision: Int) -> Int {
        revision + 1
    }
}

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
    @State private var stateRevision: Int = 0

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
                    .resizable()
                    .scaledToFill()
                    .frame(width: tileSize.width, height: tileSize.height)
                    .clipped()
            } else {
                CisumMagicBackground.deepForest.opacity(0.2)
            }

            HStack {
                Spacer()
                VStack {
                    Spacer()

                    if noCover {
                        Text(title)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 10)
                    }

                    Spacer()

                    if childCount > 0, noCover {
                        Text("Total \(childCount)", tableName: "Book-DBView", bundle: .module)
                    }

                    Spacer()
                    if let lastPlayedTitle, noCover {
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "info")
                                Text("Last played", tableName: "Book-DBView", bundle: .module)
                            }
                            Text(lastPlayedTitle)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.75)
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
        .task(id: BookTileLoadIdentity(bookURL: url, dbRoot: dependencies.dbRoot, stateRevision: stateRevision)) {
            await loadTileData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .bookStateUpdated), perform: handleBookStateUpdated)
    }
}

// MARK: - Action

extension BookTile {
    func handleBookStateUpdated(_ notification: Notification) {
        let updatedBookURL = notification.userInfo?["url"] as? URL
        guard BookTileStateRefreshPolicy.shouldReloadTile(bookURL: url, updatedBookURL: updatedBookURL) else {
            return
        }

        stateRevision = BookTileStateRefreshPolicy.nextRevision(after: stateRevision)
    }

    @MainActor
    func loadTileData() async {
        cover = nil
        lastPlayedTitle = nil

        let bookURL = url
        let bookTitle = title
        let thumbnailSize = tileSize
        let repo = repo
        let dbRoot = dependencies.dbRoot
        let logPrefix = t

        if verbose {
            os_log("\(logPrefix)开始获取封面图 \(bookTitle)")
        }

        async let loadedCover = repo.getCover(for: bookURL, thumbnailSize: thumbnailSize)
        async let loadedLastPlayedTitle = Self.lastPlayedTitle(for: bookURL, dbRoot: dbRoot, logPrefix: logPrefix, verbose: verbose)
        let (newCover, newLastPlayedTitle) = await (loadedCover, loadedLastPlayedTitle)

        guard !Task.isCancelled else {
            return
        }

        cover = newCover
        lastPlayedTitle = newLastPlayedTitle
    }

    nonisolated private static func lastPlayedTitle(
        for bookURL: URL,
        dbRoot: URL,
        logPrefix: String,
        verbose: Bool
    ) async -> String? {
        await Task.detached(priority: .background) {
            do {
                let container = try BookConfig.getContainer(dbRootURL: dbRoot)
                let context = ModelContext(container)
                let state = try BookDBViewBookStateLookup.findBookState(for: bookURL, in: context)
                return state?.currentURL?.lastPathComponent
            } catch {
                if verbose {
                    os_log(.error, "\(logPrefix)读取书籍播放状态失败: \(error.localizedDescription)")
                }

                return nil
            }
        }.value
    }
}

// MARK: - Preview

#if os(macOS)

#endif
