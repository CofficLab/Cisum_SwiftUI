import AsyncAlgorithms
import Foundation
import OSLog

class ItemQuery {
    let query = NSMetadataQuery()
    let queue: OperationQueue
    let url: URL
    var label: String {"\(Logger.isMain)📁 ItemQuery::"}
    var verbose = true

    init(queue: OperationQueue = .main, url: URL) {
        self.queue = queue
        self.url = url
    }

    // MARK: 监听某个目录的变化

    func searchMetadataItems(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        scopes: [Any] = [NSMetadataQueryUbiquitousDocumentsScope],
        verbose: Bool = false
    ) -> AsyncStream<MetadataItemCollection> {
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
                self.collectAll(continuation, name: .NSMetadataQueryDidFinishGathering)
            }

            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate,
                object: query,
                queue: queue
            ) { notification in
                self.collectChanged(continuation, notification: notification, name: .NSMetadataQueryDidUpdate)
            }

            query.operationQueue = queue
            query.operationQueue?.addOperation {
                if verbose {
                    os_log("\(self.label)start")
                }
                
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

    // MARK: 所有的item
    
    private func collectAll(_ continuation: AsyncStream<MetadataItemCollection>.Continuation, name: Notification.Name) {
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
            
            continuation.yield(MetadataItemCollection(name: name, items: result))
        }
    }

    // MARK: 仅改变过的item
    
    private func collectChanged(_ continuation: AsyncStream<MetadataItemCollection>.Continuation, notification: Notification, name: Notification.Name) {
        DispatchQueue.global().async {
            if self.verbose {
                os_log("\(self.label)NSMetadataQueryDidUpdate")
            }
            
            let changedItems = notification.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem] ?? []
            let deletedItems = notification.userInfo?[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem] ?? []
            
            let changedResult = changedItems.compactMap { item -> MetaWrapper? in
                MetaWrapper(metadataItem: item, isUpdated: true)
            }
            
            let deletedResult = deletedItems.compactMap { item -> MetaWrapper? in
                MetaWrapper(metadataItem: item, isDeleted: true, isUpdated: true)
            }
                
            if changedResult.count > 0 {
                continuation.yield(MetadataItemCollection(name: name, items: changedResult))
            }
            
            if deletedResult.count > 0 {
                continuation.yield(MetadataItemCollection(name: name, items: deletedResult))
            }
        }
    }
}
