import Foundation
import OSLog

class DiskiCloud: ObservableObject, Disk {
    static var label = "☁️ DiskiCloud::"
    static let cloudRoot = Config.cloudDocumentsDir

    // MARK: 磁盘的挂载目录

    static func getMountedURL() -> URL? {
        guard let cloudRoot = Self.cloudRoot else {
            os_log(.error, "\(self.label)无法获取根目录，因为 CloudRoot=nil")
            
            return nil
        }

        return cloudRoot
    }
    
    var root: URL
    var queue = DispatchQueue(label: "DiskiCloud", qos: .background)
    var fileManager = FileManager.default
    var cloudHandler = iCloudHandler()
    var bg = Config.bgQueue
    var query: ItemQuery
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var verbose = true
    var onUpdated: (_ items: DiskFileGroup) -> Void = { items in
        os_log("\(Logger.isMain)\(DiskiCloud.label)updated with items.count=\(items.count)")
    }
    
    required init(root: URL) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        self.root = root
        self.query = ItemQuery(queue: queue)
    }
}

// MARK: GetTree

extension DiskiCloud {
    func getRoot() -> DiskFile {
        DiskFile.fromURL(root)
    }
    
    func next(_ url: URL) -> DiskFile? {
        DiskFile(url: url).next()
    }
    
    func getTotal() -> Int {
        0
    }
}

// MARK: Delete

extension DiskiCloud {
    func deleteFiles(_ urls: [URL]) {
        for url in urls {
            if verbose {
                os_log("\(self.label)删除 \(url.lastPathComponent)")
            }
            
            if fileManager.fileExists(atPath: url.path) == false {
                continue
            }
            
            try? fileManager.removeItem(at: url)
        }
    }
    
    func deleteFile(_ url: URL) {
        deleteFiles([url])
    }
}

extension DiskiCloud {
    func clearFolderContents(atPath path: String) {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for item in contents {
                let itemPath = URL(fileURLWithPath: path).appendingPathComponent(item).path
                try fileManager.removeItem(atPath: itemPath)
            }
        } catch {
            os_log("\(Logger.isMain)\(self.label)clearFolderContents error: \(error.localizedDescription)")
        }
    }
}

// MARK: Copy

extension DiskiCloud {
    func copyTo(url: URL) throws {
        os_log("\(self.label)copy \(url.lastPathComponent)")
        
        // 目的地已经存在同名文件
        var d = root.appendingPathComponent(url.lastPathComponent)
        var times = 1
        let fileName = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        while fileManager.fileExists(atPath: d.path) {
            d = d.deletingLastPathComponent()
                .appendingPathComponent("\(fileName)-\(times)")
                .appendingPathExtension(ext)
            times += 1
            os_log("\(self.label)copy  -> \(d.lastPathComponent)")
        }
        
        do {
            // 获取授权
            if url.startAccessingSecurityScopedResource() {
                os_log(
                    "\(self.label)copy 获取授权后复制 \(url.lastPathComponent, privacy: .public)"
                )
                try FileManager.default.copyItem(at: url, to: d)
                url.stopAccessingSecurityScopedResource()
            } else {
                os_log("\(self.label)copy 获取授权失败，可能不是用户选择的文件，直接复制 \(url.lastPathComponent)")
                try fileManager.copyItem(at: url, to: d)
            }
        } catch {
            os_log("\(self.label)复制文件发生错误 -> \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: Download

extension DiskiCloud {
    func evict(_ url: URL) {
        Task {
            try? await cloudHandler.evict(url: url)
        }
    }
    
    func download(_ url: URL, reason: String) {
        let verbose = false

        if verbose {
            os_log("\(self.label)Download ⏬⏬⏬ \(url.lastPathComponent) reason -> \(reason)")
        }
        
        if !fileManager.fileExists(atPath: url.path) {
            if verbose {
                os_log("\(self.label)Download \(url.lastPathComponent) -> Not Exists ⚠️⚠️⚠️")
            }
            
            return
        }
        
        if iCloudHelper.isDownloaded(url) {
            if verbose {
                os_log("\(self.label)Download \(url.lastPathComponent) -> Already downloaded ⚠️⚠️⚠️")
            }
            return
        }
        
        if iCloudHelper.isDownloading(url) {
            if verbose {
                os_log("\(self.label)Download \(url.lastPathComponent) -> Already downloading ⚠️⚠️⚠️")
            }
            return
        }
        
        let downloadingCount = getDownloadingCount()
        
        if downloadingCount > 1000 {
            os_log("\(self.label)Download \(url.lastPathComponent) -> Ignore ❄️❄️❄️ -> Downloading.count=\(downloadingCount)")
            
            return
        }
        
        Task {
            do {
                try await cloudHandler.download(url: url)
            } catch let e {
                os_log(.error, "\(self.label)Download(\(reason))出错->\(e.localizedDescription)")
            }
        }
    }
    
    func getDownloadingCount() -> Int {
        var count = 0
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: self.root.path)
            for file in files {
                if iCloudHelper.isDownloading(URL(fileURLWithPath: root.path).appendingPathComponent(file)) {
                    count += 1
                }
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
        
        return count
    }
}

// MARK: Watch

extension DiskiCloud {
    func stopWatch(reason: String) {
        let emoji = "🌛🌛🌛"
        
        os_log("\(self.label)\(emoji) 停止监听 because of \(reason)")
        self.query.stop()
    }
    
    /// 监听存储Audio文件的文件夹
    func watch() async {
        let verbose = true
        let emoji = "🌞🌞🌞"
        
        if verbose {
            os_log("\(Logger.isMain)\(self.label)\(emoji) Watch(\(self.name))")
        }

        self.query.stopped = false
        let result = query.searchMetadataItems(predicates:  [
            NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, root.path + "/"),
            NSPredicate(format: "NOT %K ENDSWITH %@", NSMetadataItemFSNameKey, ".DS_Store"),
            NSPredicate(format: "NOT %K ENDSWITH %@", NSMetadataItemFSNameKey, ".zip"),
            NSPredicate(format: "NOT %K ENDSWITH %@", NSMetadataItemFSNameKey, ".plist"),
            NSPredicate(format: "NOT %K BEGINSWITH %@", NSMetadataItemFSNameKey, "."),
            NSPredicate(format: "NOT %K BEGINSWITH[c] %@", NSMetadataItemFSNameKey, ".")
        ]).debounce(for: .seconds(0.2))
        for try await collection in result {
            os_log("\(Logger.isMain)\(self.label)\(emoji) Watch(\(collection.items.count))")
                
            self.onUpdated(DiskFileGroup.fromMetaCollection(collection))
        }
    }
}

// MARK: Move

extension DiskiCloud {
    func moveFile(at sourceURL: URL, to destinationURL: URL) async {
        do {
            try await self.cloudHandler.moveFile(at: sourceURL, to: destinationURL)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}

// MARK: MakeURL

extension DiskiCloud {
    func makeURL(_ fileName: String) -> URL {
        self.root.appending(component: fileName)
    }
}
