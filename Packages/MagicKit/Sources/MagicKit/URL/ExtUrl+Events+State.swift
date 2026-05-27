
    import Foundation
import Combine
import SwiftUI
import OSLog

public extension URL {
    /// 监听文件的状态变化
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - onChange: 状态变化回调，返回最新的元数据项
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onStateChanged(
        verbose: Bool = true,
        _ onChange: @escaping (NSMetadataItem) -> Void
    ) -> AnyCancellable {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self as NSURL)
        query.operationQueue = queue
        
        if verbose {
            Task.detached {
                os_log("\(self.t)开始监听状态变化")
            }
        }
        
        let task = Task {
            let stream = AsyncStream<Notification> { continuation in
                NotificationCenter.default.addObserver(
                    forName: .NSMetadataQueryDidUpdate,
                    object: query,
                    queue: queue
                ) { notification in
                    continuation.yield(notification)
                }
            }
            
            for await _ in stream {
                if let item = query.results.first as? NSMetadataItem {
                    if verbose {
                        os_log("\(self.t)状态已更新")
                    }
                    await MainActor.run {
                        onChange(item)
                    }
                }
            }
        }
        
        query.start()
        
        return AnyCancellable {
            if verbose {
                os_log("\(self.t)停止监听状态变化")
            }
            task.cancel()
            query.stop()
        }
    }
}