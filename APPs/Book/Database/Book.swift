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

    // 以下值可以通过其他属性计算出来，但因为这些原因而保存下来
    //  SwiftData查询时不支持计算属性
    //  计算开销较大，直接缓存下来
    //  值变动时，UI刷新
    var isCollection: Bool = false
    var parentBookURL: URL?
    var bookTitle: String = ""
    var childCount: Int = 0
    var order: Int = 0
    var coverData: Data?

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
    func getBookCover(verbose: Bool = true) async -> Image? {
        if verbose {
            os_log("\(self.t)GetBookCover for \(self.title)")
        }

        // 根目录没有封面
        if self.url.pathComponents.count <= 1 {
            return nil
        }

        // 如果 coverData 不为空，使用它来生成跨平台的图像
        if let coverData = self.coverData {
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

        return await self.getBookCoverFromFile()
    }

    func getBookCoverFromFile() async -> Image? {
        let verbose = true
        
        if verbose {
            os_log("\(self.t)GetBookCoverFromFile for \(self.title)")
        }

        // 根目录没有封面
        if self.url.pathComponents.count <= 1 {
            return nil
        }

        // 先获取自己的
        if let selfImage = await self.getCoverImage() {
            return selfImage
        }

        // 无children
        guard let children = children else {
            return nil
        }

        // 获取children的
        for child in children.map({ Book(url: $0) }) {
            if let image = await child.getBookCoverFromFile() {
                return image
            }
        }

        return nil
    }
    
    func getCoverURLFromFile() async -> URL? {
        let verbose = true
        
        if verbose {
            os_log("\(self.t)GetBookCoverFromFile for \(self.title)")
        }

        // 根目录没有封面
        if self.url.pathComponents.count <= 1 {
            return nil
        }

        // 先获取自己的
        if let selfImage = await self.getCoverFromMeta() {
            return selfImage
        }

        // 无children
        guard let children = children else {
            return nil
        }

        // 获取children的
        for child in children.map({ Book(url: $0) }) {
            if let image = await child.getCoverURLFromFile() {
                return image
            }
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
