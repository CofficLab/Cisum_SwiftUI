import MagicCore
import MagicPlayMan
import OSLog
import SwiftData
import SwiftUI

struct BookGrid: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📖"
    nonisolated static let verbose = true

    @EnvironmentObject var a: AppProvider
    @EnvironmentObject var messageManager: StateProvider
    @EnvironmentObject var man: PlayManController

    @State var selection: AudioModel? = nil
    @State var syncingTotal: Int = 0
    @State var syncingCurrent: Int = 0
    
    /// 当前选中的书籍 URL
    @State private var selectedBookURL: URL? = nil

    /// 从数据库查询所有集合类型的书籍，按顺序排序
    @Query(
        filter: #Predicate<BookModel> { $0.isCollection == true },
        sort: \BookModel.order,
        animation: .default
    ) var books: [BookModel]

    /// 书籍总数
    var total: Int { books.count }
    
    /// 是否显示提示信息
    var showTips: Bool {
        if a.isDropping {
            return true
        }

        return false
    }

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)📺 开始渲染")
        }
        return ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150), spacing: 12),
            ], alignment: .center, spacing: 16, pinnedViews: [.sectionHeaders]) {
                ForEach(books) { item in
                    BookTile(url: item.url, title: item.bookTitle, childCount: item.childCount)
                        .overlay(
                            // 高亮边框
                            Rectangle()
                                .stroke(
                                    selectedBookURL == item.url ? Color.accentColor : Color.clear,
                                    lineWidth: selectedBookURL == item.url ? 3 : 0
                                )
                        )
                        .animation(.easeInOut(duration: 0.2), value: selectedBookURL)
                        .onTapGesture {
                            handleBookTap(book: item)
                        }
                }
            }
            .padding()
        }
        .onAppear(perform: handleOnAppear)
        .onPlayManAssetChanged(handleAssetChanged)
    }
}

// MARK: - Action

extension BookGrid {
    /// 更新选中的书籍
    ///
    /// 根据给定的音频 URL，查找并高亮显示包含该音频的书籍。
    /// 如果 URL 是书籍本身或书籍的子文件，都会被识别并选中。
    ///
    /// - Parameter url: 要查找的音频文件 URL
    private func updateSelectedBook(for url: URL) {
        if Self.verbose {
            os_log("\(self.t)🔍 查找包含音频的书籍: \(url.lastPathComponent)")
        }
        
        // 查找包含该URL的书籍
        for book in books {
            if book.url == url || book.url.getChildren().contains(url) {
                if Self.verbose {
                    os_log("\(self.t)✅ 找到书籍: \(book.bookTitle)")
                }
                selectedBookURL = book.url
                return
            }
        }
        
        if Self.verbose {
            os_log("\(self.t)⚠️ 未找到对应的书籍")
        }
        selectedBookURL = nil
    }
    
    /// 播放书籍
    ///
    /// 点击书籍时触发播放操作。如果书籍有子文件，播放第一个子文件；
    /// 否则直接播放书籍本身。
    ///
    /// - Parameter book: 要播放的书籍模型
    private func playBook(_ book: BookModel) async {
        if Self.verbose {
            os_log("\(self.t)▶️ 准备播放书籍: \(book.bookTitle)")
        }
        
        if let first = book.url.getChildren().first {
            if Self.verbose {
                os_log("\(self.t)🎵 播放第一个子文件: \(first.lastPathComponent)")
            }
            await man.play(url: first)
        } else {
            if Self.verbose {
                os_log("\(self.t)🎵 播放书籍文件: \(book.url.lastPathComponent)")
            }
            await man.play(url: book.url)
        }
    }
}

// MARK: - Event Handler

extension BookGrid {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时，检查播放器当前播放的音频，
    /// 并高亮显示对应的书籍。
    func handleOnAppear() {
        if Self.verbose {
            os_log("\(self.t)👀 视图已出现，书籍总数: \(total)")
        }
        
        // 初始化时检查当前播放的音频
        if let currentAsset = man.getAsset() {
            if Self.verbose {
                os_log("\(self.t)🎵 检测到当前播放: \(currentAsset.lastPathComponent)")
            }
            updateSelectedBook(for: currentAsset)
        }
    }
    
    /// 处理书籍点击事件
    ///
    /// 当用户点击书籍卡片时触发，更新选中状态并开始播放。
    ///
    /// - Parameter book: 被点击的书籍模型
    func handleBookTap(book: BookModel) {
        if Self.verbose {
            os_log("\(self.t)👆 点击书籍: \(book.bookTitle)")
        }
        
        selectedBookURL = book.url
        
        Task {
            await playBook(book)
        }
    }
    
    /// 处理播放资源变化事件
    ///
    /// 当播放器的播放资源改变时触发，更新选中的书籍高亮状态。
    ///
    /// - Parameter url: 新的播放资源 URL，如果为 nil 则清除选中状态
    func handleAssetChanged(_ url: URL?) {
        if Self.verbose {
            if let url = url {
                os_log("\(self.t)🔄 播放资源已变化: \(url.lastPathComponent)")
            } else {
                os_log("\(self.t)🔄 播放已停止")
            }
        }
        
        if let url = url {
            updateSelectedBook(for: url)
        }
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
