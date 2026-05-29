import Combine
import Foundation
import OSLog

/// 监听 iCloud 文件夹内容变化的专用类
/// - Note: 使用 NSMetadataQuery 进行 iCloud 文件同步状态监听
public final class ICloudDirectoryMonitor: SuperLog {
    public static let emoji = "☁️"
    
    // MARK: - Types

    public typealias onChangeCallback = @Sendable (_ files: [URL], _ isInitialFetch: Bool, _ error: Error?) -> Void
    public typealias onDeletedCallback = @Sendable (_ urls: [URL]) -> Void
    public typealias onProgressCallback = @Sendable (_ url: URL, _ progress: Double) -> Void

    /// 进度更新节流控制（防止过于频繁的进度更新）
    private actor ProgressThrottle {
        private var lastUpdateTime: [URL: Date] = [:]
        private var lastProgress: [URL: Double] = [:]
        private let minInterval: TimeInterval = 0.5

        func shouldUpdate(for url: URL, progress: Double) -> Bool {
            let now = Date()
            let lastTime = lastUpdateTime[url] ?? .distantPast
            let previousProgress = lastProgress[url] ?? 0.0

            let isFirstUpdate = lastProgress[url] == nil
            let isComplete = progress >= 1.0
            let timeElapsed = now.timeIntervalSince(lastTime) >= minInterval
            let significantChange = abs(progress - previousProgress) >= 0.05

            if isFirstUpdate || isComplete || timeElapsed || significantChange {
                lastUpdateTime[url] = now
                lastProgress[url] = progress
                return true
            }

            return false
        }

        func reset(for url: URL) {
            lastUpdateTime.removeValue(forKey: url)
            lastProgress.removeValue(forKey: url)
        }
    }

    // MARK: - Properties

    private let directoryURL: URL
    private let verbose: Bool
    private let caller: String
    private let onChange: onChangeCallback
    private let onDeleted: onDeletedCallback
    private let onProgress: onProgressCallback

    private let query = NSMetadataQuery()
    private var cancellables = Set<AnyCancellable>()
    private let progressThrottle = ProgressThrottle()
    private let normalizedPath: String

    // MARK: - Initialization

    /// 初始化 iCloud 目录监听器
    /// - Parameters:
    ///   - directoryURL: 要监听的目录 URL
    ///   - verbose: 是否打印详细日志
    ///   - caller: 调用者名称
    ///   - onProgress: 进度回调
    ///   - onDeleted: 删除回调
    ///   - onChange: 变化回调
    public init(
        directoryURL: URL,
        verbose: Bool,
        caller: String,
        onProgress: @escaping onProgressCallback,
        onDeleted: @escaping onDeletedCallback,
        onChange: @escaping onChangeCallback
    ) {
        self.directoryURL = directoryURL
        self.verbose = verbose
        self.caller = caller
        self.onChange = onChange
        self.onDeleted = onDeleted
        self.onProgress = onProgress

        // 确保路径以 "/" 结尾，避免前缀匹配到相似名称的目录
        self.normalizedPath = directoryURL.path.hasSuffix("/")
            ? directoryURL.path
            : directoryURL.path + "/"
    }

    // MARK: - Public Methods

    /// 启动监听
    /// - Returns: 取消令牌
    @discardableResult
    public func start() -> AnyCancellable {
        // 1. 先配置查询参数
        configureQuery()

        // 2. 再设置通知处理器（必须在 startQuery 之前）
        setupNotificationHandlers()

        // 3. 最后启动查询（延迟一点，确保通知处理器已注册）
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if self.verbose {
                os_log("\(self.t)⏳ (\(self.caller)) 准备启动查询...")
            }

            // 额外延迟，确保通知订阅生效
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.verbose {
                    os_log("\(self.t)🚀 (\(self.caller)) 正在启动查询...")
                }
                self.startQuery()
            }
        }

        // 关键修复：闭包需要捕获 self 的强引用（不使用 weak）
        // 这样返回的 AnyCancellable 会持有 ICloudDirectoryMonitor 实例，防止被释放
        // 不会造成循环引用，因为 cancellables 只存储通知订阅，不持有 self
        return AnyCancellable { [self] in
            self.cancel()
        }
    }

    // MARK: - Private Methods - Query Setup

    private func configureQuery() {
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]

        if verbose {
            os_log("\(self.t)🔍 (\(self.caller)) 设置查询路径：\(self.normalizedPath)")
        }

        // 构建谓词：匹配指定目录下的文件，排除目录本身和系统文件
        let predicates = [
            NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, self.normalizedPath),
            NSPredicate(format: "%K.length > %d", NSMetadataItemPathKey, self.normalizedPath.count),
            NSPredicate(format: "NOT %K ENDSWITH %@", NSMetadataItemFSNameKey, ".DS_Store"),
        ]

        query.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        query.valueListAttributes = [
            NSMetadataItemURLKey,
            NSMetadataUbiquitousItemPercentDownloadedKey,
            NSMetadataUbiquitousItemIsDownloadingKey,
        ]
    }

    private func setupNotificationHandlers() {
        if verbose {
            os_log("\(self.t)📡 (\(self.caller)) 设置通知处理器...")
        }

        // 监听查询更新
        NotificationCenter.default.publisher(for: .NSMetadataQueryDidUpdate)
            .sink { [weak self] notification in
                guard let self = self else { return }
                if self.verbose {
                    os_log("\(self.t)📨 (\(self.caller)) 收到查询更新通知")
                }
                self.handleQueryUpdate(notification)
            }
            .store(in: &cancellables)

        // 监听初始查询完成
        NotificationCenter.default.publisher(for: .NSMetadataQueryDidFinishGathering)
            .sink { [weak self] notification in
                guard let self = self else { return }
                if self.verbose {
                    os_log("\(self.t)📨 (\(self.caller)) 收到查询完成通知")
                }
                self.handleQueryFinished(notification)
            }
            .store(in: &cancellables)

        if verbose {
            os_log("\(self.t)✅ [\(self.caller)] 通知处理器已注册")
        }
    }

    private func startQuery() {
        DispatchQueue.main.async {
            if self.verbose {
                os_log("\(self.t)🎯 (\(self.caller)) 调用 query.start()")
                os_log("\(self.t)🔧 (\(self.caller)) 查询状态：started=\(self.query.isStarted), gathering=\(self.query.isGathering)")
            }
            self.query.start()

            if self.verbose {
                os_log("\(self.t)✅ (\(self.caller)) query.start() 已返回")
            }
        }
    }

    // MARK: - Private Methods - Event Handlers

    private func handleQueryUpdate(_ notification: Notification) {
        guard let query = notification.object as? NSMetadataQuery, query === self.query else {
            return
        }

        let rawChangedItems = notification.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem]
        let rawDeletedItems = notification.userInfo?[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem]

        if verbose {
            os_log("\(self.t)🔔 (\(self.caller)) 查询更新")
            os_log("\(self.t)  • 变更数：\(rawChangedItems?.count ?? 0)")
            os_log("\(self.t)  • 删除数：\(rawDeletedItems?.count ?? 0)")
        }

        // 手动应用谓词过滤
        let changedItems = filterItems(rawChangedItems)
        let deletedItems = filterItems(rawDeletedItems)

        handleDownloadProgress(changedItems)
        processResults(isInitial: false, changedItems: changedItems, deletedItems: deletedItems)
    }

    private func handleQueryFinished(_ notification: Notification) {
        guard let query = notification.object as? NSMetadataQuery, query === self.query else {
            return
        }

        if verbose {
            os_log("\(self.t)✅ (\(self.caller)) 初始查询完成")
            os_log("\(self.t)  • 项目数量: \(query.resultCount)")

            // 打印所有找到的文件路径
            for i in 0..<min(query.resultCount, 10) { // 最多打印 10 个
                if let item = query.result(at: i) as? NSMetadataItem,
                   let path = item.value(forAttribute: NSMetadataItemPathKey) as? String {
                    os_log("\(self.t)  • [\(i)] \(path)")
                }
            }

            if query.resultCount > 10 {
                os_log("\(self.t)  • ... 还有 \(query.resultCount - 10) 个项目")
            }
        }

        processResults(isInitial: true)
    }

    // MARK: - Private Methods - Processing

    private func filterItems(_ items: [NSMetadataItem]?) -> [NSMetadataItem] {
        items?.filter { item in
            guard let itemPath = item.value(forAttribute: NSMetadataItemPathKey) as? String else {
                return false
            }

            let matchesPrefix = itemPath.hasPrefix(normalizedPath)
            let isNotDirectory = itemPath.count > normalizedPath.count
            let isNotDSStore = !(item.value(forAttribute: NSMetadataItemFSNameKey) as? String ?? "").hasSuffix(".DS_Store")

            return matchesPrefix && isNotDirectory && isNotDSStore
        } ?? []
    }

    private func handleDownloadProgress(_ items: [NSMetadataItem]) {
        Task.detached { [weak self] in
            guard let self = self else { return }

            for item in items {
                guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL,
                      let isDownloading = item.value(forAttribute: NSMetadataUbiquitousItemIsDownloadingKey) as? Bool,
                      let percentDownloaded = item.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double
                else { continue }

                let progress = max(0.0, min(1.0, percentDownloaded / 100))

                if isDownloading || progress >= 1.0 {
                    guard await self.progressThrottle.shouldUpdate(for: url, progress: progress) else { continue }

                    await MainActor.run {
                        self.onProgress(url, progress)
                    }

                    if progress >= 1.0 {
                        await self.progressThrottle.reset(for: url)
                    }
                } else {
                    await self.progressThrottle.reset(for: url)
                }
            }
        }
    }

    private func processResults(
        isInitial: Bool = false,
        changedItems: [NSMetadataItem]? = nil,
        deletedItems: [NSMetadataItem]? = nil
    ) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }

            self.query.disableUpdates()
            defer { self.query.enableUpdates() }

            let urls = self.extractUrls(isInitial: isInitial, changedItems: changedItems)

            if let deletedItems = deletedItems, !deletedItems.isEmpty {
                self.handleDeletedItems(deletedItems)
            }

            // 只有在有实际变化时才通知
            if isInitial || !urls.isEmpty {
                self.onChange(urls, isInitial, nil)
            } else if self.verbose {
                os_log("\(self.t)⏭️ (\(self.caller)) 无变化，跳过回调")
            }
        }
    }

    private func extractUrls(isInitial: Bool, changedItems: [NSMetadataItem]?) -> [URL] {
        if isInitial {
            let allItems = query.results as? [NSMetadataItem] ?? []
            return allItems.compactMap { $0.value(forAttribute: NSMetadataItemURLKey) as? URL }
        } else {
            return changedItems?.compactMap { item in
                guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else { return nil }
                if self.verbose {
                    os_log("\(self.t)🍋 [\(self.caller)] 变更文件：\(url.lastPathComponent)")
                }
                return url
            } ?? []
        }
    }

    private func handleDeletedItems(_ items: [NSMetadataItem]) {
        if verbose {
            os_log("\(self.t)🔍 (\(self.caller)) 处理已删除项目")
            os_log("\(self.t)  • 项目数量: \(items.count)")
        }

        let fileManager = FileManager.default
        var deletedUrls: [URL] = []

        for (index, item) in items.enumerated() {
            guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else {
                if verbose {
                    os_log(.error, "\(self.t)⚠️ (\(self.caller)) 已删除项目 \(index)：无 URL")
                }
                continue
            }

            let exists = fileManager.fileExists(atPath: url.path)
            if exists {
                if verbose {
                    os_log(.error, "\(self.t)⚠️ (\(self.caller)) 文件仍然存在：\(url.lastPathComponent)")
                }
                continue
            }

            deletedUrls.append(url)
            if verbose {
                os_log("\(self.t)✅ (\(self.caller)) 确认删除：\(url.lastPathComponent)")
            }
        }

        if !deletedUrls.isEmpty {
            if verbose {
                os_log("\(self.t)🗑️ (\(self.caller)) 调用 onDeleted")
                os_log("\(self.t)  • 文件数量: \(deletedUrls.count)")
            }

            DispatchQueue.main.async {
                self.onDeleted(deletedUrls)
            }
        }
    }

    // MARK: - Cleanup

    private func cancel() {
        if verbose {
            os_log("\(self.t)⏹️ (\(self.caller)) 停止 iCloud 监控器")
        }

        query.stop()
        cancellables.removeAll()
    }
}
