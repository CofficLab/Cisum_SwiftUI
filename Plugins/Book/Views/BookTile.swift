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

    @EnvironmentObject var bookRepoState: BookRepoState
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
            let repo = self.bookRepoState.repo
            let logPrefix = self.t

            Task {
                os_log("\(logPrefix)开始获取封面图 \(title)")
                if let repo = repo {
                    let cover = await repo.getCover(for: url, thumbnailSize: thumbnailSize)
                    await MainActor.run {
                        self.setCover(cover)
                    }
                } else {
                    os_log("\(logPrefix)BookRepo not available yet")
                }
            }
        }
    }

}

// MARK: - Setter

extension BookTile {
    func setCover(_ cover: Image?) {
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
