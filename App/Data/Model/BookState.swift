import Foundation
import SwiftData
import OSLog

/**
 记录一本有声书的状态数据，并通过 CloudKit 同步
 */
@Model
class BookState {
    /// 图书的URL
    var url: URL?
    
    /// 当前播放的章节的URL
    var currentURL: URL?
    
    var currentTitle: String {
        currentURL?.lastPathComponent ?? "无"
    }
    
    init(url: URL, currentURL: URL? = nil) {
        self.url = url
        self.currentURL = currentURL
    }
}

// MARK: Descriptor

extension BookState {
    static var descriptorAll = FetchDescriptor(predicate: #Predicate<BookState> { _ in
        return true
    }, sortBy: [])
    
    static func descriptorOf(_ url: URL) -> FetchDescriptor<BookState> {
        FetchDescriptor(predicate: #Predicate<BookState> { s in
            s.url == url
        }, sortBy: [])
    }
}
