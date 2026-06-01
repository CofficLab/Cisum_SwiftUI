import Foundation
import MagicAlert
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
    @State private var isFileImporterPresented = false
    @State private var isImportingFiles = false
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
            isFileImporterPresented = true
        })
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.folder, .audio],
            allowsMultipleSelection: true,
            onCompletion: handleFileImport
        )
        .onDrop(of: [UTType.fileURL], isTargeted: $isDropping, perform: handleDrop)
        .onAppear(perform: handleOnAppear)
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

        let importSources = Self.importableSourceCandidates(files)

        guard !importSources.isEmpty else {
            alert_error(String(localized: "No files were added", table: "Book-DBView", bundle: .module))
            return
        }

        guard let bookDisk = dependencies.bookDisk else {
            os_log(.error, "\(self.t)❌ 书籍仓库目录不可用")
            alert_error(String(localized: "Storage location is unavailable", table: "Book-DBView", bundle: .module))
            return
        }

        guard Self.shouldStartImport(isImporting: isImportingFiles) else {
            alert_warning(String(localized: "Import is already in progress", table: "Book-DBView", bundle: .module))
            return
        }

        isImportingFiles = true
        Task {
            defer {
                isImportingFiles = false
            }

            var copiedItems: [URL] = []
            do {
                copiedItems = try await Task.detached(priority: .userInitiated) {
                    try await Self.copyImportedItems(importSources, to: bookDisk)
                }.value
                guard !copiedItems.isEmpty else {
                    alert_error(String(localized: "No files were added", table: "Book-DBView", bundle: .module))
                    return
                }

                try await repo.syncImportedItems(copiedItems)
            } catch {
                Self.cleanUpCopiedItems(copiedItems)
                os_log(.error, "\(self.t)❌ 复制书籍文件失败: \(error.localizedDescription)")
                await MainActor.run {
                    alert_error(String(localized: "Import failed: \(error.localizedDescription)", table: "Book-DBView", bundle: .module))
                }
            }
        }
    }
}

// MARK: - Import Helpers

extension BookDBView {
    nonisolated static func copyImportedItems(_ files: [URL], to bookDisk: URL) async throws -> [URL] {
        try FileManager.default.createDirectory(at: bookDisk, withIntermediateDirectories: true)

        let importSources = uniqueImportSources(files)
        let folders = importSources.filter(Self.isFolderLikeImportSource)
        let audioFiles = importSources.filter { url in
            !Self.isFolderLikeImportSource(url) && BookPluginInfo.supportedExtensions.contains(url.pathExtension.lowercased())
        }
        var copiedItems: [URL] = []

        do {
            for folder in folders {
                guard try canImportFolder(folder) else { continue }

                let destination = uniqueDestination(for: folder, in: bookDisk)
                let sourceToCopy = copySourceURL(for: folder)
                guard !isDestinationNestedInSource(source: sourceToCopy, destination: destination) else {
                    throw NSError(
                        domain: "BookDBView",
                        code: 2,
                        userInfo: [
                            NSLocalizedDescriptionKey: String(localized: "Import destination cannot be inside the original folder", table: "Book-DBView", bundle: .module)
                        ]
                    )
                }
                try await copySecurityScopedItem(folder, to: destination)
                copiedItems.append(destination)
            }

            guard !audioFiles.isEmpty else { return copiedItems }

            let collectionName = audioFiles.count == 1 ? audioFiles[0].title : collectionTitle(for: audioFiles)
            let collectionURL = uniqueDestination(named: collectionName, in: bookDisk, isDirectory: true)
            try FileManager.default.createDirectory(at: collectionURL, withIntermediateDirectories: true)
            copiedItems.append(collectionURL)

            for file in audioFiles {
                let destination = uniqueDestination(for: file, in: collectionURL)
                try await copySecurityScopedItem(file, to: destination)
            }
        } catch {
            for copiedItem in copiedItems {
                try? FileManager.default.removeItem(at: copiedItem)
            }
            throw error
        }

        return copiedItems
    }

    nonisolated static func importableSourceCandidates(_ urls: [URL]) -> [URL] {
        uniqueImportSources(urls).filter { url in
            isFolderLikeImportSource(url)
                || BookPluginInfo.supportedExtensions.contains(url.pathExtension.lowercased())
        }
    }

    nonisolated static func cleanUpCopiedItems(_ urls: [URL]) {
        for url in urls {
            try? FileManager.default.removeItem(at: url)
        }
    }

    nonisolated static func droppedFileURL(from provider: NSItemProvider) async throws -> URL? {
        var fileURLDataError: Error?

        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            do {
                let data: Data? = try await withCheckedThrowingContinuation { continuation in
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: data)
                        }
                    }
                }

                if let data, let url = URL(dataRepresentation: data, relativeTo: nil), url.isFileURL {
                    return url
                }
            } catch {
                fileURLDataError = error
            }
        }

        if let url = try await droppedURLObject(from: provider) {
            return url
        }

        if let fileURLDataError {
            throw fileURLDataError
        }

        return nil
    }

    nonisolated private static func droppedURLObject(from provider: NSItemProvider) async throws -> URL? {
        guard provider.canLoadObject(ofClass: URL.self) else { return nil }

        return try await withCheckedThrowingContinuation { continuation in
            _ = provider.loadObject(ofClass: URL.self) { object, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: object)
                }
            }
        }
    }

    nonisolated static func droppedFileURLs(from providers: [NSItemProvider]) async -> (urls: [URL], errors: [Error]) {
        var urls: [URL] = []
        var errors: [Error] = []

        for provider in providers {
            do {
                if let url = try await droppedFileURL(from: provider) {
                    urls.append(url)
                }
            } catch {
                errors.append(error)
            }
        }

        return (urls, errors)
    }

    nonisolated static func shouldImportDroppedURLs(_ urls: [URL], after errors: [Error]) -> Bool {
        !urls.isEmpty
    }

    nonisolated static func shouldReportDroppedURLLoadFailure(_ urls: [URL], errors: [Error]) -> Bool {
        urls.isEmpty && !errors.isEmpty
    }

    nonisolated static func shouldStartImport(isImporting: Bool) -> Bool {
        !isImporting
    }

    nonisolated static func uniqueImportSources(_ urls: [URL]) -> [URL] {
        var seenIdentities = Set<String>()
        var uniqueURLs: [URL] = []
        uniqueURLs.reserveCapacity(urls.count)

        for url in urls {
            let identity = canonicalImportSourceIdentity(for: url)
            guard seenIdentities.insert(identity).inserted else {
                continue
            }

            uniqueURLs.append(url)
        }

        return uniqueURLs.filter { source in
            !isNestedInSelectedFolder(source, selectedSources: uniqueURLs)
        }
    }

    private nonisolated static func isNestedInSelectedFolder(_ source: URL, selectedSources: [URL]) -> Bool {
        selectedSources.contains { candidate in
            guard candidate != source, isFolderLikeImportSource(candidate) else {
                return false
            }

            return isDestinationNestedInSource(source: candidate, destination: source)
        }
    }

    nonisolated static func representsSameImportSource(_ lhs: URL, _ rhs: URL) -> Bool {
        canonicalImportSourceIdentity(for: lhs) == canonicalImportSourceIdentity(for: rhs)
    }

    nonisolated static func canonicalImportSourceIdentity(for url: URL) -> String {
        guard url.isFileURL else {
            return url.standardized.absoluteString
        }

        return resolvedStandardizedPath(for: url)
    }

    nonisolated static func isDestinationNestedInSource(source: URL, destination: URL) -> Bool {
        let sourcePath = resolvedStandardizedPath(for: source)
        let destinationPath = resolvedStandardizedPath(for: destination)

        return destinationPath != sourcePath && destinationPath.hasPrefix(childPrefix(for: sourcePath))
    }

    private nonisolated static func resolvedStandardizedPath(for url: URL) -> String {
        let standardizedURL = url.standardizedFileURL
        guard !FileManager.default.fileExists(atPath: standardizedURL.path) else {
            return standardizedURL.resolvingSymlinksInPath().standardizedFileURL.path
        }

        var candidate = standardizedURL
        var missingComponents: [String] = []
        while !FileManager.default.fileExists(atPath: candidate.path) {
            let parent = candidate.deletingLastPathComponent()
            guard parent.path != candidate.path else {
                return standardizedURL.resolvingSymlinksInPath().standardizedFileURL.path
            }
            missingComponents.insert(candidate.lastPathComponent, at: 0)
            candidate = parent
        }

        var resolvedURL = candidate.resolvingSymlinksInPath().standardizedFileURL
        for component in missingComponents {
            resolvedURL.appendPathComponent(component)
        }
        return resolvedURL.standardizedFileURL.path
    }

    private nonisolated static func childPrefix(for parentPath: String) -> String {
        parentPath.hasSuffix("/") ? parentPath : parentPath + "/"
    }

    nonisolated static func hasImportSourceAccess(_ source: URL, securityScopeGranted: Bool) -> Bool {
        securityScopeGranted || FileManager.default.isReadableFile(atPath: source.path)
    }

    nonisolated static func isFolderLikeImportSource(_ source: URL) -> Bool {
        source.isFolder || resolvedDirectoryURL(for: source) != nil
    }

    private nonisolated static func resolvedDirectoryURL(for source: URL) -> URL? {
        let resolvedURL = source.resolvingSymlinksInPath().standardizedFileURL
        return resolvedURL.isFolder ? resolvedURL : nil
    }

    private nonisolated static func copySourceURL(for source: URL) -> URL {
        if source.isFolder {
            return source
        }

        if let resolvedDirectory = resolvedDirectoryURL(for: source) {
            return resolvedDirectory
        }

        let resolvedSource = source.resolvingSymlinksInPath().standardizedFileURL
        guard FileManager.default.fileExists(atPath: resolvedSource.path) else {
            return source
        }

        return resolvedSource
    }

    private nonisolated static func canImportFolder(_ folder: URL) throws -> Bool {
        let hasAccess = folder.startAccessingSecurityScopedResource()
        guard hasImportSourceAccess(folder, securityScopeGranted: hasAccess) else {
            throw NSError(
                domain: "BookDBView",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: String(localized: "Permission to access the original file was denied", table: "Book-DBView", bundle: .module)
                ]
            )
        }

        defer {
            if hasAccess {
                folder.stopAccessingSecurityScopedResource()
            }
        }

        return folderContainsPlayableFiles(folder)
    }

    nonisolated static func folderContainsPlayableFiles(_ folder: URL) -> Bool {
        let source = copySourceURL(for: folder)
        for child in fileDescendants(of: source) {
            if isPlayableBookFile(child) {
                return true
            }
        }

        return false
    }

    private nonisolated static func isPlayableBookFile(_ url: URL) -> Bool {
        BookPluginInfo.supportedExtensions.contains(url.pathExtension.lowercased())
    }

    private nonisolated static func fileDescendants(of folder: URL) -> AnySequence<URL> {
        guard let enumerator = FileManager.default.enumerator(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return AnySequence([])
        }

        return AnySequence {
            AnyIterator {
                while let url = enumerator.nextObject() as? URL {
                    if !url.isFolder {
                        return url
                    }
                }

                return nil
            }
        }
    }

    private nonisolated static func copySecurityScopedItem(_ source: URL, to destination: URL) async throws {
        let hasAccess = source.startAccessingSecurityScopedResource()
        guard hasImportSourceAccess(source, securityScopeGranted: hasAccess) else {
            throw NSError(
                domain: "BookDBView",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: String(localized: "Permission to access the original file was denied", table: "Book-DBView", bundle: .module)
                ]
            )
        }

        defer {
            if hasAccess {
                source.stopAccessingSecurityScopedResource()
            }
        }

        let sourceToCopy = copySourceURL(for: source)
        if sourceToCopy.isFolder {
            for child in fileDescendants(of: sourceToCopy) {
                try await child.ensureLocalAvailability()
            }
        } else {
            try await sourceToCopy.ensureLocalAvailability()
        }

        try FileManager.default.copyItem(at: sourceToCopy, to: destination)
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
            pathExtension: isFolderLikeImportSource(source) ? "" : source.pathExtension,
            in: directory,
            isDirectory: isFolderLikeImportSource(source)
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

        while pathExistsIncludingSymlink(candidate) {
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

    private nonisolated static func pathExistsIncludingSymlink(_ url: URL) -> Bool {
        if FileManager.default.fileExists(atPath: url.path) {
            return true
        }

        return (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true
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
            alert_error(String(localized: "Import failed: \(error.localizedDescription)", table: "Book-DBView", bundle: .module))
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

        Task {
            let droppedFiles = await Self.droppedFileURLs(from: providers)

            if Self.shouldReportDroppedURLLoadFailure(droppedFiles.urls, errors: droppedFiles.errors),
               let error = droppedFiles.errors.first {
                os_log(.error, "\(self.t)⚠️ 加载文件失败: \(error.localizedDescription)")
                alert_error(String(localized: "Import failed: \(error.localizedDescription)", table: "Book-DBView", bundle: .module))
            }

            guard Self.shouldImportDroppedURLs(droppedFiles.urls, after: droppedFiles.errors) else {
                return
            }

            copy(droppedFiles.urls)
        }
        
        return true
    }
}

// MARK: - Preview

#if os(macOS)

#endif
