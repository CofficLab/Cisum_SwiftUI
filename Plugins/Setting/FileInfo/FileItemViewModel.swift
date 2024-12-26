import Foundation
import SwiftUI

@MainActor
class FileItemViewModel: ObservableObject {
    static let ignoredFiles = [
        ".DS_Store",
        ".git",
        ".gitignore",
        "Thumbs.db", // Windows 缩略图文件
        ".localized", // macOS 本地化文件
    ]

    @Published private(set) var downloadStatus: FileStatus.DownloadStatus?
    @Published private(set) var subItems: [URL] = []
    @Published var isExpanded: Bool
    @Published private(set) var itemSize: Int64 = 0

    private let statusChecker = DirectoryStatusChecker()
    let url: URL
    let isDirectory: Bool

    init(url: URL, isExpanded: Bool = false) {
        self.url = url
        self.isExpanded = isExpanded

        // 检查是否为目录
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        self.isDirectory = isDir.boolValue

        if isDirectory {
            // 如果是目录，预先加载子项目
            loadSubItems()
        }

        // 异计算大小
        Task {
            await calculateSize()
        }
    }

    private func calculateSize() async {
        let size = await Task.detached(priority: .background) {
            if self.isDirectory {
                return await self.calculateFolderSize(url: self.url)
            } else {
                return Int64((try? self.url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
            }
        }.value

        await MainActor.run {
            self.itemSize = size
        }
    }

    private func calculateFolderSize(url: URL) -> Int64 {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey],
            options: [],
            errorHandler: nil
        ) else { return 0 }

        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if FileItemViewModel.ignoredFiles.contains(fileURL.lastPathComponent) {
                continue
            }

            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey]),
                  let size = resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize
            else { continue }
            totalSize += Int64(size)
        }
        return totalSize
    }

    private func loadSubItems() {
        guard isDirectory else { return }

        do {
            subItems = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: []
            ).filter { url in
                !FileItemViewModel.ignoredFiles.contains(url.lastPathComponent)
            }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        } catch {
            print("Error loading subitems: \(error)")
        }
    }

    func checkStatus() async {
        // 如果是目录，先检查是否只包含被忽略的文件
        if isDirectory {
            let hasNonIgnoredFiles = subItems.contains { url in
                !FileItemViewModel.ignoredFiles.contains(url.lastPathComponent)
            }

            // 如果目录下只有被忽略的文件，则不显示任何状态
            if !hasNonIgnoredFiles {
                await MainActor.run {
                    self.downloadStatus = nil
                }
                return
            }
        }

        // 如果当前文件是被忽略的文件，则不检查状态
        if FileItemViewModel.ignoredFiles.contains(url.lastPathComponent) {
            await MainActor.run {
                self.downloadStatus = nil
            }
            return
        }

        // 继续检查其他文件的状态
        downloadStatus = await statusChecker.checkItemStatus(url) { _, status in
            Task { @MainActor in
                withAnimation {
                    self.downloadStatus = status
                    NotificationCenter.default.post(
                        name: .fileStatusUpdated,
                        object: (self.url.lastPathComponent, status)
                    )
                }
            }
        }
    }
}