import Foundation
import OSLog
import MagicKit
import MagicUI

class LocalStorage: ObservableObject, SuperStorage {
    static let emoji = "🛖"
    static let localRoot = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    static let null = LocalStorage(root: URL(string: "/dev/null")!) 
    
    static func getMountedURL(verbose: Bool) -> URL? {
        guard let localRoot = Self.localRoot else {
            return nil
        }
        
        return localRoot
    }

    var fileManager = FileManager.default
    var root: URL
    var delegate: DiskDelegate?
    
    required init(root: URL, delegate: DiskDelegate? = nil) {
        self.root = root
    }
    
    func getRoot() -> DiskFile {
        DiskFile.fromURL(root)
    }
    
    func getTotal() -> Int {
        0
    }

    func next(_ url: URL) -> DiskFile? {
        let diskFile = DiskFile(url: url)
        
        return diskFile.nextDiskFile()
    }

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
            os_log("\(self.t)clearFolderContents error: \(error.localizedDescription)")
        }
    }
    
    func deleteFile(_ url: URL) {
        let verbose = false
        
        if verbose {
            os_log("\(self.t)删除 \(url)")
        }
        
        if fileManager.fileExists(atPath: url.path) == false {
            return
        }
        
        try? fileManager.removeItem(at: url)
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
        
        do {
            // 获取授权
            if url.startAccessingSecurityScopedResource() {
                os_log(
                    "\(self.t)copy 获取授权后复制 \(url.lastPathComponent, privacy: .public)"
                )
                try FileManager.default.copyItem(at: url, to: d)
                url.stopAccessingSecurityScopedResource()
            } else {
                os_log("\(self.t)copy 获取授权失败，可能不是用户选择的文件，直接复制 \(url.lastPathComponent)")
                try fileManager.copyItem(at: url, to: d)
            }
        } catch {
            os_log("\(self.t)复制文件发生错误 -> \(error.localizedDescription)")
            throw error
        }
    }

    func evict(_ url: URL) {
        return
    }

    func getDownloadingCount() -> Int {
        return 0
    }
    
    func download(_ url: URL, reason: String, verbose: Bool) {
        return
    }

    func stopWatch(reason: String) {
        
    }
    
    func watch(reason: String, verbose: Bool) async {
        if verbose {
            os_log("\(self.t)👀👀👀 WatchAudiosFolder because of \(reason)")
        }

        let presenter = FilePresenter(fileURL: self.root)
        
        await self.delegate?.onUpdate(.fromURLs(presenter.getFiles(), isFullLoad: true, disk: self))
        
        presenter.onDidChange = {
            Task {
                await self.delegate?.onUpdate(.fromURLs(presenter.getFiles(), isFullLoad: true, disk: self))
            }
        }
    }

    func moveFile(at sourceURL: URL, to destinationURL: URL) async {
        do {
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }

    func makeURL(_ fileName: String) -> URL {
        self.root.appending(component: fileName)
    }
    
    func setDelegate(_ delegate: DiskDelegate) {
        self.delegate = delegate
    }
}
