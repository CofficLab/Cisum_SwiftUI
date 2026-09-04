import CisumUIComponents
import OSLog
import PluginBook
import SwiftData
import SwiftUI

struct BookList: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📖"

    @Environment(\.bookDBViewDependencies) private var dependencies

    @Query(
        sort: \BookModel.order,
        animation: .default
    ) var books: [BookModel]

    private var displayableBooks: [BookModel] {
        guard let bookDisk = dependencies.bookDisk else {
            return []
        }

        return books.filter {
            BookRepo.isDisplayableLibraryItem(
                url: $0.url,
                isCollection: $0.isCollection,
                childCount: $0.childCount,
                libraryRoot: bookDisk
            )
        }
    }

    var total: Int { displayableBooks.count }
    var showTips: Bool {
        false
    }

    var body: some View {
//        os_log("\(self.t)开始渲染")
        return List(displayableBooks) { item in
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
