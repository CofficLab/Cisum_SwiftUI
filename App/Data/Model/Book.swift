import Foundation
import SwiftData
import SwiftUI
import OSLog

/**
 记录一本有声书的数据
 */
@Model
class Book: FileBox {
    var url: URL
    var currentURL: URL?
    var isFolder: Bool = false
    
    init(url: URL, currentURL: URL? = nil, isFolder: Bool) {
        self.url = url
        self.currentURL = currentURL
        self.isFolder = isFolder
    }
}

// MARK: Transform

extension Book {
    func toPlayAsset(verbose: Bool = false) -> PlayAsset {
        if verbose {
            os_log("\(self.label)ToPlayAsset: title(\(self.title))")
        }
        
        return PlayAsset(url: self.url, like: false)
    }
    
    static func fromDiskFile(_ file: DiskFile) -> Book {
        file.toBook()
    }
}

// MARK: Cover

extension Book {
    func getBookCover() async -> Image? {
        // 先获取自己的
        if let selfImage = await self.getCoverImage() {
            return selfImage
        }
        
        // 无children
        guard let children = children else {
            return nil
        }
        
        // 获取children的
        for child in children.map({Book(url: $0, isFolder: $0.isFileURL == false)}) {
            if let image = await child.getBookCover() {
                return image
            }
        }
        
        return nil
    }
}

// MARK: Descriptor

extension Book {
    static var descriptorIsFolder = FetchDescriptor(predicate: #Predicate<Book> { book in
        book.isFolder == true
    }, sortBy: [])
    
    static var descriptorNotFolder = FetchDescriptor(predicate: #Predicate<Book> { book in
        book.isFolder == false
    }, sortBy: [])
    
    static var descriptorAll = FetchDescriptor(predicate: #Predicate<Book> { _ in
        return true
    }, sortBy: [])
    
    static func descriptorOf(_ url: URL) -> FetchDescriptor<Book> {
        FetchDescriptor(predicate: #Predicate<Book> { s in
            s.url == url
        }, sortBy: [])
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
