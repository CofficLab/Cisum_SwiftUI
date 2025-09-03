import MagicCore
import OSLog
import SwiftUI

/**
 展示从数据库读取的图书数据
 */
struct BookTile: View, SuperThread, SuperLog {
    @State private var state: BookState? = nil
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    @State private var cover: Image? = nil
    @State private var isLoadingCover: Bool = false
    @State private var tileSize: CGSize = .zero
    @State private var childCount = 0

    nonisolated static let emoji = "🖥️"
    var hasCover: Bool { cover != nil }
    var noCover: Bool { cover == nil }
    var book: BookModel

    var body: some View {
        os_log("\(self.t)开始渲染 \(self.book.title)")
        return ZStack {
            ZStack {
                if let cover = cover {
                    cover.resizable().scaledToFit()
                } else {
                    MagicBackground.deepForest
                }
            }
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
            .shadow(radius: 5)
            .background(
                GeometryReader { geometry in
                    Color.clear.onAppear {
                        tileSize = geometry.size
                    }
                }
            )
            HStack {
                Spacer()
                VStack {
                    Spacer()

                    if noCover {
                        Text(book.bookTitle).font(.title)
                    }

                    Spacer()

                    if childCount > 0, noCover {
                        Text("共 \(book.childCount)")
                    }

                    book.url.makeOpenButton()

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
        .foregroundStyle(.white)
        .scaleEffect(CGSize(width: scale, height: scale))
        .opacity(opacity)
        .onAppear(perform: onAppear)
        .onTapGesture(perform: onTap)
    }
}

// MARK: Action

extension BookTile {
    func updateCover() {
        if self.cover == nil {
            self.isLoadingCover = true
            // 预先在主线程捕获必要的 Sendable 值，避免非 Sendable 的 self/book 跨 actor 逃逸
            let url = self.book.url
            let title = self.book.title
            let thumbnailSize = CGSize(
                width: max(120, tileSize.width * 2),
                height: max(120, tileSize.height * 2)
            )

            Task.detached(priority: .utility) {
                do {
                    os_log("\(self.t)开始获取封面图 \(title)")
                    let cover = try await Self.findCoverRecursively(in: url, thumbnailSize: thumbnailSize)
                    await MainActor.run {
                        self.isLoadingCover = false
                        self.cover = cover
                    }
                } catch {
                    os_log("\(self.t)Failed to find cover: \(error.localizedDescription)")
                    await MainActor.run { self.isLoadingCover = false }
                }
            }
        }
    }

    private static func findCoverRecursively(in url: URL, thumbnailSize: CGSize) async throws -> Image? {
        // 获取当前目录下的所有文件
        let children = url.getChildren()

        // 首先检查当前层级的文件
        for child in children where !child.hasDirectoryPath {
            // 跳过未下载的 iCloud 文件
            if child.isiCloud && child.isNotDownloaded {
                continue
            }

            if let cover = try await child.coverFromMetadata(size: thumbnailSize, verbose: true) {
                return cover
            }
        }

        // 如果当前层级没有找到封面，递归查找子文件夹
        for child in children where child.hasDirectoryPath {
            if let cover = try await findCoverRecursively(in: child, thumbnailSize: thumbnailSize) {
                return cover
            }
        }

        return nil
    }
}

// MARK: Event Handler

extension BookTile {
    func onAppear() {
        self.updateCover()
        Task {
            let localChildCount = self.book.childCount
            await MainActor.run { self.childCount = localChildCount }
        }
    }

    @MainActor
    func onTap() {
        // 首先执行动画
        withAnimation(.spring()) {
            scale = 0.95
            opacity = 0.95
        }

//        if let first = book.url.getChildren().first {
//            playMan.play(url: first)
//        } else {
//            playMan.play(url: book.url)
//        }

        // 延迟恢复动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { @MainActor in
            withAnimation(.spring()) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
