import Foundation
import OSLog

protocol Disk {
    static var label: String { get }
    static func make(_ subDirName: String) -> Disk?
    static func getMountedURL() -> URL?
    
    var root: URL { get }
    var onUpdated: (_ items: DiskFileGroup) -> Void { get set }
    
    func clearFolderContents(atPath path: String)
    
    /// 删除一个文件
    func deleteFile(_ url: URL)
    
    func deleteFiles(_ urls: [URL])
    
    /// 移除下载
    func evict(_ url: URL)
    
    func download(_ url: URL, reason: String)
    
    func copyTo(url: URL) throws
    
    func watch() async
    func stopWatch()
    
    func getDownloadingCount() -> Int
    
    func moveFile(at sourceURL: URL, to destinationURL: URL) 
    
    func makeURL(_ fileName: String) -> URL
    
    func getRoot() -> DiskFile

    func next(_ url: URL) -> DiskFile?
    
    func getTotal() -> Int
}

extension Disk {
    var name: String {
        Self.label + root.pathComponents.suffix(2).joined(separator: "/")
    }
    
    func getMountedURL() -> URL? {
        Self.getMountedURL()
    }
    
    // MARK: 下载
    
    func downloadNextBatch(_ url: URL, count: Int = 6, reason: String) {
        var currentIndex = 0
        var currentURL: URL = url

        while currentIndex < count {
            download(currentURL, reason: "downloadNext 🐛 \(reason)")

            currentIndex = currentIndex + 1
            if let next = self.next(currentURL) {
                currentURL = next.url
            }
        }
    }
    
    // MARK: 创建磁盘
    
    static func make(_ subDirName: String) -> (any Disk)? {
        let fileManager = FileManager.default
        
        guard let mountedURL = Self.getMountedURL() else {
            return nil
        }
        
        let subRoot = mountedURL.appendingPathComponent(subDirName)
        
        if !fileManager.fileExists(atPath: subRoot.path) {
            do {
                try fileManager.createDirectory(at: subRoot, withIntermediateDirectories: true)
            } catch {
                os_log(.error, "\(self.label)创建Disk失败 -> \(error.localizedDescription)")
                
                return nil
            }
        }

        return DiskiCloud(root: subRoot)
    }
    
    func make(_ subDirName: String) -> (any Disk)? {
        Self.make(subDirName)
    }
}
