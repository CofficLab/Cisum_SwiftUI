import Foundation
import OSLog
import SwiftUI
import Compression

import Compression

// MARK: - Cache Support

private class SizeCacheEntry {
    let size: Int64
    let modificationDate: Date

    init(size: Int64, modificationDate: Date) {
        self.size = size
        self.modificationDate = modificationDate
    }
}

private let fileSizeCache = NSCache<NSString, SizeCacheEntry>()

public extension URL {
    /// 删除指定 URL 对应的文件或目录。
    ///
    /// 此方法从文件系统中删除文件或目录。如果 URL 指向一个目录，
    /// 其所有内容也将被删除。
    ///
    /// - Throws: 如果删除失败或文件没有足够的权限时抛出错误。
    /// - Note: 此操作无法撤消。
    func delete() throws {
        guard FileManager.default.fileExists(atPath: self.path) else {
            return
        }
        try FileManager.default.removeItem(at: self)
    }

    /// 递归返回目录及其子目录中的所有文件。
    ///
    /// - Returns: 包含目录树中所有文件 URL 的数组。
    /// - Note: 此方法会自动过滤掉 .DS_Store 文件。
    func flatten() -> [URL] {
        getAllFilesInDirectory()
    }

    /// 递归返回目录及其子目录中的所有文件。
    ///
    /// - Returns: 包含目录树中所有文件 URL 的数组。
    /// - Note: 此方法会自动过滤掉 .DS_Store 文件。
    /// - Important: 如果无法访问目录，此方法会记录错误。
    func getAllFilesInDirectory() -> [URL] {
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            let urls = try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])

            for url in urls {
                if url.hasDirectoryPath {
                    fileURLs += url.getAllFilesInDirectory()
                } else {
                    fileURLs.append(url)
                }
            }
        } catch {
            os_log(.error, "读取目录时发生错误: \(error.localizedDescription)")
        }

        return fileURLs.filter { $0.lastPathComponent != ".DS_Store" }
    }

    /// 返回当前目录的直接子项（文件和目录）。
    ///
    /// - Returns: 按名称排序的直接子项 URL 数组。
    /// - Note: 此方法会自动过滤掉 .DS_Store 文件。
    func getChildren() -> [URL] {
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            let urls = try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
            fileURLs = urls.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
        } catch {
            os_log(.error, "读取目录时发生错误: \(error)")
        }

        return fileURLs.filter { $0.lastPathComponent != ".DS_Store" }
    }

    /// 返回当前目录的直接文件子项（不包括目录）。
    ///
    /// - Returns: 按名称排序的直接文件子项 URL 数组。
    /// - Note: 此方法会自动过滤掉 .DS_Store 文件。
    func getFileChildren() -> [URL] {
        let fileManager = FileManager.default
        var fileURLs: [URL] = []

        do {
            let urls = try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
            fileURLs = urls.filter { !$0.hasDirectoryPath }
        } catch {
            os_log(.error, "读取目录时发生错误: \(error)")
        }

        return fileURLs
            .filter { $0.lastPathComponent != ".DS_Store" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    /// 返回父目录中的下一个文件。
    ///
    /// - Returns: 下一个文件的 URL，如果是最后一个文件则返回 `nil`。
    /// - Note: 文件按名称字母顺序排序。
    func getNextFile() -> URL? {
        let parent = deletingLastPathComponent()
        let files = parent.getChildren()
        guard let index = files.firstIndex(of: self) else {
            return nil
        }

        return index < files.count - 1 ? files[index + 1] : nil
    }

    /// 返回父目录中的上一个文件。
    ///
    /// - Returns: 上一个文件的 URL，如果是第一个文件则返回 `nil`。
    /// - Note: 文件按名称字母顺序排序。
    func getPrevFile() -> URL? {
        let parent = deletingLastPathComponent()
        let files = parent.getChildren()
        guard let index = files.firstIndex(of: self) else {
            return nil
        }

        return index > 0 ? files[index - 1] : nil
    }

    /// 计算文件或目录的大小（以字节为单位）。
    ///
    /// 对于目录，此方法会递归计算所有包含文件的总大小。
    ///
    /// - Parameter useCache: 是否使用缓存（默认为 true）。如果为 true，会根据文件修改时间检查缓存。
    /// - Returns: 以 Int64 表示的字节大小。
    /// - Note: 如果无法确定大小，则返回 0。
    func getSize(useCache: Bool = true) -> Int64 {
        // 获取当前文件的修改时间
        let currentModificationDate: Date?
        if useCache {
            currentModificationDate = (try? resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
            
            // 尝试从缓存获取
            if let date = currentModificationDate,
               let cached = fileSizeCache.object(forKey: path as NSString),
               cached.modificationDate == date {
                return cached.size
            }
        } else {
            currentModificationDate = nil
        }

        var size: Int64 = 0

        // 如果是文件夹，计算所有子项的大小总和
        if hasDirectoryPath {
            size = getAllFilesInDirectory()
                .reduce(Int64(0)) { $0 + $1.getSize(useCache: useCache) }
        } else {
            // 如果是文件，返回文件大小
            let attributes = try? resourceValues(forKeys: [.fileSizeKey])
            size = Int64(attributes?.fileSize ?? 0)
        }

        // 写入缓存
        if useCache, let date = currentModificationDate {
            fileSizeCache.setObject(SizeCacheEntry(size: size, modificationDate: date), forKey: path as NSString)
        }

        return size
    }

    /// 返回文件或目录大小的人类可读格式。
    ///
    /// 大小会自动转换为最适合的单位（B、KB、MB、GB 或 TB）。
    ///
    /// - Parameters:
    ///   - verbose: 是否输出详细日志
    ///   - useCache: 是否使用缓存（默认为 true）
    /// - Returns: 表示大小的格式化字符串（例如："1.5 MB"）。
    func getSizeReadable(verbose: Bool = false, useCache: Bool = true) -> String {
        if verbose {
            os_log("\(self.t)<\(self.title)>获取文件大小: \(self.path)")
        }

        let size = Double(getSize(useCache: useCache))
        let units = ["B", "KB", "MB", "GB", "TB"]
        var index = 0
        var convertedSize = size

        while convertedSize >= 1024 && index < units.count - 1 {
            convertedSize /= 1024
            index += 1
        }

        return String(format: "%.1f %@", convertedSize, units[index])
    }

    /// 检查 URL 是否指向现有目录。
    var isDirExist: Bool {
        var isDir: ObjCBool = true
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    }

    /// 检查 URL 是否指向现有文件。
    var isFileExist: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    var isNotFileExist: Bool {
        !isFileExist
    }

    var isNotDirExist: Bool {
        !isDirExist
    }

    /// 删除当前文件或目录的父文件夹。
    ///
    /// - Throws: 如果删除失败或文件夹没有足够的权限时抛出错误。
    /// - Important: 此操作无法撤消，并且会删除父文件夹的所有内容。
    func removeParentFolder() throws {
        try FileManager.default.removeItem(at: deletingLastPathComponent())
    }

    /// 根据条件删除当前文件或目录的父文件夹。
    ///
    /// - Parameter condition: 决定是否应删除父文件夹的布尔值。
    /// - Note: 此方法会静默忽略删除过程中发生的任何错误。
    func removeParentFolderWhen(_ condition: Bool) {
        if condition {
            try? removeParentFolder()
        }
    }

    /// 如果 URL 对应的目录或文件不存在则创建它，并返回 URL。
    ///
    /// - 对于目录：创建目录及任何必要的中间目录。
    /// - 对于文件：创建空文件及任何必要的父目录。
    ///
    /// - Returns: 当前 URL（self）
    /// - Throws: 如果创建失败则抛出错误
    @discardableResult
    func createIfNotExist() throws -> URL {
        // 处理父目录
        let parentDir = deletingLastPathComponent()
        if parentDir.isNotDirExist {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }
        
        // 处理当前路径
        if hasDirectoryPath {
            if isNotDirExist {
                try FileManager.default.createDirectory(at: self, withIntermediateDirectories: true)
            }
        } else {
            if isNotFileExist {
                do {
                    try Data().write(to: self)
                } catch {
                    throw error
                }
            }
        }
        
        return self
    }
}

// MARK: - 预览

#if DEBUG
#Preview("File Operations") {
    FileOperationTestView()
}
#endif

private struct FileOperationTestView: View {
    @State private var selectedFile: URL?
    @State private var error: Error?
    @State private var showError = false

    let testDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("FileOperationTest", isDirectory: true)

    var body: some View {
        List {
            Section("文件操作") {
                // 创建测试文件
                Button("创建测试文件") {
                    do {
                        try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)

                        // 创建一些测试文件
                        for i in 1 ... 5 {
                            let fileURL = testDirectory.appendingPathComponent("test\(i).txt")
                            try "Test content \(i)".write(to: fileURL, atomically: true, encoding: .utf8)
                        }

                        // 创建子文件夹
                        let subDir = testDirectory.appendingPathComponent("subdir")
                        try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true)
                        try "Subdir content".write(to: subDir.appendingPathComponent("subfile.txt"), atomically: true, encoding: .utf8)

                    } catch {
                        self.error = error
                        showError = true
                    }
                }

                // 显示文件列表
                if testDirectory.isDirExist {
                    ForEach(testDirectory.getChildren(), id: \.path) { url in
                        FileRow(url: url, selectedFile: $selectedFile)
                    }
                }

                // 清理测试文件
                Button("清理测试文件", role: .destructive) {
                    try? testDirectory.delete()
                }
            }

            if let selectedFile = selectedFile {
                Section("文件信息") {
                    Text("大小: \(selectedFile.getSizeReadable())")
                    Text("上级目录: \(selectedFile.deletingLastPathComponent().path)")
                    if let prev = selectedFile.getPrevFile() {
                        Text("上一个: \(prev.lastPathComponent)")
                    }
                    if let next = selectedFile.getNextFile() {
                        Text("下一个: \(next.lastPathComponent)")
                    }
                }

                Section("操作") {
                    #if os(macOS)
                        Button("在访达中显示") {
                            selectedFile.showInFinder()
                        }
                    #endif

                    Button("打开文件夹") {
                        selectedFile.openFolder()
                    }

                    Button("删除", role: .destructive) {
                        try? selectedFile.delete()
                        self.selectedFile = nil
                    }
                }
            }
        }
        .alert("错误", isPresented: $showError, presenting: error) { _ in
            Button("确定") {}
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}

private struct FileRow: View {
    let url: URL
    @Binding var selectedFile: URL?

    var body: some View {
        HStack {
            Image(systemName: url.hasDirectoryPath ? "folder" : "doc")

            VStack(alignment: .leading) {
                Text(url.lastPathComponent)
                Text(url.getSizeReadable())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedFile = url
        }
    }
}
