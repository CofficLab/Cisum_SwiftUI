import MagicCore

import OSLog
import SwiftData
import SwiftUI

struct BookGrid: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📖"

    @EnvironmentObject var appManager: AppProvider
    @EnvironmentObject var messageManager: StateProvider
    @EnvironmentObject var db: BookRepo

    @State var selection: AudioModel? = nil
    @State var syncingTotal: Int = 0
    @State var syncingCurrent: Int = 0
    @State var books: [BookModel] = []

    var total: Int { books.count }
    var showTips: Bool {
        if appManager.isDropping {
            return true
        }

        return false
    }

    var body: some View {
        os_log("\(self.t)开始渲染")
        return ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150), spacing: 10),
            ], pinnedViews: [.sectionHeaders]) {
                ForEach(books) { item in
                    BookTile(book: item)
                        .frame(width: 150)
                        .frame(height: 200)
                        .id(item.url)
                }
            }
            .padding()
        }
        .task(handleOnAppear)
    }

    func handleOnAppear() async {

            self.books = await db.getRootBooks()
    }
}

#Preview("App") {
    AppPreview()
        .frame(width: 800)
        .frame(height: 800)
}

