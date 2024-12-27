import Foundation
import OSLog
import MagicKit
import MagicUI

protocol DiskDelegate {
    func onUpdate(_ items: DiskFileGroup) async -> Void
}

protocol SuperStorage: FileBox {
    static var label: String { get }
    static func make(_ subDirName: String, delegate: DiskDelegate?, verbose: Bool, reason: String) -> (any SuperStorage)?
    static func getMountedURL(verbose: Bool) -> URL?

    var root: URL { get }
    
    init(root: URL, delegate: DiskDelegate?)

    func clearFolderContents(atPath path: String)

    func deleteFile(_ url: URL) throws

    func deleteFiles(_ urls: [URL]) throws
    
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

extension SuperStorage {
    var url: URL { root }
    
    public static var label: String {
        let fullName = String(describing: Self.self)
        if let genericStart = fullName.firstIndex(of: "<") {
            return String(fullName[..<genericStart])
        }
        return fullName
    }

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

    static func make(_ subDirName: String, delegate: DiskDelegate? = nil, verbose: Bool, reason: String) -> (any SuperStorage)? {
        if verbose {
            os_log("\(self.t)创建Disk: \(subDirName) 🐛 \(reason)")
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
                os_log(.error, "\(self.t)创建Disk失败 -> \(error.localizedDescription)")

                return nil
            }
        }

        return Self(root: subRoot, delegate: delegate)
    }

    func make(_ subDirName: String, verbose: Bool, reason: String) -> (any SuperStorage)? {
        Self.make(subDirName, verbose: verbose, reason: reason)
    }
}
