import Foundation
import OSLog

class DiskiCloud: ObservableObject, Disk {
    func download(_ url: URL, reason: String) {
        
    }
    
    func next(_ url: URL) -> DiskFile? {
        nil
    }
    
    func getTotal() -> Int {
        0
    }
    
    static var label = "☁️ DiskiCloud::"
    
    var name: String = "iCloud 文件夹"
    var queue = DispatchQueue(label: "DiskiCloud", qos: .background)
    var fileManager = FileManager.default
    var cloudHandler = iCloudHandler()
    var audiosDir: URL {
        let url = Config.cloudDocumentsDir.appendingPathComponent(Config.audiosDirName)

        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
                os_log("\(Logger.isMain)🍋 DB::创建 Audios 目录成功")
            } catch {
                os_log("\(Logger.isMain)创建 Audios 目录失败\n\(error.localizedDescription)")
            }
        }

        return url
    }
    var bg = Config.bgQueue
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var verbose = true
    var onUpdated: (_ items: DiskFileGroup) -> Void = { items in
        os_log("\(Logger.isMain)\(DiskiCloud.label)updated with items.count=\(items.count)")
    }
}

// MARK: GetTree

extension DiskiCloud {
    func getRoot() -> DiskFile {
        DiskFile.fromURL(audiosDir)
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

    // MARK: 将文件复制到音频目录

    func copyTo(url: URL) throws {
        os_log("\(self.label)copy \(url.lastPathComponent)")
        
        // 目的地已经存在同名文件
        var d = audiosDir.appendingPathComponent(url.lastPathComponent)
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
    
    func download(_ url: URL, reason: String) async {
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
        
//        let downloadingCount = getDownloadingCount()
//        
//        if downloadingCount > 10 {
//            os_log("\(self.label)Download \(url.lastPathComponent) -> Ignore ❄️❄️❄️ -> Downloading.count=\(downloadingCount)")
//            
//            return
//        }
        
        do {
            try await cloudHandler.download(url: url)
        } catch let e {
            os_log(.error, "\(self.label)Download(\(reason))出错->\(e.localizedDescription)")
        }
    }
    
    func getDownloadingCount() -> Int {
        var count = 0
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: self.audiosDir.path)
            for file in files {
                if iCloudHelper.isDownloading(URL(fileURLWithPath: audiosDir.path).appendingPathComponent(file)) {
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
    /// 监听存储Audio文件的文件夹
    func watchAudiosFolder() async {
        //os_log("\(Logger.isMain)\(self.label)WatchAudiosFolder")

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let query = ItemQuery(queue: queue, url: self.audiosDir)
        let result = query.searchMetadataItems()
        for try await collection in result {
            os_log("\(Logger.isMain)\(self.label)WatchAudiosFolder -> count=\(collection.items.count)")
                
            self.onUpdated(DiskFileGroup.fromMetaCollection(collection))
        }
    }
}

// MARK: Move

extension DiskiCloud {
    func moveFile(at sourceURL: URL, to destinationURL: URL) {
        let handler = iCloudHandler()
        Task {
            do {
                try await handler.moveFile(at: sourceURL, to: destinationURL)
            } catch let e {
                os_log(.error, "\(e.localizedDescription)")
            }
        }
    }
}

// MARK: MakeURL

extension DiskiCloud {
    func makeURL(_ fileName: String) -> URL {
        self.audiosDir.appending(component: fileName)
    }
}
