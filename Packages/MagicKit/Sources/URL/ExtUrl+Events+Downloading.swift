
import Foundation
import Combine
import SwiftUI
import OSLog

public extension URL {
    /// 监听文件的下载进度
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - caller: 调用者名称
    ///   - updateInterval: 更新进度的时间间隔（秒），默认 0.5 秒
    ///   - onProgress: 下载进度回调，progress 范围 0-1
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onDownloading(
        verbose: Bool = true,
        caller: String,
        updateInterval: TimeInterval = 0.5,
        _ onProgress: @escaping (Double) -> Void
    ) -> AnyCancellable {
        if verbose {
            os_log("\(self.t)👂 (\(caller)) 开始监听下载进度 -> \(self.title)")
        }
        
        // 注册到全局监听器
        let uuid = GlobalDownloadMonitor.shared.addSubscriber(
            url: self,
            updateInterval: updateInterval,
            onProgress: onProgress
        )
        
        return AnyCancellable {
            if verbose {
                os_log("\(self.t)🔚 (\(caller)) 停止监听下载进度(Global) -> \(self.title)")
            }
            GlobalDownloadMonitor.shared.removeSubscriber(url: self, uuid: uuid)
        }
    }

    /// 监听文件下载完成事件
    /// - Parameters:
    ///   - verbose: 是否打印详细日志
    ///   - caller: 调用者名称
    ///   - onFinished: 下载完成回调
    /// - Returns: 可用于取消监听的 AnyCancellable
    func onDownloadFinished(
        verbose: Bool,
        caller: String,
        _ onFinished: @escaping () -> Void
    ) -> AnyCancellable {
        if verbose {
            os_log("\(self.t)👂 [\(caller)] 开始监听下载完成(Global) -> \(self.title)")
        }
        
        // 直接复用 onDownloading 监听
        // GlobalDownloadMonitor 会在下载完成（离开 query）时回调 1.0
        return self.onDownloading(
            verbose: false, // 内部不再打印详细进度日志，避免刷屏
            caller: caller,
            updateInterval: 1.0 // 对完成检测来说，频率不需要太高
        ) { progress in
            if progress >= 1.0 {
                if verbose {
                    os_log("\(self.t)[\(caller)] 下载完成(Global) -> \(self.title)")
                }
                
                // 确保在主线程回调 (保持原有行为)
                if Thread.isMainThread {
                    onFinished()
                } else {
                    DispatchQueue.main.async {
                        onFinished()
                    }
                }
            }
        }
    }
}
