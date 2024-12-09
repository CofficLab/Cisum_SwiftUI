import Foundation
import OSLog
import SwiftData
import SwiftUI
import MagicKit

/**
 记录一本有声书的数据
 */
@Model
class Book: FileBox, SuperLog {
    @Transient let emoji = "📖"
    
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

    @Relationship(deleteRule: .noAction)
    var parent: Book?

    @Relationship(deleteRule: .noAction, inverse: \Book.parent)
    var childBooks: [Book]?

    init(url: URL, currentURL: URL? = nil) {
        self.url = url
        self.currentURL = currentURL
        self.bookTitle = self.title
        self.isCollection = self.isFolder()
        self.parentBookURL = self.parentURL
    }

    func getParentURL() -> URL? {
        url.deletingLastPathComponent()
    }

    func nextURL() -> URL? {
        url.getNextFile()
    }
}

// MARK: Transform

extension Book {
    func toPlayAsset(verbose: Bool = false) -> PlayAsset {
        if verbose {
            os_log("\(self.t)ToPlayAsset: title(\(self.title))")
        }

        return PlayAsset(url: self.url, like: false)
    }

    static func fromDiskFile(_ file: DiskFile) -> Book {
        file.toBook()
    }
}

// MARK: Cover

extension Book {
    func getBookCoverFromDB(verbose: Bool = false) async -> Image? {
        if verbose {
            os_log("\(self.t)GetBookCover for \(self.title)")
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
    static var descriptorIsFolder = FetchDescriptor(predicate: #Predicate<Book> { book in
        book.isCollection == true
    }, sortBy: [])

    static var descriptorNotFolder = FetchDescriptor(predicate: #Predicate<Book> { book in
        book.isCollection == false
    }, sortBy: [])

    static var descriptorAll = FetchDescriptor(predicate: #Predicate<Book> { _ in
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

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}