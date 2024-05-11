import AsyncAlgorithms
import Foundation
import OSLog

class ItemQuery {
    let query = NSMetadataQuery()
    let queue: OperationQueue
    let url: URL
    var label: String {"\(Logger.isMain)📷 ItemQuery::"}
    var verbose = true

    init(queue: OperationQueue = .main, url: URL) {
        self.queue = queue
        self.url = url
    }

    // MARK: 监听某个目录的变化

    func searchMetadataItems(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        scopes: [Any] = [NSMetadataQueryUbiquitousDocumentsScope]
    ) -> AsyncStream<[MetaWrapper]> {
        if verbose {
            os_log("\(self.label)searchMetadataItems")
        }
        
        let predicates = [
            NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, url.path + "/"),
            NSPredicate(format: "NOT %K ENDSWITH %@", NSMetadataItemFSNameKey, ".DS_Store"),
            NSPredicate(format: "NOT %K ENDSWITH %@", NSMetadataItemFSNameKey, ".zip"),
            NSPredicate(format: "NOT %K ENDSWITH %@", NSMetadataItemFSNameKey, ".plist"),
            NSPredicate(format: "NOT %K BEGINSWITH %@", NSMetadataItemFSNameKey, "."),
            NSPredicate(format: "NOT %K BEGINSWITH[c] %@", NSMetadataItemFSNameKey, ".")
        ]
        query.searchScopes = scopes
        query.sortDescriptors = sortDescriptors
        query.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        return AsyncStream { continuation in
            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering,
                object: query,
                queue: queue
            ) { _ in
                self.collectAll(continuation)
            }

            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate,
                object: query,
                queue: queue
            ) { notification in
                self.collectChanged(continuation, notification: notification)
                self.collectDeleted(continuation, notification: notification)
            }

            query.operationQueue = queue
            query.operationQueue?.addOperation {
                os_log("\(self.label)start")
                self.query.start()
            }

            continuation.onTermination = { @Sendable _ in
                os_log("\(self.label)onTermination")
                self.query.stop()
                NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: self.query)
                NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidUpdate, object: self.query)
            }
        }
    }

    private func collectAll(_ continuation: AsyncStream<[MetaWrapper]>.Continuation) {
        DispatchQueue.global().async {
            if self.verbose {
                os_log("\(self.label)NSMetadataQueryDidFinishGathering")
            }
            
            let result = self.query.results.compactMap { item -> MetaWrapper? in
                guard let metadataItem = item as? NSMetadataItem else {
                    return nil
                }
                return MetaWrapper(metadataItem: metadataItem)
            }
            continuation.yield(result)
        }
    }

    private func collectChanged(_ continuation: AsyncStream<[MetaWrapper]>.Continuation, notification: Notification) {
        DispatchQueue.global().async {
            let changedItems = notification.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem] ?? []

            if self.verbose {
                os_log("\(self.label)NSMetadataQueryDidUpdate with changed items -> \(changedItems.count)")
            }

            let result = changedItems.compactMap { item -> MetaWrapper? in
                MetaWrapper(metadataItem: item, isUpdated: true)
            }
            if result.isEmpty == false {
                continuation.yield(result)
            }
        }
    }
    
    private func collectDeleted(_ continuation: AsyncStream<[MetaWrapper]>.Continuation, notification: Notification) {
        DispatchQueue.global().async {
            if let deletedItems = notification.userInfo?[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem] {
                if self.verbose {
                    os_log("\(self.label)NSMetadataQueryDidUpdate with deleted items -> \(deletedItems.count)")
                }

                let result = deletedItems.compactMap { item -> MetaWrapper? in
                    MetaWrapper(metadataItem: item, isDeleted: true, isUpdated: true)
                }
                continuation.yield(result)
            }
        }
    }
}
