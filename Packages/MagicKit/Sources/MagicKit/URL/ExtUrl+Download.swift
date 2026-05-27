import Foundation
import MagicKit
import OSLog
import SwiftUI

public extension URL {
    /// 获取文件的状态信息
    ///
    /// 这个属性返回文件的当前状态描述，例如：
    /// - "远程文件"：表示文件是一个网络 URL
    /// - "本地文件"：表示文件存储在本地
    /// - "iCloud 文件"：表示文件存储在 iCloud 中
    /// - "正在从 iCloud 下载"：表示文件正在从 iCloud 下载
    var magicFileStatus: String? {
        if isNetworkURL {
            return "远程文件"
        } else if isFileURL {
            if checkIsICloud(verbose: true) {
                if checkIsDownloading(verbose: false) {
                    return "正在从 iCloud 下载"
                } else if isDownloaded {
                    return "已从 iCloud 下载"
                } else {
                    return "未从 iCloud 下载"
                }
            }
            return isLocal ? "本地文件" : nil
        }
        return nil
    }

    /// 下载方式
    enum DownloadMethod {
        /// 轮询方式
        case polling(updateInterval: TimeInterval = 0.5) // 默认 0.5 秒
        /// 使用 NSMetadataQuery
        case query
    }

    /// 下载 iCloud 文件
    /// - Parameters:
    ///   - verbose: 是否输出详细日志，默认为 false
    ///   - reason: 下载原因，用于日志记录
    ///   - method: 下载方式，默认为 .polling
    ///   - onProgress: 下载进度回调
    func download(
        verbose: Bool = false,
        reason: String,
        method: DownloadMethod = .polling(),
        onProgress: ((Double) -> Void)? = nil
    ) async throws {
        // 通用的检查和日志
        guard checkIsICloud(verbose: false), isNotDownloaded else {
            if verbose {
                os_log("\(self.t)文件无需下载：不是 iCloud 文件或已下载完成")
            }
            return
        }

        if verbose {
            os_log("\(self.t)🛫 (\(reason)) <\(self.title)> 开始下载")
        }

        // 如果不需要进度回调，直接使用简单的下载方式
        guard let onProgress = onProgress else {
            try await FileManager.default.startDownloadingUbiquitousItem(at: self)
            if verbose {
                os_log("\(self.t)⏬ (\(reason)) <\(self.title)> 已启动下载")
            }
            return
        }

        // 需要进度回调时，根据方法选择具体的下载实现
        switch method {
        case let .polling(updateInterval):
            try await downloadWithPolling(verbose: verbose, updateInterval: updateInterval, onProgress: onProgress)
        case .query:
            try await downloadWithQuery(verbose: verbose, onProgress: onProgress)
        }
    }

    /// 下载状态相关属性
    /// ⚠️ 注意：此属性会访问文件系统，可能需要 1-5 毫秒
    /// 建议在后台线程调用，或使用 `checkIsDownloaded()` 函数
    var isDownloaded: Bool {
        checkIsDownloaded(verbose: false)
    }

    /// 检查文件是否已下载
    /// - Parameters:
    ///   - verbose: 是否输出详细日志，默认为 false（避免频繁调用时产生大量日志）
    /// - Returns: 如果文件已下载返回 true，否则返回 false
    /// - Note: 此函数会访问文件系统，建议在后台线程调用
    /// - Performance: ~1-5ms for iCloud files, ~0.1μs for local files
    func checkIsDownloaded(verbose: Bool = false) -> Bool {
        // 💡 关键：强制清理 URL 的内部资源属性缓存，确保获取到磁盘上的最新状态
        var mutableSelf = self
        mutableSelf.removeAllCachedResourceValues()

        guard let resources = try? mutableSelf.resourceValues(forKeys: [
            .isUbiquitousItemKey,
            .ubiquitousItemDownloadingStatusKey,
            URLResourceKey(rawValue: "NSURLUbiquitousItemPercentDownloadedKey"),
        ]) else {
            // 无法获取资源，可能是本地文件
            return true
        }

        // 如果不是 iCloud 文件，视为本地文件
        guard resources.isUbiquitousItem == true else {
            return true
        }

        // 先检查进度，100% 进度视为已下载
        if let progress = resources.allValues[URLResourceKey(rawValue: "NSURLUbiquitousItemPercentDownloadedKey")] as? Double, progress >= 100.0 {
            return true
        }

        // 检查下载状态
        guard let status = resources.ubiquitousItemDownloadingStatus else {
            if verbose {
                os_log("\(self.t)<\(self.title)>iCloud 文件下载状态为空 ❌")
            }
            return false
        }

        let isDownloaded = status == .current
        return isDownloaded
    }

    /// 检查文件是否正在下载
    /// - Parameters:
    ///   - verbose: 是否输出详细日志，默认为 false（避免频繁调用时产生大量日志）
    /// - Returns: 如果文件是 iCloud 文件且正在下载返回 true，否则返回 false
    /// - Note: 此函数会访问文件系统，建议在后台线程调用
    /// - Performance: ~1-5ms for iCloud files
    func checkIsDownloading(verbose: Bool = false) -> Bool {
        // 💡 关键：清理 URL 缓存，确保获取最新状态
        var mutableSelf = self
        mutableSelf.removeAllCachedResourceValues()
        
        // 使用单次 I/O 获取所有需要的属性
        guard let resources = try? mutableSelf.resourceValues(forKeys: [
            .isUbiquitousItemKey,
            .ubiquitousItemDownloadingStatusKey,
            .ubiquitousItemIsDownloadingKey,
        ]) else {
            if verbose {
                os_log("\(self.t)<\(self.title)>无法获取文件资源 ❌")
            }
            return false
        }

        // 如果不是 iCloud 文件，肯定不在下载
        guard resources.isUbiquitousItem == true else {
            return false
        }

        // 优先使用 isDownloading 属性
        if let isDownloading = resources.ubiquitousItemIsDownloading, isDownloading {
            return true
        }

        // 备选：检查下载状态字符串
        if let status = resources.ubiquitousItemDownloadingStatus {
            // 使用原始字符串比较，因为 Apple 的 API 在不同系统版本中可能有差异
            return status.rawValue == "NSMetadataUbiquitousItemDownloadingStatusDownloading"
        }

        return false
    }

    var isNotDownloaded: Bool {
        !isDownloaded
    }

    /// 检查文件是否为 iCloud 文件
    /// - Parameters:
    ///   - verbose: 是否输出详细日志
    /// - Returns: 如果是 iCloud 文件返回 true，否则返回 false
    /// - Note: 此函数会访问文件系统，建议在后台线程调用
    /// - Performance: ~1-5ms
    func checkIsICloud(verbose: Bool) -> Bool {
        let startTime = CFAbsoluteTimeGetCurrent()

        guard let resources = try? self.resourceValues(forKeys: [.isUbiquitousItemKey]) else {
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            if verbose {
                os_log("\(self.t)<\(self.title)>检查失败 (⏱️ \(String(format: "%.2f", elapsed * 1000))ms): 非 iCloud 文件 ❌")
            }
            return false
        }

        let isiCloud = resources.isUbiquitousItem ?? false
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime

        if verbose {
            let status = isiCloud ? "☁️ 是 iCloud 文件" : "📁 非 iCloud 文件"
            os_log("\(self.t)<\(self.title)>\(status) (⏱️ \(String(format: "%.2f", elapsed * 1000))ms)")
        }

        return isiCloud
    }

    var isNotiCloud: Bool {
        !checkIsICloud(verbose: false)
    }

    var isLocal: Bool {
        isNotiCloud
    }

    /// 创建下载按钮
    /// - Parameters:
    ///   - size: 按钮大小，默认为 28x28
    ///   - showLabel: 是否显示文字标签，默认为 false
    ///   - shape: 按钮形状，默认为圆形
    ///   - destination: 下载目标位置，如果为 nil 则只下载到 iCloud 本地
    /// - Returns: 下载按钮视图
    func makeDownloadButton(
        size: CGFloat = 28,
        showLabel: Bool = false,
        destination: URL? = nil
    ) -> some View {
        DownloadButtonView(
            url: self,
            size: size,
            showLabel: showLabel,
            destination: destination
        )
    }

    /// 从本地驱动器中移除文件，但保留在 iCloud 中
    /// - Returns: 是否成功移除
    @discardableResult
    func evict() throws -> Bool {
        os_log("\(self.t)开始从本地移除文件: \(self.path)")

        guard checkIsICloud(verbose: false) else {
            os_log("\(self.t)不是 iCloud 文件，无法执行移除操作")
            return false
        }

        guard isDownloaded else {
            os_log("\(self.t)文件未下载，无需移除")
            return true
        }

        do {
            try FileManager.default.evictUbiquitousItem(at: self)
            os_log("\(self.t)文件已从本地成功移除")
            return true
        } catch {
            os_log("\(self.t)移除文件失败: \(error.localizedDescription)")
            throw error
        }
    }

    /// 移动文件到目标位置，支持 iCloud 文件
    /// - Parameter destination: 目标位置
    /// - Throws: 移动过程中的错误
    func moveTo(_ destination: URL) async throws {
        os_log("\(self.t)开始移动文件: \(self.path) -> \(destination.path)")

        if self.checkIsICloud(verbose: false) && self.isNotDownloaded {
            os_log("\(self.t)检测到 iCloud 文件未下载，开始下载")
            try await download(verbose: false, reason: "移动文件时，检测到 iCloud 文件未下载，开始下载")
        }

        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        var moveError: Error?

        coordinator.coordinate(
            writingItemAt: self,
            options: .forMoving,
            writingItemAt: destination,
            options: .forReplacing,
            error: &coordinationError
        ) { sourceURL, destinationURL in
            do {
                os_log("\(self.t)执行文件移动操作")
                try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                os_log("\(self.t)文件移动完成")
            } catch {
                moveError = error
                os_log("\(self.t)移动文件失败: \(error.localizedDescription)")
            }
        }

        // 检查移动过程中是否发生错误
        if let error = moveError {
            throw error
        }

        // 检查协调过程中是否发生错误
        if let error = coordinationError {
            throw error
        }
    }

    /// 使用轮询方式下载 iCloud 文件
    private func downloadWithPolling(
        verbose: Bool,
        updateInterval: TimeInterval,
        onProgress: @escaping (Double) -> Void
    ) async throws {
        // 创建下载任务
        try FileManager.default.startDownloadingUbiquitousItem(at: self)

        // 等待下载完成
        while checkIsDownloading(verbose: false) {
            if verbose {
                os_log("\(self.t)文件下载中...")
            }
            // 获取下载进度
            if let resources = try? self.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey, .ubiquitousItemDownloadingErrorKey, .fileSizeKey, .fileAllocatedSizeKey]),
               let totalSize = resources.fileSize,
               let downloadedSize = resources.fileAllocatedSize {
                let progress = Double(downloadedSize) / Double(totalSize)
                onProgress(progress)

                // 检查是否有下载错误
                if let error = resources.ubiquitousItemDownloadingError {
                    throw error
                }
            }

            try await Task.sleep(nanoseconds: UInt64(updateInterval * 1000000000)) // 转换为纳秒
        }

        if verbose {
            os_log("\(self.t)文件下载完成")
        }
    }

    /// 使用 NSMetadataQuery 下载 iCloud 文件
    /// - Parameters:
    ///   - verbose: 是否输出详细日志，默认为 false
    ///   - onProgress: 下载进度回调
    private func downloadWithQuery(
        verbose: Bool,
        onProgress: @escaping (Double) -> Void
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let query = NSMetadataQuery()
            query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
            query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemURLKey, self.path)

            var observers: [NSObjectProtocol] = []

            let startObserver = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidStartGathering,
                object: query,
                queue: .main
            ) { _ in
                if verbose {
                    os_log("\(self.t)查询开始")
                }

                do {
                    try FileManager.default.startDownloadingUbiquitousItem(at: self)
                } catch {
                    observers.forEach { NotificationCenter.default.removeObserver($0) }
                    continuation.resume(throwing: error)
                }
            }
            observers.append(startObserver)

            let updateObserver = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate,
                object: query,
                queue: .main
            ) { _ in
                guard let item = query.results.first as? NSMetadataItem else { return }

                let downloadStatus = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String
                let isDownloading = downloadStatus == "NSMetadataUbiquitousItemDownloadingStatusDownloading"

                if isDownloading {
                    // 现在一定会计算进度
                    if let downloadedSize = item.value(forAttribute: "NSMetadataUbiquitousItemDownloadedSizeKey") as? NSNumber,
                       let totalSize = item.value(forAttribute: "NSMetadataUbiquitousItemTotalSizeKey") as? NSNumber {
                        let progress = Double(truncating: downloadedSize) / Double(truncating: totalSize)
                        onProgress(progress)

                        if verbose {
                            os_log("\(self.t)下载进度：\(progress * 100)%")
                        }
                    }

                    if let error = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingErrorKey) as? Error {
                        observers.forEach { NotificationCenter.default.removeObserver($0) }
                        query.stop()
                        continuation.resume(throwing: error)
                    }
                } else if downloadStatus == "NSMetadataUbiquitousItemDownloadingStatusCurrent" {
                    if verbose {
                        os_log("\(self.t)文件下载完成")
                    }
                    observers.forEach { NotificationCenter.default.removeObserver($0) }
                    query.stop()
                    continuation.resume(returning: ())
                }
            }
            observers.append(updateObserver)

            let finishObserver = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering,
                object: query,
                queue: .main
            ) { _ in
                if verbose {
                    os_log("\(self.t)查询完成")
                }
            }
            observers.append(finishObserver)

            query.start()
        }
    }

    /// 获取文件的下载进度快照
    /// - Parameters:
    ///   - verbose: 是否输出详细日志，默认为 false（避免频繁调用时产生大量日志）
    /// - Returns: 下载进度（0.0 到 1.0 之间）
    /// - Note: 此函数会访问文件系统，建议在后台线程调用
    /// - Performance: ~1-5ms for iCloud files, ~0.1μs for local files
    func getDownloadProgressSnapshot(verbose: Bool = false) -> Double {
        if verbose {
            os_log("\(self.t)<\(self.title)>获取下载进度")
        }
        
        // 💡 关键：强制清理 URL 的内部资源属性缓存，确保获取到磁盘上的最新状态
        var mutableSelf = self
        mutableSelf.removeAllCachedResourceValues()

        // 如果是本地文件，直接返回 1.0
        if isLocal {
            if verbose {
                os_log("\(self.t)<\(self.title)>是本地文件，下载进度 100% ✅")
            }
            return 1.0
        }

        // 如果是 iCloud 文件，获取下载进度
        if checkIsICloud(verbose: false) {
            // 💡 使用 iCloud 专用属性获取下载进度
            let percentKey = URLResourceKey(rawValue: "NSURLUbiquitousItemPercentDownloadedKey")
            guard let resources = try? mutableSelf.resourceValues(forKeys: [
                .fileSizeKey,
                .fileAllocatedSizeKey,
                .ubiquitousItemDownloadingStatusKey,
                .ubiquitousItemIsDownloadingKey,
                percentKey,
            ]) else {
                os_log("\(self.t)<\(self.title)>无法获取文件信息 ❌")
                return 0.0
            }
            
            // 所有获取到的属性
            let status = resources.ubiquitousItemDownloadingStatus
            let isDownloading = resources.ubiquitousItemIsDownloading
            let percent = resources.allValues[percentKey] as? Double
            let fileSize = resources.fileSize
            let allocatedSize = resources.fileAllocatedSize
            
            // 优先检查下载状态
            if let status = status, status == .current {
                return 1.0
            }
            
            // 优先使用 iCloud 提供的百分比进度（更准确）
            if let percent = percent, percent > 0 {
                let progress = percent / 100.0
                return min(progress, 1.0)
            }

            // 降级方案：使用文件大小计算
            guard let totalSize = fileSize, totalSize > 0,
                  let downloadedSize = allocatedSize else {
                return 0.0
            }

            let progress = Double(downloadedSize) / Double(totalSize)
            return progress
        }

        if verbose {
            os_log("\(self.t)<\(self.title)>非本地文件，也非iCloud文件，返回下载进度 0% ")
        }

        return 0.0
    }
}
