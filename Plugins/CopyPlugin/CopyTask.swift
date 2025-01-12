import Foundation
import SwiftData
import MagicKit


@Model
class CopyTask {
    static let emoji: String = "🍁"
    
    var url: URL
    var destination: URL
    var createdAt: Date
    var error: String = ""
    var isRunning: Bool = false
    
    var title: String { url.lastPathComponent }
    var time: String { Date.now }
    var message: String {
        if isRunning {
            return "进行中"
        }
        
        if self.url.isDownloading {
            return "正在从 iCloud 下载"
        }
    
        return error
    }
    
    init(url: URL, destination: URL) {
        self.url = url
        self.destination = destination
        self.createdAt = .now
    }
}

// MARK: ID

extension CopyTask: Identifiable {
    var id: PersistentIdentifier { persistentModelID }
}

// 添加一个新的值类型结构体用于数据传输
struct CopyTaskDTO: Sendable {
    let url: URL
    let destination: URL
    let error: String
    
    init(from model: CopyTask) {
        self.url = model.url
        self.destination = model.destination
        self.error = model.error
    }
}
