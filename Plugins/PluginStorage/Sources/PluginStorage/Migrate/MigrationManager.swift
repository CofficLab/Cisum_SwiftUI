import Foundation
import MagicKit
import OSLog

typealias ProgressCallback = (Double, String) -> Void
typealias DownloadProgressCallback = (String, FileStatus.DownloadStatus) -> Void

class MigrationManager: ObservableObject, SuperLog, SuperThread, @unchecked Sendable {
    static let emoji: String = "👵"

    private let cancellationLock = NSLock()
    private var cancellationRequested = false

    var isCancelled: Bool {
        cancellationLock.lock()
        let value = cancellationRequested
        cancellationLock.unlock()
        return value
    }

    func cancelMigration() {
        cancellationLock.lock()
        cancellationRequested = true
        cancellationLock.unlock()
    }

    func resetCancellation() {
        cancellationLock.lock()
        cancellationRequested = false
        cancellationLock.unlock()
    }

    func migrate(
        from sourceRoot: URL,
        to targetRoot: URL,
        progressCallback: ProgressCallback?,
        downloadProgressCallback: DownloadProgressCallback?,
        verbose: Bool
    ) throws {
        os_log(.info, "\(self.t)开始迁移任务")

        do {
            if Self.resolvedStandardizedPath(for: sourceRoot) == Self.resolvedStandardizedPath(for: targetRoot) {
                progressCallback?(1.0, "")
                os_log(.info, "\(self.t)源目录与目标目录相同，跳过迁移")
                return
            }
            guard !Self.isTargetNestedInSource(sourceRoot: sourceRoot, targetRoot: targetRoot) else {
                throw MigrationError.fileOperationFailed("目标文件夹不能位于源文件夹内")
            }

            // 获取所有文件并过滤掉 .DS_Store
            var files = try FileManager.default.contentsOfDirectory(
                at: sourceRoot,
                includingPropertiesForKeys: nil
            ).filter { $0.lastPathComponent != ".DS_Store" }

            files.sort { $0.lastPathComponent < $1.lastPathComponent }
            os_log(.info, "\(self.t)找到 \(files.count) 个待迁移文件（已排除 .DS_Store）")

            try FileManager.default.createDirectory(
                at: targetRoot,
                withIntermediateDirectories: true
            )
            os_log(.info, "\(self.t)已创建目标目录")

            guard !files.isEmpty else {
                progressCallback?(1.0, "")
                os_log(.info, "\(self.t)源目录为空，迁移完成")
                return
            }

            for (index, sourceFile) in files.enumerated() {
                if self.isCancelled {
                    os_log(.info, "\(self.t)迁移任务被取消")
                    throw MigrationError.migrationCancelled
                }

                let fileName = sourceFile.lastPathComponent

                os_log(.info, "\(self.t)开始迁移文件: \(fileName) (\(index + 1)/\(files.count))")

                progressCallback?(Double(index) / Double(files.count), fileName)

                if self.isCancelled {
                    os_log(.info, "\(self.t)迁移任务被取消")
                    throw MigrationError.migrationCancelled
                }

                try prepareForMigration(
                    sourceFile,
                    downloadProgressCallback: downloadProgressCallback
                )

                if self.isCancelled {
                    os_log(.info, "\(self.t)迁移任务被取消")
                    throw MigrationError.migrationCancelled
                }

                let targetFile = uniqueDestination(for: sourceFile, in: targetRoot)
                do {
                    try migrateItem(from: sourceFile, to: targetFile)
                    os_log(.info, "\(self.t)成功迁移: \(fileName) -> \(targetFile.lastPathComponent)")
                    progressCallback?(Double(index + 1) / Double(files.count), fileName)
                } catch {
                    os_log(.error, "\(self.t)迁移失败: \(fileName) - \(error.localizedDescription)")
                    throw MigrationError.fileOperationFailed("\(fileName): \(error.localizedDescription)")
                }
            }

            if self.isCancelled {
                os_log(.info, "\(self.t)迁移任务被取消")
                throw MigrationError.migrationCancelled
            }

            os_log(.info, "\(self.t)保留源目录")
            os_log(.info, "\(self.t)迁移完成，共处理 \(files.count) 个文件")
        } catch {
            os_log(.error, "\(self.t)迁移错误: \(error.localizedDescription)")
            if let migrationError = error as? MigrationError {
                throw migrationError
            } else {
                throw MigrationError.fileOperationFailed(error.localizedDescription)
            }
        }

        os_log(.info, "\(self.t)迁移任务结束")
    }

    static func isTargetNestedInSource(sourceRoot: URL, targetRoot: URL) -> Bool {
        let sourcePath = resolvedStandardizedPath(for: sourceRoot)
        let targetPath = resolvedStandardizedPath(for: targetRoot)

        return targetPath != sourcePath && targetPath.hasPrefix(childPrefix(for: sourcePath))
    }

    private static func resolvedStandardizedPath(for url: URL) -> String {
        let fileManager = FileManager.default
        var existingAncestor = url
        var missingComponents: [String] = []

        while !fileManager.fileExists(atPath: existingAncestor.path),
              existingAncestor.path != existingAncestor.deletingLastPathComponent().path {
            missingComponents.insert(existingAncestor.lastPathComponent, at: 0)
            existingAncestor.deleteLastPathComponent()
        }

        var resolvedURL = existingAncestor.resolvingSymlinksInPath().standardizedFileURL
        for component in missingComponents {
            resolvedURL.appendPathComponent(component)
        }

        return resolvedURL.standardizedFileURL.path
    }

    private static func childPrefix(for parentPath: String) -> String {
        parentPath.hasSuffix("/") ? parentPath : parentPath + "/"
    }

    private func prepareForMigration(
        _ sourceFile: URL,
        downloadProgressCallback: DownloadProgressCallback?
    ) throws {
        if sourceFile.isFolder {
            for child in sourceFile.flatten() {
                try ensureLocalAvailability(
                    for: child,
                    displayName: sourceFile.lastPathComponent,
                    downloadProgressCallback: downloadProgressCallback
                )
            }
        } else {
            try ensureLocalAvailability(
                for: sourceFile,
                displayName: sourceFile.lastPathComponent,
                downloadProgressCallback: downloadProgressCallback
            )
        }
    }

    private func ensureLocalAvailability(
        for url: URL,
        displayName: String,
        downloadProgressCallback: DownloadProgressCallback?
    ) throws {
        downloadProgressCallback?(displayName, .downloading(progress: url.getDownloadProgressSnapshot()))
        try url.ensureLocalAvailabilitySync()
        downloadProgressCallback?(displayName, .local)
    }

    private func migrateItem(from sourceFile: URL, to targetFile: URL) throws {
        let resolvedSource = sourceFile.resolvingSymlinksInPath().standardizedFileURL
        let standardizedSource = sourceFile.standardizedFileURL

        guard Self.representsSymlink(sourceFile),
              FileManager.default.fileExists(atPath: resolvedSource.path),
              resolvedSource.path != standardizedSource.path else {
            try FileManager.default.moveItem(at: sourceFile, to: targetFile)
            return
        }

        try FileManager.default.copyItem(at: resolvedSource, to: targetFile)
        try FileManager.default.removeItem(at: sourceFile)
    }

    private static func representsSymlink(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true
    }

    private func uniqueDestination(for sourceFile: URL, in targetRoot: URL) -> URL {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: sourceFile.path, isDirectory: &isDirectory)

        let sourceIsDirectory = isDirectory.boolValue
        let pathExtension = sourceIsDirectory ? "" : sourceFile.pathExtension
        let rawBaseName = sourceIsDirectory
            ? sourceFile.lastPathComponent
            : sourceFile.deletingPathExtension().lastPathComponent
        let baseName = rawBaseName.isEmpty ? "Migrated Item" : rawBaseName

        var candidate = destination(
            named: baseName,
            pathExtension: pathExtension,
            in: targetRoot,
            isDirectory: sourceIsDirectory
        )
        var suffix = 2

        while Self.pathExistsIncludingSymlink(candidate) {
            candidate = destination(
                named: "\(baseName) \(suffix)",
                pathExtension: pathExtension,
                in: targetRoot,
                isDirectory: sourceIsDirectory
            )
            suffix += 1
        }

        return candidate
    }

    private static func pathExistsIncludingSymlink(_ url: URL) -> Bool {
        if FileManager.default.fileExists(atPath: url.path) {
            return true
        }

        return (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true
    }

    private func destination(
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
