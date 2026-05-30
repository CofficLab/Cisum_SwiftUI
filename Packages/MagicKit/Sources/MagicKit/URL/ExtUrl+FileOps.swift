import Foundation
import Combine
import CryptoKit
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

/// URL 扩展：文件操作基础方法
public extension URL {
    /// File/display title without the path extension.
    var title: String {
        deletingPathExtension().lastPathComponent
    }

    /// Whether the URL points to a directory.
    var isFolder: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? hasDirectoryPath
    }

    /// Alias for callers that use directory terminology.
    var isDirectory: Bool {
        isFolder
    }

    /// Whether the URL points to an existing directory.
    var isDirExist: Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
    }

    /// Whether the URL does not point to an existing directory.
    var isNotDirExist: Bool {
        !isDirExist
    }

    /// Whether the URL does not point to an existing file.
    var isNotFileExist: Bool {
        !FileManager.default.fileExists(atPath: path)
    }

    /// Whether the URL does not point to a directory.
    var isNotFolder: Bool {
        !isFolder
    }

    /// Whether a local/iCloud file is available on disk.
    var isDownloaded: Bool {
        if isFileURL, FileManager.default.fileExists(atPath: path) {
            return true
        }

        let values = try? resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])

        if values?.ubiquitousItemDownloadingStatus == URLUbiquitousItemDownloadingStatus.current {
            return true
        }

        return false
    }

    /// Whether an iCloud file is explicitly not downloaded.
    var isNotDownloaded: Bool {
        #if os(macOS)
            let values = try? resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
            return values?.ubiquitousItemDownloadingStatus == .notDownloaded
        #else
            return false
        #endif
    }

    /// 创建文件如果不存在，返回自身
    func createIfNotExist() -> URL {
        if !FileManager.default.fileExists(atPath: self.path) {
            try? FileManager.default.createDirectory(
                at: self.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            FileManager.default.createFile(atPath: self.path, contents: nil)
        }
        return self
    }

    /// 读取文件内容
    func getContent() throws -> String {
        try String(contentsOf: self)
    }

    /// 删除当前 URL 指向的文件或目录。
    func delete() throws {
        guard FileManager.default.fileExists(atPath: path) else {
            return
        }
        try FileManager.default.removeItem(at: self)
    }

    /// 复制当前文件到目标位置。
    func copyTo(
        _ destination: URL,
        verbose: Bool = true,
        caller: String,
        downloadProgress: ((Double) -> Void)? = nil
    ) async throws {
        try await ensureLocalAvailability()

        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }

        try FileManager.default.copyItem(at: self, to: destination)
    }

    /// Ensure an iCloud-backed file has finished downloading before a caller reads or copies it.
    func ensureLocalAvailability(
        timeout: TimeInterval = 120,
        pollInterval: TimeInterval = 0.25
    ) async throws {
        guard checkIsICloud(verbose: false) else { return }

        if isDownloaded { return }

        if isNotDownloaded {
            try FileManager.default.startDownloadingUbiquitousItem(at: self)
        }

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            try Task.checkCancellation()

            var refreshedURL = self
            refreshedURL.removeAllCachedResourceValues()
            if refreshedURL.isDownloaded {
                return
            }

            let nanoseconds = UInt64(max(pollInterval, 0.05) * 1_000_000_000)
            try await Task.sleep(nanoseconds: nanoseconds)
        }

        throw NSError(
            domain: "MagicKit.FileAvailability",
            code: 1,
            userInfo: [
                NSLocalizedDescriptionKey: "Timed out waiting for iCloud file to download: \(lastPathComponent)"
            ]
        )
    }

    /// 计算文件的 MD5 哈希值。
    func getHash(verbose: Bool = false) -> String {
        guard !isFolder else {
            return ""
        }

        do {
            let handle = try FileHandle(forReadingFrom: self)
            defer { try? handle.close() }

            var hash = Insecure.MD5()
            while true {
                let data = handle.readData(ofLength: 1024)
                if data.isEmpty { break }
                hash.update(data: data)
            }

            return hash.finalize().map { String(format: "%02hhx", $0) }.joined()
        } catch {
            return ""
        }
    }

    /// 获取父目录 URL。
    func getParent() -> URL {
        deletingLastPathComponent()
    }

    /// 获取路径最后三个组件的简短显示。
    func shortPath() -> String {
        lastThreeComponents()
    }

    /// 获取路径的最后三个组件。
    func lastThreeComponents() -> String {
        pathComponents
            .filter { $0 != "/" }
            .suffix(3)
            .joined(separator: "/")
    }

    /// 在 Finder 中打开文件夹
    func openFolder() {
        #if os(macOS)
            NSWorkspace.shared.activateFileViewerSelecting([self])
        #elseif os(iOS)
            UIApplication.shared.open(self)
        #endif
    }

    /// 在 Finder 中显示当前文件或目录。
    func openInFinder() {
        #if os(macOS)
            NSWorkspace.shared.activateFileViewerSelecting([self])
        #elseif os(iOS)
            UIApplication.shared.open(self)
        #endif
    }

    /// 在系统默认应用中打开当前 URL。
    func open() {
        #if os(macOS)
            NSWorkspace.shared.open(self)
        #elseif os(iOS)
            UIApplication.shared.open(self)
        #endif
    }

    /// 获取文件大小的可读格式。
    func getSizeReadable() -> String {
        let size = getSize()
        guard size > 0 else {
            return "0 bytes"
        }

        if size < 1024 {
            return "\(size) bytes"
        } else if size < 1024 * 1024 {
            return String(format: "%.1f KB", Double(size) / 1024.0)
        } else if size < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB", Double(size) / (1024.0 * 1024.0))
        } else {
            return String(format: "%.1f GB", Double(size) / (1024.0 * 1024.0 * 1024.0))
        }
    }

    /// 计算文件或目录大小，单位为字节。
    func getSize() -> Int64 {
        if isFolder {
            return flatten().reduce(Int64(0)) { total, url in
                total + url.getSize()
            }
        }

        let size = (try? resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        return Int64(size)
    }

    /// 创建一个打开当前 URL 的按钮。
    func makeOpenButton() -> some View {
        Button(action: {
            self.open()
        }) {
            Image(systemName: "folder")
        }
        .buttonStyle(.plain)
    }

    /// 获取同级目录中的下一个文件。
    func getNextFile() -> URL? {
        let contents = deletingLastPathComponent().getChildren()
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        guard let index = contents.firstIndex(of: self) else { return nil }
        let nextIndex = index + 1
        return nextIndex < contents.count ? contents[nextIndex] : nil
    }

    /// 获取同级目录中的上一个文件。
    func getPrevFile() -> URL? {
        let contents = deletingLastPathComponent().getChildren()
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        guard let index = contents.firstIndex(of: self) else { return nil }
        return index > 0 ? contents[index - 1] : nil
    }

    /// 检查 URL 是否位于 iCloud Documents 容器中。
    func checkIsICloud(verbose: Bool = false) -> Bool {
        guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents") else {
            return false
        }

        return path.hasPrefix(iCloudURL.path)
    }

    /// Whether the URL is not under iCloud Documents.
    var isLocal: Bool {
        !checkIsICloud(verbose: false)
    }

    /// 检查 iCloud 文件是否正在下载。
    func checkIsDownloading(verbose: Bool = false) -> Bool {
        var mutableSelf = self
        mutableSelf.removeAllCachedResourceValues()

        guard let resources = try? mutableSelf.resourceValues(forKeys: [
            .isUbiquitousItemKey,
            .ubiquitousItemDownloadingStatusKey,
            .ubiquitousItemIsDownloadingKey,
        ]) else {
            return false
        }

        guard resources.isUbiquitousItem == true else {
            return false
        }

        if resources.ubiquitousItemIsDownloading == true {
            return true
        }

        return resources.ubiquitousItemDownloadingStatus?.rawValue == "NSMetadataUbiquitousItemDownloadingStatusDownloading"
    }

    /// 获取 iCloud 文件当前下载进度，范围为 0...1。
    func getDownloadProgressSnapshot(verbose: Bool = false) -> Double {
        var mutableSelf = self
        mutableSelf.removeAllCachedResourceValues()

        if isLocal {
            return 1.0
        }

        let percentKey = URLResourceKey(rawValue: "NSURLUbiquitousItemPercentDownloadedKey")
        guard let resources = try? mutableSelf.resourceValues(forKeys: [
            .fileSizeKey,
            .fileAllocatedSizeKey,
            .ubiquitousItemDownloadingStatusKey,
            .ubiquitousItemIsDownloadingKey,
            percentKey,
        ]) else {
            return 0.0
        }

        if resources.ubiquitousItemDownloadingStatus == .current {
            return 1.0
        }

        if let percent = resources.allValues[percentKey] as? Double, percent > 0 {
            return min(percent / 100.0, 1.0)
        }

        guard let totalSize = resources.fileSize, totalSize > 0,
              let downloadedSize = resources.fileAllocatedSize else {
            return 0.0
        }

        return min(Double(downloadedSize) / Double(totalSize), 1.0)
    }

    /// 将文件夹展开为所有非文件夹子项；普通文件返回自身。
    func flatten() -> [URL] {
        guard isFolder else { return [self] }

        guard let enumerator = FileManager.default.enumerator(
            at: self,
            includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var files: [URL] = []
        for case let url as URL in enumerator {
            if !url.isFolder {
                files.append(url)
            }
        }

        return files
    }

    /// 获取文件夹内的直接子项。
    func getChildren() -> [URL] {
        guard isFolder else { return [] }

        return (try? FileManager.default.contentsOfDirectory(
            at: self,
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        )) ?? []
    }

    /// 递归统计当前 URL 下的文件数量。
    func filesCountRecursively() -> Int {
        guard FileManager.default.fileExists(atPath: path) else {
            return 0
        }

        guard isFolder else {
            return 1
        }

        return flatten().count
    }

    /// 获取本地图片缩略图。
    func thumbnailImage(
        size: CGSize = CGSize(width: 120, height: 120),
        useDefaultIcon: Bool = true,
        verbose: Bool,
        reason: String
    ) async throws -> Image? {
        #if os(macOS)
            if let image = NSImage(contentsOf: self) {
                return Image(nsImage: image)
            }
        #elseif os(iOS)
            if let image = UIImage(contentsOfFile: path) {
                return Image(uiImage: image)
            }
        #endif

        return useDefaultIcon ? Image(systemName: isFolder ? "folder" : "doc") : nil
    }

    /// 自动判断并监听文件夹变化。
    func onDirChange(
        verbose: Bool = true,
        caller: String,
        onChange: @escaping @Sendable (_ files: [URL], _ isInitialFetch: Bool, _ error: Error?) async -> Void,
        onDeleted: @escaping @Sendable (_ urls: [URL]) -> Void = { _ in },
        onProgress: @escaping @Sendable (_ url: URL, _ progress: Double) -> Void = { _, _ in }
    ) -> AnyCancellable {
        if checkIsICloud(verbose: false) {
            let monitor = ICloudDirectoryMonitor(
                directoryURL: self,
                verbose: verbose,
                caller: caller,
                onProgress: onProgress,
                onDeleted: onDeleted
            ) { files, isInitial, error in
                Task {
                    await onChange(files, isInitial, error)
                }
            }

            return monitor.start()
        }

        let monitor = LocalDirectoryMonitor(
            directoryURL: self,
            verbose: verbose,
            caller: caller,
            onChange: onChange
        )

        return monitor.start()
    }
}
