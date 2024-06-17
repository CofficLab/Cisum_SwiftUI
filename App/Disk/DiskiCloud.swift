import Foundation
import OSLog

class DiskiCloud: ObservableObject {
    static var label = "☁️ DiskiCloud::"
    
    var queue = DispatchQueue(label: "DiskiCloud", qos: .background)
    var fileManager = FileManager.default
    var cloudHandler = CloudHandler()
    var audiosDir: URL = AppConfig.audiosDir
    var bg = AppConfig.bgQueue
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var verbose = true
    var onUpdated: (_ items: DiskFileGroup) -> Void = { items in
        os_log("\(Logger.isMain)\(DiskiCloud.label)updated with items.count=\(items.count)")
    }
    
    func trash(_ audio: Audio) async {
        let url = audio.url
        let ext = audio.ext
        let fileName = audio.title
        let trashDir = AppConfig.trashDir
        var trashUrl = trashDir.appendingPathComponent(url.lastPathComponent)
        var times = 1
        
        // 回收站已经存在同名文件
        while fileManager.fileExists(atPath: trashUrl.path) {
            trashUrl = trashUrl.deletingLastPathComponent()
                .appendingPathComponent("\(fileName)-\(times)")
                .appendingPathExtension(ext)
            times += 1
        }
        
        // 文件不存在
        if !fileManager.fileExists(atPath: audio.url.path) {
            return
        }
            
        // 移动到回收站
        do {
            try await cloudHandler.moveFile(at: audio.url, to: trashUrl)
        } catch let e {
            os_log(.error, "\(Logger.isMain)☁️⚠️ CloudFile::trash \(e.localizedDescription)")
        }
    }
}

// MARK: Delete

extension DiskiCloud {
    func deleteFiles(_ audios: [Audio]) throws {
        for audio in audios {
            if verbose {
                os_log("\(self.label)删除 \(audio.title)")
            }
            
            if fileManager.fileExists(atPath: audio.url.path) == false {
                continue
            }
            
            try fileManager.removeItem(at: audio.url)
        }
    }
    
    func deleteFile(_ audio: Audio) throws {
        try deleteFiles([audio])
    }
}

extension DiskiCloud: DiskContact {
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
    
    func download(_ audio: Audio) async {
        if audio.isNotExists {
            //os_log("\(self.label)Download \(audio.title) -> Not Exists")
            return
        }
        
//        if audio.isDownloaded {
//            //os_log("\(self.label)Download \(audio.title) -> Already downloaded")
//            return
//        }
        
//        if audio.isDownloading {
//            //os_log("\(self.label)Download \(audio.title) -> Already downloading")
//            return
//        }
        
//        let downloadingCount = getDownloadingCount()
        
//        if downloadingCount > 10 {
//            os_log("\(self.label)Download \(audio.title) -> Ignore ❄️❄️❄️ -> Downloading.count=\(downloadingCount)")
//            
//            return
//        }
        
        //os_log("\(self.label)Download \(audio.title)")
        
        do {
            try await cloudHandler.download(url: audio.url)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
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
