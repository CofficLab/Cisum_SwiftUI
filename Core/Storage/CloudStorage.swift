import Foundation
import MagicKit
import MagicUI
import OSLog

class CloudStorage: ObservableObject, @preconcurrency SuperStorage, @preconcurrency SuperLog, SuperThread {
    static let emoji = "☁️"
    @MainActor
    static var cloudRoot: URL? {
        Config.cloudDocumentsDir
    }

    var delegate: DiskDelegate?

    // MARK: 磁盘的挂载目录

    @MainActor static func getMountedURL(verbose: Bool) -> URL? {
        guard let cloudRoot = Self.cloudRoot else {
            os_log(.error, "\(Self.t)无法获取根目录，因为 CloudRoot=nil")

            return nil
        }

        if verbose {
            os_log("\(self.t)磁盘的根目录是 \(cloudRoot.path())")
        }

        if FileManager.default.fileExists(atPath: cloudRoot.path(percentEncoded: false)) == false {
            os_log(.error, "CloudRoot 目录不存在")
        }

        return cloudRoot
    }

    var root: URL
    var queue = DispatchQueue(label: "DiskiCloud", qos: .background)
    var fileManager = FileManager.default
    var query: ItemQuery
    var verbose = true

    required init(root: URL, delegate: DiskDelegate?) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        self.root = root
        self.delegate = delegate
        self.query = ItemQuery(queue: queue)
    }

    func setDelegate(_ delegate: DiskDelegate) {
        self.delegate = delegate
    }

    func getRoot() -> DiskFile {
        DiskFile.fromURL(root)
    }

    func next(_ url: URL) -> DiskFile? {
        DiskFile(url: url).nextDiskFile()
    }

    func getTotal() -> Int {
        0
    }

    func deleteFiles(_ urls: [URL]) throws {
        for url in urls {
            if verbose {
                os_log("\(self.t)删除 \(url.lastPathComponent)")
            }

            try url.delete()
        }
    }

    func deleteFile(_ url: URL) throws {
        try deleteFiles([url])
    }

    func clearFolderContents(atPath path: String) {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for item in contents {
                let itemPath = URL(fileURLWithPath: path).appendingPathComponent(item).path
                try fileManager.removeItem(atPath: itemPath)
            }
        } catch {
            os_log("\(self.t)clearFolderContents error: \(error.localizedDescription)")
        }
    }

    func copyTo(url: URL, reason: String) throws {
        let verbose = true
        if verbose {
            os_log("\(self.t)copy \(url.lastPathComponent) because of \(reason)")
        }

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
            os_log("\(self.t)copy  -> \(d.lastPathComponent)")
        }

        os_log("\(self.t)copy 开始复制 \(url.lastPathComponent)")
        os_log("  ➡️ 从： \(url.relativePath)")
        os_log("  ➡️ 到： \(d.relativePath)")

        do {
            // 检查源文件的访问权限
            guard fileManager.isReadableFile(atPath: url.path) else {
                throw NSError(domain: "DiskiCloud", code: 403, userInfo: [NSLocalizedDescriptionKey: "没有读取源文件的权限: \(url.path)"])
            }

            // 检查目标文件夹是否存在，如果不存在则创建
            let destinationFolder = d.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: destinationFolder.path) {
                try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
                os_log("\(self.t)创建目标文件夹: \(destinationFolder.path)")
            }

            // 检查目标文件夹的访问权限
            guard fileManager.isWritableFile(atPath: destinationFolder.path) else {
                throw NSError(domain: "DiskiCloud", code: 403, userInfo: [NSLocalizedDescriptionKey: "没有写入目标文件夹的权限: \(destinationFolder.path)"])
            }

            // 执行复制操作
            try fileManager.copyItem(at: url, to: d)
            os_log("\(self.t)复制成功: \(d.path)")
        } catch {
            os_log(.error, "\(self.t)复制文件发生错误 -> \(error.localizedDescription)")

            // 添加更多诊断信息
            if let nsError = error as NSError? {
                os_log(.error, "\(self.t)错误域: \(nsError.domain)")
                os_log(.error, "\(self.t)错误代码: \(nsError.code)")
                if let failureReason = nsError.localizedFailureReason {
                    os_log(.error, "\(self.t)失败原因: \(failureReason)")
                }
                if let recoverySuggestion = nsError.localizedRecoverySuggestion {
                    os_log(.error, "\(self.t)恢复建议: \(recoverySuggestion)")
                }
            }

            // 检查文件的具体权限
            let attributes = try? fileManager.attributesOfItem(atPath: url.path)
            if let permissions = attributes?[.posixPermissions] as? Int {
                os_log(.error, "\(self.t)文件权限: \(String(format: "%o", permissions))")
            }

            throw error
        }
    }

    func evict(_ url: URL) {
        os_log("\(self.t)🏃🏃🏃 Evit \(url.lastPathComponent)")
        do {
            try url.evict()
        } catch {
            os_log(.error, "\(error.localizedDescription)")
        }
    }

    func download(_ url: URL, reason: String, verbose: Bool = false) async throws {
        if verbose {
            os_log("\(self.t)Download ⏬⏬⏬ \(url.lastPathComponent) 🐛 \(reason)")
        }

        try await url.download()
    }

    func getDownloadingCount() -> Int {
        var count = 0

        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: self.root.path)
            for file in files {
                if URL(fileURLWithPath: root.path).appendingPathComponent(file).isDownloading {
                    count += 1
                }
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return count
    }

    func stopWatch(reason: String) {
        let emoji = "🌛🌛🌛"
        let verbose = false

        if verbose {
            os_log("\(self.t)\(emoji) 停止监听 🐛 \(reason)")
        }

        self.query.stop()
    }

    /// 监听存储Audio文件的文件夹
    func watch(reason: String, verbose: Bool) async {
        let verbose2 = false

        if verbose {
            os_log("\(self.t)👀👀👀 Watch(\(self.name)) 🐛 \(reason)")
        }

        self.query.stopped = false
        let result = query.searchMetadataItems(predicates: [
            NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, root.path + "/"),
            NSPredicate(format: "NOT %K ENDSWITH %@", NSMetadataItemFSNameKey, ".DS_Store"),
            NSPredicate(format: "NOT %K ENDSWITH %@", NSMetadataItemFSNameKey, ".zip"),
            NSPredicate(format: "NOT %K ENDSWITH %@", NSMetadataItemFSNameKey, ".plist"),
            NSPredicate(format: "NOT %K BEGINSWITH %@", NSMetadataItemFSNameKey, "."),
            NSPredicate(format: "NOT %K BEGINSWITH[c] %@", NSMetadataItemFSNameKey, "."),
        ]).debounce(for: .seconds(0.3))
        for try await collection in result {
            var message = "\(self.t)👀👀👀 Watch(\(collection.items.count))"

            if let first = collection.first, first.isDownloading == true {
                message += " -> \(first.fileName ?? "-") -> \(String(format: "%.0f", first.downloadProgress))% ⏬⏬⏬"
            }

            if verbose {
                os_log("\(message)")
            }

            if verbose2 {
                if collection.count == 1, let first = collection.first {
                    os_log("   ➡️ FileName: \(first.fileName ?? "nil")")
                    os_log("   ➡️ Downloading: \(first.isDownloading ? "true" : "false")")
                    os_log("   ➡️ Downloaded: \(first.isDownloaded ? "true" : "false")")
                    os_log("   ➡️ Placeholder: \(first.isPlaceholder ? "true" : "false")")
                }
            }

//            await self.delegate?.onUpdate(DiskFileGroup.fromMetaCollection(collection, disk: self))
        }
    }

    func moveFile(at sourceURL: URL, to destinationURL: URL) async {
        do {
            try await sourceURL.moveTo(destinationURL)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    func makeURL(_ fileName: String) -> URL {
        self.root.appending(component: fileName)
    }
}
