import Foundation

// MARK: 队列配置

extension Config {
    static let mainQueue = DispatchQueue.main
    static let bgQueue = DispatchQueue(label: "com.yueyi.bgqueue")
}
