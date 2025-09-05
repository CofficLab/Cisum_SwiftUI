import MagicCore
import OSLog
import SwiftUI

/**
 展示从数据库读取的图书数据
 */
struct BookTile: View, SuperThread, SuperLog, Equatable {
    nonisolated static func == (lhs: BookTile, rhs: BookTile) -> Bool {
        lhs.url == rhs.url
    }

    @State private var state: BookState? = nil
    @State private var cover: Image? = nil
    @State private var tileSize: CGSize = .init(width: 150, height: 200)

    nonisolated static let emoji = "🖥️"
    var hasCover: Bool { cover != nil }
    var noCover: Bool { cover == nil }
    var url: URL
    var title: String
    var childCount: Int

    var body: some View {
        return ZStack {
            if let cover = cover {
                cover
            } else {
                MagicBackground.deepForest.opacity(0.2)
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
                        Text("共 \(childCount)")
                    }

                    Spacer()
                    if let s = self.state, noCover, s.currentURL != nil {
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "info")
                                Text("上次播放")
                            }
                            Text(s.currentTitle)
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

// MARK: Action

extension BookTile {
    func updateCover() {
        if self.cover == nil {
            // 预先在主线程捕获必要的 Sendable 值，避免非 Sendable 的 self/book 跨 actor 逃逸
            let url = self.url
            let title = self.title
            let thumbnailSize = tileSize

            Task.detached(priority: .background) {
                do {
                    os_log("\(self.t)开始获取封面图 \(title)")
                    let cover = try await Self.findCoverRecursively(in: url, thumbnailSize: thumbnailSize)
                    await self.setCover(cover)
                } catch {
                    os_log(.error, "\(self.t)Failed to find cover: \(error.localizedDescription)")
                }
            }
        }
    }

    private static func findCoverRecursively(in url: URL, thumbnailSize: CGSize) async throws -> Image? {
        // 确保在后台线程执行文件系统操作
        return try await withCheckedThrowingContinuation { continuation in
            Task.detached(priority: .background) {
                do {
                    os_log("\(self.t)findCoverRecursively \(url.title)")
                    // 获取当前目录下的所有文件
                    let children = url.getChildren()

                    // 首先检查当前层级的文件
                    for child in children where !child.hasDirectoryPath {
                        // 跳过未下载的 iCloud 文件
                        if child.isiCloud && child.isNotDownloaded {
                            continue
                        }

                        if let cover = try await child.coverFromMetadata(size: thumbnailSize, verbose: true) {
                            continuation.resume(returning: cover)
                            return
                        }
                    }

                    // 如果当前层级没有找到封面，递归查找子文件夹
                    for child in children where child.hasDirectoryPath {
                        if let cover = try await findCoverRecursively(in: child, thumbnailSize: thumbnailSize) {
                            continuation.resume(returning: cover)
                            return
                        }
                    }

                    continuation.resume(returning: nil)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Setter

extension BookTile {
    func setCover(_ cover: Image?) {
        os_log("\(self.t)SetCover for \(title)")
        self.cover = cover
    }
}

// MARK: Event Handler

extension BookTile {
    func onAppear() {
        self.updateCover()
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
