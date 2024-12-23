import Foundation
import OSLog

protocol DiskDelegate {
    func onUpdate(_ items: DiskFileGroup) async -> Void
}

protocol SuperDisk: FileBox {
    static var label: String { get }
    static func make(_ subDirName: String, delegate: DiskDelegate?, verbose: Bool, reason: String) -> (any SuperDisk)?
    static func getMountedURL(verbose: Bool) -> URL?

    var root: URL { get }
    
    init(root: URL, delegate: DiskDelegate?)

    func clearFolderContents(atPath path: String)

    func deleteFile(_ url: URL)

    func deleteFiles(_ urls: [URL])
    
    func download(_ url: URL, reason: String, verbose: Bool) async throws

    func evict(_ url: URL)

    func copyTo(url: URL, reason: String) throws

    func watch(reason: String, verbose: Bool) async

    func stopWatch(reason: String)

    func getDownloadingCount() -> Int

    func moveFile(at sourceURL: URL, to destinationURL: URL) async

    func makeURL(_ fileName: String) -> URL

    func getRoot() -> DiskFile

    func next(_ url: URL) -> DiskFile?

    func getTotal() -> Int
    
    func setDelegate(_ d: DiskDelegate)
}

extension SuperDisk {
    var url: URL { root }

    var name: String {
        Self.label + url.pathComponents.suffix(2).joined(separator: "/")
    }

    func getMountedURL() -> URL? {
        Self.getMountedURL(verbose: true)
    }

    // MARK: 下载

    func downloadNextBatch(_ url: URL, count: Int = 6, reason: String) {
        Task {
            do {
                var currentIndex = 0
                var currentURL: URL = url

                while currentIndex < count {
                    try await download(currentURL, reason: "downloadNext 🐛 \(reason)", verbose: false)

                    currentIndex = currentIndex + 1
                    if let next = self.next(currentURL) {
                        currentURL = next.url
                    }
                }
            } catch {
                os_log(.error, "downloadNext 🐛 \(reason) -> \(error.localizedDescription)")
            }
        }
    }

    // MARK: 创建磁盘

    static func make(_ subDirName: String, delegate: DiskDelegate? = nil, verbose: Bool, reason: String) -> (any SuperDisk)? {
        if verbose {
            os_log("\(self.label)创建Disk: \(subDirName) 🐛 \(reason)")
        }

        let fileManager = FileManager.default

        guard let mountedURL = Self.getMountedURL(verbose: verbose) else {
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

        return Self(root: subRoot, delegate: delegate)
    }

    func make(_ subDirName: String, verbose: Bool, reason: String) -> (any SuperDisk)? {
        Self.make(subDirName, verbose: verbose, reason: reason)
    }
}
