import Foundation
import OSLog

class DiskLocal: ObservableObject, Disk {
    static let label = "🛖 DiskLocal::"
    static let rootDirName = Config.audiosDirName
    static let localDocumentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    static var defaultRoot: URL {
        let fileManager = FileManager.default
        let url = Self.localDocumentsDir!.appendingPathComponent(Self.rootDirName)

        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                os_log(.error, "\(self.label)创建根目录失败 -> \(error.localizedDescription)")
            }
        }

        return url
    }
    
    static func makeSub(_ subDirName: String) -> any Disk {
        let fileManager = FileManager.default
        let subRoot = DiskLocal.defaultRoot.appendingPathComponent(subDirName)
        
        if !fileManager.fileExists(atPath: subRoot.path) {
            do {
                try fileManager.createDirectory(at: subRoot, withIntermediateDirectories: true)
            } catch {
                os_log(.error, "\(self.label)创建根目录失败 -> \(error.localizedDescription)")
            }
        }

        return DiskLocal(root: subRoot)
    }

    var name: String { "本地磁盘:\(root)" }
    var fileManager = FileManager.default
    var bg = Config.bgQueue
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var root: URL
    var db: DB = DB(Config.getContainer, reason: "DiskLocal")
    var onUpdated: (_ collection: DiskFileGroup) -> Void = { collection in
        os_log("\(Logger.isMain)\(DiskiCloud.label)updated with items.count=\(collection.count)")
    }
    
    init(root: URL = DiskLocal.defaultRoot) {
        self.root = root
    }
    
    func getRoot() -> DiskFile {
        DiskFile.fromURL(root)
    }
    func getTotal() -> Int {
        0
    }
}

// MARK: Next

extension DiskLocal {
    func next(_ url: URL) -> DiskFile? {
        return nil
    }
}

// MARK: Delete

extension DiskLocal {
    func deleteFiles(_ urls: [URL]) {
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
            os_log("\(Logger.isMain)\(self.label)clearFolderContents error: \(error.localizedDescription)")
        }
    }
    
    func deleteFile(_ url: URL) {
        let verbose = false
        
        if verbose {
            os_log("\(self.label)删除 \(url)")
        }
        
        if fileManager.fileExists(atPath: url.path) == false {
            return
        }
        
        try? fileManager.removeItem(at: url)
    }
}

// MARK: Copy

extension DiskLocal {
    func copy(_ urls: [URL]) {
        Task {
            await self.db.addCopyTasks(urls)
        }
    }
    
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
    
    func copyFiles() {
        Task.detached(priority: .low) {
            let tasks = await self.db.allCopyTasks()

//            for task in tasks {
//                Task {
//                    do {
//                        let context = ModelContext(self.modelContainer)
//                        let url = task.url
//                        try await self.disk.copyTo(url: url)
//                        try context.delete(model: CopyTask.self, where: #Predicate { item in
//                            item.url == url
//                        })
//                        try context.save()
//                    } catch let e {
//                        await self.setTaskError(task, e)
//                    }
//                }
//            }
        }
    }
}

// MARK: Evit

extension DiskLocal {
    func evict(_ url: URL) {
        return
    }
}

// MARK: Download

extension DiskLocal {
    func getDownloadingCount() -> Int {
        return 0
    }
    
    func download(_ url: URL, reason: String) {
        
    }
}

// MARK: Watch

extension DiskLocal {
    func watchAudiosFolder() async {
         os_log("\(self.label)WatchAudiosFolder")

        let presenter = FilePresenter(fileURL: self.root)
        
        self.onUpdated(.fromURLs(presenter.getFiles(), isFullLoad: true))
        
        presenter.onDidChange = {
            self.onUpdated(.fromURLs(presenter.getFiles(), isFullLoad: true))
        }
    }
}

// MARK: Move

extension DiskLocal {
    func moveFile(at sourceURL: URL, to destinationURL: URL) {
        do {
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
}

// MARK: MakeURL

extension DiskLocal {
    func makeURL(_ fileName: String) -> URL {
        self.root.appending(component: fileName)
    }
}
