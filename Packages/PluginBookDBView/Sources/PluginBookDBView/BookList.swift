import MagicKit
import OSLog
import PluginBook
import SwiftData
import SwiftUI

struct BookList: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📖"

    @Query(
        filter: #Predicate<BookModel> { $0.isCollection == true },
        sort: \BookModel.order,
        animation: .default
    ) var books: [BookModel]

    var total: Int { books.count }
    var showTips: Bool {
        false
    }

    var body: some View {
//        os_log("\(self.t)开始渲染")
        return List(books) { item in
            BookTile(url: item.url, title: item.bookTitle, childCount: item.childCount)
        }
    }
}

// MARK: - Action

extension BookList {
}

// MARK: - Event Handler

extension BookList {
}

// MARK: - Preview

#if os(macOS)

#endif
