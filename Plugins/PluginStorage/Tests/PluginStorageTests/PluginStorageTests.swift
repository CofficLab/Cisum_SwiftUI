import Testing
@testable import PluginStorage
import Foundation

@Test func storagePluginInfoIsExposed() {
    #expect(StoragePluginInfo.titleKey == "Storage Settings")
    #expect(PluginStorageLocation.local.rawValue == "local")
    #expect(StoragePlugin.shouldRegister)
}

@Test func fileItemReportsDirectoryReadFailures() {
    let missingDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let item = FileItem(url: missingDirectory, level: 0, isExpanded: true)

    #expect(throws: Error.self) {
        _ = try item.children()
    }
}

@Test func fileListOnlyAppliesLatestVisibleItemsUpdate() {
    #expect(FileListUpdatePolicy.shouldApplyResult(
        currentGeneration: 2,
        resultGeneration: 2
    ))
    #expect(!FileListUpdatePolicy.shouldApplyResult(
        currentGeneration: 2,
        resultGeneration: 1
    ))
}

@Test func fileListRefreshesDirectoryCacheWhenExpandedAgain() {
    let folder = URL(fileURLWithPath: "/tmp/cisum-storage-file-list", isDirectory: true)
    let child = folder.appendingPathComponent("old.mp3")
    let cachedItems = [
        folder: [
            FileItem(url: child, level: 1, isExpanded: false)
        ]
    ]

    #expect(FileListView.cacheAfterExpansionChange(
        isExpanded: true,
        itemURL: folder,
        currentCache: cachedItems
    )[folder] == nil)

    #expect(FileListView.cacheAfterExpansionChange(
        isExpanded: false,
        itemURL: folder,
        currentCache: cachedItems
    )[folder] == cachedItems[folder])
}

@Test func fileInfoCellsOnlyApplyCurrentURLResults() {
    let first = URL(fileURLWithPath: "/tmp/cisum-storage-file-info/first")
    let second = URL(fileURLWithPath: "/tmp/cisum-storage-file-info/second")

    #expect(FileInfoCellLoadPolicy.shouldApplyResult(currentURL: first, requestedURL: first))
    #expect(!FileInfoCellLoadPolicy.shouldApplyResult(currentURL: second, requestedURL: first))
}

@Test func fileInfoCellsApplySymlinkedCurrentURLResults() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realFile = root.appendingPathComponent("real.mp3")
    let linkedFile = root.appendingPathComponent("linked.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    #expect(FileInfoCellLoadPolicy.shouldApplyResult(
        currentURL: realFile,
        requestedURL: linkedFile
    ))
}

@Test func fileSizeReadPolicyReadsFoundationNumberAttributes() {
    #expect(FileSizeReadPolicy.fileSize(from: [.size: NSNumber(value: 1234)]) == 1234)
    #expect(FileSizeReadPolicy.fileSize(from: [.size: Int64(5678)]) == 5678)
    #expect(FileSizeReadPolicy.fileSize(from: [:]) == 0)
}

@Test func fileStatusReportsMissingLocalFiles() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let existingFile = root.appendingPathComponent("track.mp3")
    let missingFile = root.appendingPathComponent("missing.mp3")
    let danglingLink = root.appendingPathComponent("dangling.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: existingFile)
    try FileManager.default.createSymbolicLink(
        at: danglingLink,
        withDestinationURL: root.appendingPathComponent("deleted-target.mp3")
    )

    #expect(FileStatusColumnView.resolveStatus(for: existingFile, verbose: false).status == "本地文件")
    #expect(FileStatusColumnView.resolveStatus(for: missingFile, verbose: false).status == "不存在")
    #expect(FileStatusColumnView.resolveStatus(for: danglingLink, verbose: false).status == "本地文件")
}

@Test func repositoryInfoOnlyOpensExistingLocalPaths() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let missingRoot = root.appendingPathComponent("missing", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    #expect(RepositoryInfoActionPolicy.canOpenInFinder(root))
    #expect(!RepositoryInfoActionPolicy.canOpenInFinder(missingRoot))
    #expect(!RepositoryInfoActionPolicy.canOpenInFinder(nil))
    #expect(RepositoryInfoActionPolicy.canOpenInFinder(URL(string: "https://example.com")!))
}

@Test func directStorageSwitchUsesAccurateCompletionMessage() {
    #expect(MigrationProgressView.completionMessage(shouldMigrate: true) == "迁移已完成")
    #expect(MigrationProgressView.completionMessage(shouldMigrate: false) == "已切换到新位置")
}

@Test func storageSettingsClearsDisplayedSelectionAfterReset() {
    #expect(StorageSettingView.targetLocationAfterStorageUpdate(
        currentTarget: .icloud,
        storageLocation: .local
    ) == .local)
    #expect(StorageSettingView.targetLocationAfterStorageUpdate(
        currentTarget: .icloud,
        storageLocation: nil
    ) == .icloud)
    #expect(!StorageSettingView.hasSelectionChanges(
        targetLocation: .icloud,
        storageLocation: nil
    ))
    #expect(StorageSettingView.hasSelectionChanges(
        targetLocation: .icloud,
        storageLocation: .local
    ))
    #expect(!StorageSettingView.hasSelectionChanges(
        targetLocation: .local,
        storageLocation: .local
    ))
}

@Test func migrationProgressOnlyAppliesCurrentGenerationUpdates() {
    #expect(MigrationProgressView.shouldApplyMigrationUpdate(
        currentGeneration: 2,
        updateGeneration: 2
    ))
    #expect(!MigrationProgressView.shouldApplyMigrationUpdate(
        currentGeneration: 3,
        updateGeneration: 2
    ))
}

@Test func migrationSheetOnlyDisablesDismissWhileRunning() {
    #expect(!MigrationProgressView.shouldDisableInteractiveDismiss(
        showConfirmation: true,
        migrationCompleted: false,
        migrationCancelled: false,
        errorMessage: nil
    ))
    #expect(MigrationProgressView.shouldDisableInteractiveDismiss(
        showConfirmation: false,
        migrationCompleted: false,
        migrationCancelled: false,
        errorMessage: nil
    ))
    #expect(!MigrationProgressView.shouldDisableInteractiveDismiss(
        showConfirmation: false,
        migrationCompleted: true,
        migrationCancelled: false,
        errorMessage: nil
    ))
    #expect(!MigrationProgressView.shouldDisableInteractiveDismiss(
        showConfirmation: false,
        migrationCompleted: false,
        migrationCancelled: true,
        errorMessage: nil
    ))
    #expect(!MigrationProgressView.shouldDisableInteractiveDismiss(
        showConfirmation: false,
        migrationCompleted: false,
        migrationCancelled: false,
        errorMessage: "failed"
    ))
}

@Test func missingSourceStorageDoesNotAttemptMigration() {
    let target = URL(fileURLWithPath: "/tmp/cisum-storage-target", isDirectory: true)

    #expect(!MigrationProgressView.shouldPerformMigration(
        sourceURL: nil,
        targetURL: target,
        requestedMigration: true
    ))
    #expect(!MigrationProgressView.shouldPerformMigration(
        sourceURL: target,
        targetURL: nil,
        requestedMigration: true
    ))
    #expect(!MigrationProgressView.shouldPerformMigration(
        sourceURL: target,
        targetURL: target,
        requestedMigration: false
    ))
    #expect(MigrationProgressView.shouldPerformMigration(
        sourceURL: target,
        targetURL: target,
        requestedMigration: true
    ))
}

@Test func migrationActionRequiresExistingSourceStorage() {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let missingSource = root.appendingPathComponent("missing", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }
    try? FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)

    #expect(MigrationProgressView.canMigrateExistingData(
        sourceLocation: .local,
        sourceURL: source
    ))
    #expect(!MigrationProgressView.canMigrateExistingData(
        sourceLocation: .local,
        sourceURL: missingSource
    ))
    #expect(!MigrationProgressView.canMigrateExistingData(
        sourceLocation: nil,
        sourceURL: source
    ))
    #expect(!MigrationProgressView.canMigrateExistingData(
        sourceLocation: .local,
        sourceURL: nil
    ))
}

@Test func migrationUsesDisplayedSourceAndTargetRoots() throws {
    let displayedSource = URL(fileURLWithPath: "/tmp/cisum-storage-displayed-source", isDirectory: true)
    let displayedTarget = URL(fileURLWithPath: "/tmp/cisum-storage-displayed-target", isDirectory: true)

    let roots = try MigrationProgressView.migrationRoots(
        sourceURL: displayedSource,
        targetURL: displayedTarget,
        requestedMigration: true
    )

    #expect(roots?.source == displayedSource)
    #expect(roots?.target == displayedTarget)
    #expect(try MigrationProgressView.migrationRoots(
        sourceURL: displayedSource,
        targetURL: displayedTarget,
        requestedMigration: false
    ) == nil)
}

@Test func migrationRootResolutionReportsMissingDisplayedRoots() {
    let target = URL(fileURLWithPath: "/tmp/cisum-storage-target", isDirectory: true)

    #expect(throws: MigrationError.self) {
        try MigrationProgressView.migrationRoots(
            sourceURL: nil,
            targetURL: target,
            requestedMigration: true
        )
    }

    #expect(throws: MigrationError.self) {
        try MigrationProgressView.migrationRoots(
            sourceURL: target,
            targetURL: nil,
            requestedMigration: true
        )
    }

    #expect(throws: MigrationError.self) {
        try MigrationProgressView.migrationRoots(
            sourceURL: target,
            targetURL: nil,
            requestedMigration: false
        )
    }
}

@Test func migrationMovesContentsButKeepsSourceRoot() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let target = root.appendingPathComponent("target", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: source.appendingPathComponent("track.mp3"))

    let manager = MigrationManager()
    try manager.migrate(
        from: source,
        to: target,
        progressCallback: nil,
        downloadProgressCallback: nil,
        verbose: false
    )

    #expect(FileManager.default.fileExists(atPath: source.path))
    #expect(FileManager.default.fileExists(atPath: target.appendingPathComponent("track.mp3").path))
    #expect(!FileManager.default.fileExists(atPath: source.appendingPathComponent("track.mp3").path))
}

@Test func migrationRejectsTargetInsideSourceRootBeforeMovingFiles() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let target = source.appendingPathComponent("target", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: source.appendingPathComponent("track.mp3"))

    let manager = MigrationManager()

    #expect(MigrationManager.isTargetNestedInSource(sourceRoot: source, targetRoot: target))
    #expect(!MigrationManager.isTargetNestedInSource(sourceRoot: source, targetRoot: source))
    #expect(throws: MigrationError.self) {
        try manager.migrate(
            from: source,
            to: target,
            progressCallback: nil,
            downloadProgressCallback: nil,
            verbose: false
        )
    }

    #expect(FileManager.default.fileExists(atPath: source.appendingPathComponent("track.mp3").path))
    #expect(!FileManager.default.fileExists(atPath: target.path))
}

@Test func migrationTreatsRootSourceAsContainingTarget() {
    let source = URL(fileURLWithPath: "/", isDirectory: true)
    let target = URL(fileURLWithPath: "/tmp/cisum-storage-migration", isDirectory: true)

    #expect(MigrationManager.isTargetNestedInSource(sourceRoot: source, targetRoot: target))
    #expect(!MigrationManager.isTargetNestedInSource(sourceRoot: source, targetRoot: source))
}

@Test func migrationTreatsSymlinkedTargetRootAsSameSource() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let target = root.appendingPathComponent("source-link", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    let sourceFile = source.appendingPathComponent("track.mp3")
    try Data("audio".utf8).write(to: sourceFile)
    try FileManager.default.createSymbolicLink(at: target, withDestinationURL: source)

    var reportedProgress: Double?
    let manager = MigrationManager()
    try manager.migrate(
        from: source,
        to: target,
        progressCallback: { progress, _ in
            reportedProgress = progress
        },
        downloadProgressCallback: nil,
        verbose: false
    )

    #expect(reportedProgress == 1.0)
    #expect(FileManager.default.fileExists(atPath: sourceFile.path))
    #expect(!FileManager.default.fileExists(atPath: source.appendingPathComponent("track 2.mp3").path))
}

@Test func migrationRejectsTargetInsideSourceThroughSymlink() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let sourceLink = root.appendingPathComponent("source-link", isDirectory: true)
    let target = sourceLink.appendingPathComponent("target", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: source.appendingPathComponent("track.mp3"))
    try FileManager.default.createSymbolicLink(at: sourceLink, withDestinationURL: source)

    #expect(MigrationManager.isTargetNestedInSource(sourceRoot: source, targetRoot: target))

    let manager = MigrationManager()
    #expect(throws: MigrationError.self) {
        try manager.migrate(
            from: source,
            to: target,
            progressCallback: nil,
            downloadProgressCallback: nil,
            verbose: false
        )
    }

    #expect(FileManager.default.fileExists(atPath: source.appendingPathComponent("track.mp3").path))
    #expect(!FileManager.default.fileExists(atPath: target.path))
}

@Test func migrationReportsLocalAvailabilityBeforeMovingFiles() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let target = root.appendingPathComponent("target", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: source.appendingPathComponent("track.mp3"))

    var statuses: [FileStatus.DownloadStatus] = []
    let manager = MigrationManager()
    try manager.migrate(
        from: source,
        to: target,
        progressCallback: nil,
        downloadProgressCallback: { _, status in
            statuses.append(status)
        },
        verbose: false
    )

    #expect(statuses.contains(.local))
    #expect(FileManager.default.fileExists(atPath: target.appendingPathComponent("track.mp3").path))
}

@Test func migrationRenamesConflictingTargetFiles() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let target = root.appendingPathComponent("target", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)

    try Data("new".utf8).write(to: source.appendingPathComponent("track.mp3"))
    try Data("existing".utf8).write(to: target.appendingPathComponent("track.mp3"))

    let manager = MigrationManager()
    try manager.migrate(
        from: source,
        to: target,
        progressCallback: nil,
        downloadProgressCallback: nil,
        verbose: false
    )

    #expect(FileManager.default.fileExists(atPath: target.appendingPathComponent("track.mp3").path))
    #expect(FileManager.default.fileExists(atPath: target.appendingPathComponent("track 2.mp3").path))
    #expect(!FileManager.default.fileExists(atPath: source.appendingPathComponent("track.mp3").path))
}

@Test func migrationRenamesWhenTargetHasDanglingSymlink() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let target = root.appendingPathComponent("target", isDirectory: true)
    let danglingTarget = target.appendingPathComponent("track.mp3")
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)
    try Data("new".utf8).write(to: source.appendingPathComponent("track.mp3"))
    try FileManager.default.createSymbolicLink(
        at: danglingTarget,
        withDestinationURL: target.appendingPathComponent("missing.mp3")
    )

    let manager = MigrationManager()
    try manager.migrate(
        from: source,
        to: target,
        progressCallback: nil,
        downloadProgressCallback: nil,
        verbose: false
    )

    #expect((try? danglingTarget.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true)
    #expect(FileManager.default.fileExists(atPath: target.appendingPathComponent("track 2.mp3").path))
    #expect(!FileManager.default.fileExists(atPath: source.appendingPathComponent("track.mp3").path))
}

@Test func migrationCopiesSymlinkedFilesAsStandaloneFiles() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let target = root.appendingPathComponent("target", isDirectory: true)
    let external = root.appendingPathComponent("external", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: external, withIntermediateDirectories: true)
    let realFile = external.appendingPathComponent("real.mp3")
    let linkedFile = source.appendingPathComponent("linked.mp3")
    try Data("audio".utf8).write(to: realFile)
    try FileManager.default.createSymbolicLink(at: linkedFile, withDestinationURL: realFile)

    let manager = MigrationManager()
    try manager.migrate(
        from: source,
        to: target,
        progressCallback: nil,
        downloadProgressCallback: nil,
        verbose: false
    )

    let migratedFile = target.appendingPathComponent("linked.mp3")
    let fileType = try FileManager.default.attributesOfItem(atPath: migratedFile.path)[.type] as? FileAttributeType

    #expect(fileType == .typeRegular)
    #expect((try Data(contentsOf: migratedFile)) == Data("audio".utf8))
    #expect(!FileManager.default.fileExists(atPath: linkedFile.path))
    #expect(FileManager.default.fileExists(atPath: realFile.path))
}

@Test func migrationReportsCompletionOnlyAfterMoveFinishes() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let target = root.appendingPathComponent("target", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)

    let sourceFile = source.appendingPathComponent("track.mp3")
    let renamedTarget = target.appendingPathComponent("track 2.mp3")
    try Data("new".utf8).write(to: sourceFile)
    try Data("existing".utf8).write(to: target.appendingPathComponent("track.mp3"))

    var observations: [(progress: Double, sourceExists: Bool, renamedTargetExists: Bool)] = []
    let manager = MigrationManager()
    try manager.migrate(
        from: source,
        to: target,
        progressCallback: { progress, _ in
            observations.append((
                progress: progress,
                sourceExists: FileManager.default.fileExists(atPath: sourceFile.path),
                renamedTargetExists: FileManager.default.fileExists(atPath: renamedTarget.path)
            ))
        },
        downloadProgressCallback: nil,
        verbose: false
    )

    #expect(observations.count == 2)
    #expect(observations.first?.progress == 0)
    #expect(observations.first?.sourceExists == true)
    #expect(observations.first?.renamedTargetExists == false)
    #expect(observations.last?.progress == 1)
    #expect(observations.last?.sourceExists == false)
    #expect(observations.last?.renamedTargetExists == true)
}

@Test func emptyMigrationReportsCompleteProgress() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let target = root.appendingPathComponent("target", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)

    var reportedProgress: Double?
    let manager = MigrationManager()
    try manager.migrate(
        from: source,
        to: target,
        progressCallback: { progress, _ in
            reportedProgress = progress
        },
        downloadProgressCallback: nil,
        verbose: false
    )

    #expect(reportedProgress == 1.0)
    #expect(FileManager.default.fileExists(atPath: target.path))
}

@Test func migrationCancellationStopsBeforeMovingFiles() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let target = root.appendingPathComponent("target", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: source.appendingPathComponent("track.mp3"))

    let manager = MigrationManager()
    manager.cancelMigration()

    #expect(throws: MigrationError.self) {
        try manager.migrate(
            from: source,
            to: target,
            progressCallback: nil,
            downloadProgressCallback: nil,
            verbose: false
        )
    }

    #expect(FileManager.default.fileExists(atPath: source.appendingPathComponent("track.mp3").path))
    #expect(!FileManager.default.fileExists(atPath: target.appendingPathComponent("track.mp3").path))
}

@Test func migrationCancellationRequestedFromProgressStopsBeforeMovingCurrentFile() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let source = root.appendingPathComponent("source", isDirectory: true)
    let target = root.appendingPathComponent("target", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: source.appendingPathComponent("track.mp3"))

    let manager = MigrationManager()

    #expect(throws: MigrationError.self) {
        try manager.migrate(
            from: source,
            to: target,
            progressCallback: { _, _ in
                manager.cancelMigration()
            },
            downloadProgressCallback: nil,
            verbose: false
        )
    }

    #expect(FileManager.default.fileExists(atPath: source.appendingPathComponent("track.mp3").path))
    #expect(!FileManager.default.fileExists(atPath: target.appendingPathComponent("track.mp3").path))
}
