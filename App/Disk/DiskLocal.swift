import Foundation
import OSLog

class DiskLocal: ObservableObject {
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

    var name: String = "本地文件夹"
    var fileManager = FileManager.default
    var bg = Config.bgQueue
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var root: URL
    var onUpdated: (_ collection: DiskFileGroup) -> Void = { collection in
        os_log("\(Logger.isMain)\(DiskiCloud.label)updated with items.count=\(collection.count)")
    }
    
    init(_ root: URL = DiskLocal.defaultRoot) {
        self.root = root
    }
}

// MARK: Delete

extension DiskLocal: Disk {
    func download(_ url: URL, reason: String) {
        
    }
    
    func next(_ url: URL) -> DiskFile? {
        return nil
    }
    
    func getTotal() -> Int {
        0
    }
    
    
    func deleteFiles(_ urls: [URL]) {
    }
    
    func getRoot() -> DiskFile {
        DiskFile.fromURL(root)
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

    // MARK: 将文件复制到音频目录

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

extension DiskLocal {
    func evict(_ url: URL) {
        return
    }

    func download(_ url: URL, reason: String) async {
        return
    }

    func getDownloadingCount() -> Int {
        return 0
    }
}

// MARK: Watch

extension DiskLocal {
    /// 监听存储Audio文件的文件夹
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
