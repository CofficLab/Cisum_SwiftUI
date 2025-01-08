import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftData
import SwiftUI
import MagicPlayMan

/**
 记录一本有声书的数据
 */
@Model
class Book: SuperLog {
    static let emoji = "📖"
    @Transient var db: BookDB?

    @Attribute(.unique)
    var url: URL
    var currentURL: URL?
    var isCollection: Bool = false
    var parentBookURL: URL?
    var bookTitle: String = ""
    var childCount: Int = 0
    var order: Int = 0
    var coverData: Data?
    var hasGetCover = false
    
    var title: String { bookTitle }

    @Relationship(deleteRule: .noAction)
    var parent: Book?

    @Relationship(deleteRule: .noAction, inverse: \Book.parent)
    var childBooks: [Book]?

    init(url: URL, currentURL: URL? = nil) {
        self.url = url
        self.currentURL = currentURL
        self.bookTitle = self.url.title
        self.isCollection = self.url.isFolder
        self.parentBookURL = self.url.getParent()
    }

    func getParentURL() -> URL? {
        url.deletingLastPathComponent()
    }

    func nextURL() -> URL? {
        url.getNextFile()
    }

    func setDB(_ db: BookDB?) {
        self.db = db
    }
}

// MARK: Transform

//extension Book {
//    static func fromDiskFile(_ file: URL) -> Book {
//        file.toBook()
//    }
//}

// MARK: Cover

extension Book {
    func getBookCoverFromDB(verbose: Bool = false) async -> Image? {
        if verbose {
            os_log("\(self.t)GetBookCover for \(self.bookTitle)")
        }

        if let coverData = self.coverData {
            if verbose {
                os_log("  🎉 GetBookCover From Database")
            }

            #if canImport(UIKit)
                if let uiImage = UIImage(data: coverData) {
                    return Image(uiImage: uiImage)
                }
            #elseif canImport(AppKit)
                if let nsImage = NSImage(data: coverData) {
                    return Image(nsImage: nsImage)
                }
            #endif
        }

        return nil
    }
}

// MARK: Descriptor

extension Book {
    static let descriptorIsFolder = FetchDescriptor(predicate: #Predicate<Book> { book in
        book.isCollection == true
    }, sortBy: [])

    static let descriptorNotFolder = FetchDescriptor(predicate: #Predicate<Book> { book in
        book.isCollection == false
    }, sortBy: [])

    static let descriptorAll = FetchDescriptor(predicate: #Predicate<Book> { _ in
        true
    }, sortBy: [])

    static func descriptorOf(_ url: URL) -> FetchDescriptor<Book> {
        FetchDescriptor(predicate: #Predicate<Book> { s in
            s.url == url
        }, sortBy: [])
    }

    static func descriptorOfParentBookURL(_ url: URL) -> FetchDescriptor<Book> {
        FetchDescriptor(predicate: #Predicate<Book> { s in
            s.parentBookURL == url
        }, sortBy: [])
    }

    static func descriptorOfHasParentBookURL() -> FetchDescriptor<Book> {
        FetchDescriptor(predicate: #Predicate<Book> { s in
            s.parentBookURL != nil
        }, sortBy: [])
    }

    static func descriptorOfNeedUpdateParent() -> FetchDescriptor<Book> {
        FetchDescriptor(predicate: #Predicate<Book> { s in
            s.parentBookURL != nil && s.parent == nil
        }, sortBy: [])
    }
}

enum BookModelError: Error, LocalizedError {
    case deleteFailed
    case dbNotFound

    var errorDescription: String? {
        switch self {
        case .deleteFailed:
            return "Delete failed"
        case .dbNotFound:
            return "BookModel: DB not found"
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
