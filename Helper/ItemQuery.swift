import AsyncAlgorithms
import Foundation
import OSLog

class ItemQuery {
    let query = NSMetadataQuery()
    let queue: OperationQueue
    let url: URL

    init(queue: OperationQueue = .main, url: URL) {
        self.queue = queue
        self.url = url
    }

    // MARK: 监听某个目录的变化

    func searchMetadataItems(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        scopes: [Any] = [NSMetadataQueryUbiquitousDocumentsScope]
    ) -> AsyncStream<[MetadataItemWrapper]> {
        os_log("\(Logger.isMain)🍋 searchMetadataItems")
        query.searchScopes = scopes
        query.sortDescriptors = sortDescriptors
        query.predicate = NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, url.path + "/")

        return AsyncStream { continuation in
            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering,
                object: query,
                queue: queue
            ) { _ in
                DispatchQueue.global().async {
                    os_log("\(Logger.isMain)🍋 searchMetadataItems.NSMetadataQueryDidFinishGathering")
                    let result = self.query.results.compactMap { item -> MetadataItemWrapper? in
                        guard let metadataItem = item as? NSMetadataItem else {
                            return nil
                        }
                        return MetadataItemWrapper(metadataItem: metadataItem)
                    }
                    continuation.yield(result)
                }
            }

            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate,
                object: query,
                queue: queue
            ) { notification in
                DispatchQueue.global().async {
                    os_log("\(Logger.isMain)🍋 searchMetadataItems.NSMetadataQueryDidUpdate")
                    let changedItems = notification.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem] ?? []
                    let result = changedItems.compactMap { item -> MetadataItemWrapper? in
                        return MetadataItemWrapper(metadataItem: item)
                    }
                    continuation.yield(result)
                }
                
                if let deletedItems = notification.userInfo?[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem] {
                    let result = deletedItems.compactMap { item -> MetadataItemWrapper? in
                        MetadataItemWrapper(metadataItem: item, isDeleted: true)
                    }
                    continuation.yield(result)
                }
            }

            os_log("\(Logger.isMain)🍋 searchMetadataItems.start")
            query.start()

            continuation.onTermination = { @Sendable _ in
                os_log("\(Logger.isMain) onTermination")
                self.query.stop()
                NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: self.query)
                NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidUpdate, object: self.query)
            }
        }
    }
}

struct MetadataItemWrapper: Sendable {
    let fileName: String?
    let fileSize: Int?
    let contentType: String?
    let isDirectory: Bool
    let url: URL?
    let isPlaceholder: Bool
    let isDownloading: Bool
    let isDeleted: Bool
    let downloadProgress: Double
    let uploaded: Bool

    init(metadataItem: NSMetadataItem, isDeleted: Bool = false) {
        self.isDeleted = isDeleted
        fileName = metadataItem.value(forAttribute: NSMetadataItemFSNameKey) as? String
        fileSize = metadataItem.value(forAttribute: NSMetadataItemFSSizeKey) as? Int
        contentType = metadataItem.value(forAttribute: NSMetadataItemContentTypeKey) as? String

        // 检查是否是目录
        if let contentType = metadataItem.value(forAttribute: NSMetadataItemContentTypeKey) as? String {
            isDirectory = (contentType == "public.folder")
        } else {
            isDirectory = false
        }

        url = metadataItem.value(forAttribute: NSMetadataItemURLKey) as? URL

        if let downloadingStatus = metadataItem.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String {
            if downloadingStatus == NSMetadataUbiquitousItemDownloadingStatusNotDownloaded {
                // 文件是占位文件
                isPlaceholder = true
            } else if downloadingStatus == NSMetadataUbiquitousItemDownloadingStatusDownloaded || downloadingStatus == NSMetadataUbiquitousItemDownloadingStatusCurrent {
                // 文件已下载或是最新的
                isPlaceholder = false
            } else {
                isPlaceholder = false
            }
        } else {
            // 默认值，假设文件不是占位文件
            isPlaceholder = false
        }

        // 获取下载进度
        downloadProgress = metadataItem.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double ?? 0.0

        // 如果是占位文件且下载进度大于0且小于100，则认为文件正在下载
        isDownloading = isPlaceholder && downloadProgress > 0.0 && downloadProgress < 100.0

        // 是否已经上传完毕(只有 0 和 100 两个状态)
        uploaded = (metadataItem.value(forAttribute: NSMetadataUbiquitousItemPercentUploadedKey) as? Double ?? 0.0) == 100
    }
}
