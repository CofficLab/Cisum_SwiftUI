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
