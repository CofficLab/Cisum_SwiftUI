import MagicCore

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
                GridItem(.adaptive(minimum: 150), spacing: 10),
            ], pinnedViews: [.sectionHeaders]) {
                ForEach(books) { item in
                    BookTile(url: item.url, title: item.bookTitle, childCount: item.childCount)
                        .onTapGesture {
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
