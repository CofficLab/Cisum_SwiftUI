import MagicKit
import OSLog
import SwiftUI

/**
 展示从数据库读取的图书数据
 */
struct BookTile: View, SuperThread, SuperLog {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: BookDB

    @State var state: BookState? = nil
    @State var scale: CGFloat = 1.0
    @State var opacity: Double = 1.0
    @State var cover: Image? = nil

    nonisolated static let emoji = "🖥️"
    var hasCover: Bool { cover != nil }
    var noCover: Bool { cover == nil }
    var book: BookModel

    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @State private var tileSize: CGSize = .zero

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()

                if noCover {
                    Text(book.bookTitle).font(.title)
                }

                Spacer()

                if book.childCount > 0, noCover {
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
        .background(getBackground())
        .foregroundStyle(.white)
        .scaleEffect(CGSize(width: scale, height: scale))
        .opacity(opacity)
        .contextMenu(menuItems: {
            book.url.makeOpenButton()
        })
        .onHover(perform: onHover)
        .onAppear(perform: onAppear)
        .onTapGesture(perform: onTap)
    }

    func getBackground() -> some View {
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
    }
}

// MARK: Action

extension BookTile {
    func updateCover() {
        if self.cover == nil {
            Task {
                do {
                    self.cover = try await findCoverRecursively(in: book.url)
                } catch {
                    os_log("\(self.t)Failed to find cover: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func findCoverRecursively(in url: URL) async throws -> Image? {
        // 获取当前目录下的所有文件
        let children = url.getChildren()
        
        // 计算合适的缩略图尺寸
        let thumbnailSize = CGSize(
            width: max(120, tileSize.width * 2),  // 使用 2x 分辨率作为默认值
            height: max(120, tileSize.height * 2)
        )
        
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
            if let cover = try await findCoverRecursively(in: child) {
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
    }

    @MainActor
    func onHover(_ hovering: Bool) {
        withAnimation {
            scale = hovering ? 1.02 : 1
        }
    }

    @MainActor
    func onTap() {
        // 首先执行动画
        withAnimation(.spring()) {
            scale = 0.95
            opacity = 0.95
        }

        if let first = book.url.getChildren().first {
            playMan.play(url: first)
        } else {
            playMan.play(url: book.url)
        }

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
