import Foundation

protocol Disk {
    static func makeSub(_ subDirName: String) -> Disk
    
    var name: String { get }
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
    
    func watchAudiosFolder() async
    
    func getDownloadingCount() -> Int
    
    func moveFile(at sourceURL: URL, to destinationURL: URL) 
    
    func makeURL(_ fileName: String) -> URL
    
    func getRoot() -> DiskFile

    func next(_ url: URL) -> DiskFile?
    
    func getTotal() -> Int
    
    // MARK: 复制
    
    func copy(_ urls: [URL])
    func copyFiles()
}

extension Disk {
    /// 下载当前的和当前的后面的X个
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
    
    func makeSub(_ subDirName: String) -> Disk {
        Self.makeSub(subDirName)
    }
}
