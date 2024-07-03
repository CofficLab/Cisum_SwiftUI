import Foundation
import SwiftData
import OSLog

/**
 记录一本有声书的状态数据，并通过 CloudKit 同步
 */
@Model
class BookState {
    // MARK: Descriptor
    
    static var descriptorAll = FetchDescriptor(predicate: #Predicate<BookState> { _ in
        return true
    }, sortBy: [])
    
    /// 图书的URL
    var url: URL?
    
    /// 当前播放的章节的URL
    var currentURL: URL?
    
    init(url: URL, currentURL: URL? = nil) {
        self.url = url
        self.currentURL = currentURL
    }
}
