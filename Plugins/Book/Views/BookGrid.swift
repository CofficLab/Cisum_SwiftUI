import MagicCore
import MagicPlayMan
import OSLog
import SwiftData
import SwiftUI

struct BookGrid: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📖"

    @EnvironmentObject var a: AppProvider
    @EnvironmentObject var messageManager: StateProvider
    @EnvironmentObject var man: PlayManController

    @State var selection: AudioModel? = nil
    @State var syncingTotal: Int = 0
    @State var syncingCurrent: Int = 0
    @State private var selectedBookURL: URL? = nil

    @Query(
        filter: #Predicate<BookModel> { $0.isCollection == true },
        sort: \BookModel.order,
        animation: .default
    ) var books: [BookModel]

    var total: Int { books.count }
    var showTips: Bool {
        if a.isDropping {
            return true
        }

        return false
    }

    var body: some View {
//        os_log("\(self.t)开始渲染")
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
                            selectedBookURL = item.url
                            Task {
                                if let first = item.url.getChildren().first {
                                    await man.play(url: first)
                                } else {
                                    await man.play(url: item.url)
                                }
                            }
                        }
                }
            }
            .padding()
        }
        .onAppear(perform: onAppear)
        .onPlayManAssetChanged({
            if let url = $0 {
                self.updateSelectedBook(for: url)
            }
        })
    }
}

// MARK: - Action

extension BookGrid {
    private func updateSelectedBook(for url: URL) {
        // 查找包含该URL的书籍
        for book in books {
            if book.url == url || book.url.getChildren().contains(url) {
                selectedBookURL = book.url
                return
            }
        }
        selectedBookURL = nil
    }
}

// MARK: - Event Handler

extension BookGrid {
    func onAppear() {
        // 初始化时检查当前播放的音频
        if let currentAsset = man.getAsset() {
            updateSelectedBook(for: currentAsset)
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
