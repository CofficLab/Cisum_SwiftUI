import AsyncAlgorithms
import Foundation

class ItemQuery {
    let query = NSMetadataQuery()
    let queue: OperationQueue
    let url: URL

    init(queue: OperationQueue = .main, url: URL) {
        self.queue = queue
        self.url = url
    }

    // MARK: 监听文件夹中文件被删除的事件

    func searchDeletedMetadataItems(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        scopes: [Any] = [NSMetadataQueryUbiquitousDocumentsScope]
    ) -> AsyncStream<[MetadataItemWrapper]> {
        query.searchScopes = scopes
        query.sortDescriptors = sortDescriptors
        query.predicate = NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, url.path + "/")

        return AsyncStream { continuation in
            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate,
                object: query,
                queue: queue
            ) { notification in
                if let deletedItems = notification.userInfo?[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem] {
                    let result = deletedItems.compactMap { item -> MetadataItemWrapper? in
                        MetadataItemWrapper(metadataItem: item)
                    }
                    continuation.yield(result)
                }
            }

            query.start()

            continuation.onTermination = { @Sendable _ in
                self.query.stop()
                NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidUpdate, object: self.query)
            }
        }
    }

    // MARK: 监听文件夹中文件正在下载的事件

    func searchDownloadingMetadataItems(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        scopes: [Any] = [NSMetadataQueryUbiquitousDocumentsScope]
    ) -> AsyncStream<[MetadataItemWrapper]> {
        query.searchScopes = scopes
        query.sortDescriptors = sortDescriptors
        query.predicate = NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, url.path + "/")

        return AsyncStream { continuation in
            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering,
                object: query,
                queue: queue
            ) { _ in
                let result = self.query.results.compactMap { item -> MetadataItemWrapper? in
                    guard let metadataItem = item as? NSMetadataItem else {
                        return nil
                    }
                    return MetadataItemWrapper(metadataItem: metadataItem)
                }

                continuation.yield(result.filter { $0.isDownloading })
            }

            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate,
                object: query,
                queue: queue
            ) { _ in
                let result = self.query.results.compactMap { item -> MetadataItemWrapper? in
                    guard let metadataItem = item as? NSMetadataItem else {
                        return nil
                    }
                    return MetadataItemWrapper(metadataItem: metadataItem)
                }
                
                continuation.yield(result.filter { $0.isDownloading })
            }

            query.start()

            continuation.onTermination = { @Sendable _ in
                self.query.stop()
                NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidUpdate, object: self.query)
            }
        }
    }

    func searchMetadataItems(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        scopes: [Any] = [NSMetadataQueryUbiquitousDocumentsScope]
    ) -> AsyncStream<[MetadataItemWrapper]> {
        query.searchScopes = scopes
        query.sortDescriptors = sortDescriptors
        query.predicate = NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, url.path + "/")

        return AsyncStream { continuation in
            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering,
                object: query,
                queue: queue
            ) { _ in
                let result = self.query.results.compactMap { item -> MetadataItemWrapper? in
                    guard let metadataItem = item as? NSMetadataItem else {
                        return nil
                    }
                    return MetadataItemWrapper(metadataItem: metadataItem)
                }
                continuation.yield(result)
            }

//            NotificationCenter.default.addObserver(
//                forName: .NSMetadataQueryDidUpdate,
//                object: query,
//                queue: queue
//            ) { _ in
//                let result = self.query.results.compactMap { item -> MetadataItemWrapper? in
//                    guard let metadataItem = item as? NSMetadataItem else {
//                        return nil
//                    }
//                    return MetadataItemWrapper(metadataItem: metadataItem)
//                }
//                continuation.yield(result)
//            }

            query.start()

            continuation.onTermination = { @Sendable _ in
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
    let downloadProgress: Double
    let uploaded: Bool

    init(metadataItem: NSMetadataItem) {
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
