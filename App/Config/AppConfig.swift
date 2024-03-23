import Foundation
import OSLog

struct AppConfig {
    static let id = "com.yueyi.cisum"
    static let fileManager = FileManager.default
    static let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let coversDirName = "covers"
    static let audiosDirName = "audios"
    static let container = "iCloud.yueyi.cisum"
    static let logger = Logger.self
    static let mainQueue = DispatchQueue.main
    static let bgQueue = DispatchQueue(label: "com.yueyi.bgqueue")
}
