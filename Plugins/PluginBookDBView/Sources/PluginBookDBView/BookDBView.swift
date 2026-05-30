import Foundation
import MagicKit
import OSLog
import PluginBook
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

public struct BookDBView: View, SuperLog, SuperThread {
    public nonisolated static let emoji = "🐘"
    public nonisolated static let verbose = false
    
    @Environment(\.bookDBViewDependencies) private var dependencies
    @EnvironmentObject private var repo: BookRepo
    @State private var isImporting = false
    @State private var isDropping = false
    @State var treeView = false
    
    /// 是否正在拖拽文件
    var dropping: Bool { isDropping }
    
    /// 是否使用列表视图，默认为网格视图
    private var useListView = false

    public init() {}

    public var body: some View {
        if Self.verbose {
            os_log("\(self.t)📺 开始渲染")
        }
        return VStack(spacing: 0) {
            if useListView {
                BookList()
            } else {
                BookGrid()
            }
        }
        .environment(\.bookDBImportAction, {
            isImporting = true
        })
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.folder, .audio],
            allowsMultipleSelection: true,
            onCompletion: handleFileImport
        )
        .onDrop(of: [UTType.fileURL], isTargeted: $isDropping, perform: handleDrop)
        .onAppear(perform: handleOnAppear)
    }
}

private final class DroppedFileCollector: @unchecked Sendable {
    private let lock = NSLock()
    private var files: [URL] = []

    func append(_ url: URL) {
        lock.lock()
        files.append(url)
        lock.unlock()
    }

    func snapshot() -> [URL] {
        lock.lock()
        let files = files
        lock.unlock()
        return files
    }
}

// MARK: - Action

extension BookDBView {
    /// 复制文件到仓库
    ///
    /// 将选中或拖拽的文件复制到书籍仓库中。
    ///
    /// - Parameter files: 要复制的文件 URL 数组
    func copy(_ files: [URL]) {
        if Self.verbose {
            os_log("\(self.t)📂 准备复制 \(files.count) 个文件")
        }

        guard let bookDisk = dependencies.bookDisk else {
            os_log(.error, "\(self.t)❌ 书籍仓库目录不可用")
            return
        }

        Task {
            do {
                let copiedItems = try await Task.detached(priority: .userInitiated) {
                    try Self.copyImportedItems(files, to: bookDisk)
                }.value
                await repo.syncImportedItems(copiedItems)
            } catch {
                os_log(.error, "\(self.t)❌ 复制书籍文件失败: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Import Helpers

extension BookDBView {
    private nonisolated static func copyImportedItems(_ files: [URL], to bookDisk: URL) throws -> [URL] {
        try FileManager.default.createDirectory(at: bookDisk, withIntermediateDirectories: true)

        let folders = files.filter(\.isFolder)
        let audioFiles = files.filter { url in
            !url.isFolder && BookPluginInfo.supportedExtensions.contains(url.pathExtension.lowercased())
        }
        var copiedItems: [URL] = []

        for folder in folders {
            let destination = uniqueDestination(for: folder, in: bookDisk)
            try copySecurityScopedItem(folder, to: destination)
            copiedItems.append(destination)
        }

        guard !audioFiles.isEmpty else { return copiedItems }

        let collectionName = audioFiles.count == 1 ? audioFiles[0].title : collectionTitle(for: audioFiles)
        let collectionURL = uniqueDestination(named: collectionName, in: bookDisk, isDirectory: true)
        try FileManager.default.createDirectory(at: collectionURL, withIntermediateDirectories: true)
        copiedItems.append(collectionURL)

        for file in audioFiles {
            let destination = uniqueDestination(for: file, in: collectionURL)
            try copySecurityScopedItem(file, to: destination)
            copiedItems.append(destination)
        }

        return copiedItems
    }

    private nonisolated static func copySecurityScopedItem(_ source: URL, to destination: URL) throws {
        let hasAccess = source.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                source.stopAccessingSecurityScopedResource()
            }
        }

        try FileManager.default.copyItem(at: source, to: destination)
    }

    private nonisolated static func collectionTitle(for files: [URL]) -> String {
        let parents = Set(files.map { $0.deletingLastPathComponent() })
        guard parents.count == 1, let parent = parents.first, !parent.lastPathComponent.isEmpty else {
            return "Imported Audiobook"
        }
        return parent.lastPathComponent
    }

    private nonisolated static func uniqueDestination(for source: URL, in directory: URL) -> URL {
        uniqueDestination(
            named: source.deletingPathExtension().lastPathComponent,
            pathExtension: source.pathExtension,
            in: directory,
            isDirectory: source.isFolder
        )
    }

    private nonisolated static func uniqueDestination(
        named name: String,
        pathExtension: String = "",
        in directory: URL,
        isDirectory: Bool
    ) -> URL {
        let baseName = name.isEmpty ? "Imported Audiobook" : name
        var candidate = destination(
            named: baseName,
            pathExtension: pathExtension,
            in: directory,
            isDirectory: isDirectory
        )
        var suffix = 2

        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = destination(
                named: "\(baseName) \(suffix)",
                pathExtension: pathExtension,
                in: directory,
                isDirectory: isDirectory
            )
            suffix += 1
        }

        return candidate
    }

    private nonisolated static func destination(
        named name: String,
        pathExtension: String,
        in directory: URL,
        isDirectory: Bool
    ) -> URL {
        let destination = directory.appendingPathComponent(name, isDirectory: isDirectory)
        guard !pathExtension.isEmpty else {
            return destination
        }

        return destination.appendingPathExtension(pathExtension)
    }
}

// MARK: - Event Handler

extension BookDBView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现在屏幕上时触发，用于执行初始化操作。
    func handleOnAppear() {
        if Self.verbose {
            os_log("\(self.t)👀 视图已出现")
        }
        
        // TODO: 可以在这里执行初始化逻辑，例如：
        // - 检查数据完整性
        // - 加载缓存数据
        // - 更新统计信息
    }
    
    /// 处理文件导入结果
    ///
    /// 当用户通过文件选择器导入文件后触发。
    ///
    /// - Parameter result: 文件导入的结果，包含选中的文件 URL 或错误信息
    func handleFileImport(_ result: Result<[URL], Error>) {
        if Self.verbose {
            os_log("\(self.t)📥 处理文件导入")
        }
        
        switch result {
        case let .success(urls):
            if Self.verbose {
                os_log("\(self.t)✅ 成功导入 \(urls.count) 个文件")
            }
            copy(urls)
            
        case let .failure(error):
            os_log(.error, "\(self.t)❌ 导入文件失败: \(error.localizedDescription)")
        }
    }
    
    
    /// 处理文件拖拽事件
    ///
    /// 当用户拖拽文件到视图上时触发，异步加载所有拖拽的文件 URL 并复制。
    ///
    /// ## 处理流程
    /// 1. 创建 DispatchGroup 协调所有异步加载
    /// 2. 遍历所有 provider，异步加载文件 URL
    /// 3. 收集所有成功加载的文件
    /// 4. 在主线程调用 copy 方法批量复制
    ///
    /// - Parameter providers: 拖拽提供者数组，每个包含一个文件引用
    /// - Returns: 始终返回 `true` 表示接受拖拽
    func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        if Self.verbose {
            os_log("\(self.t)🎯 处理文件拖拽，提供者数量: \(providers.count)")
        }
        
        let dispatchGroup = DispatchGroup()
        let droppedFiles = DroppedFileCollector()
        
        for provider in providers {
            dispatchGroup.enter()
            
            // 异步加载文件对象
            _ = provider.loadObject(ofClass: URL.self) { object, error in
                defer { dispatchGroup.leave() }
                
                if let url = object {
                    if Self.verbose {
                        os_log("\(self.t)📎 添加 \(url.lastPathComponent) 到复制队列")
                    }
                    droppedFiles.append(url)
                } else if let error = error {
                    os_log(.error, "\(self.t)⚠️ 加载文件失败: \(error.localizedDescription)")
                }
            }
        }
        
        // 所有文件加载完成后，在主线程执行复制
        dispatchGroup.notify(queue: .main) {
            if Self.verbose {
                os_log("\(self.t)✅ 所有文件加载完成，开始复制")
            }
            copy(droppedFiles.snapshot())
        }
        
        return true
    }
}

// MARK: - Preview

#if os(macOS)

#endif
