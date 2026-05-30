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

@Test func directStorageSwitchUsesAccurateCompletionMessage() {
    #expect(MigrationProgressView.completionMessage(shouldMigrate: true) == "迁移已完成")
    #expect(MigrationProgressView.completionMessage(shouldMigrate: false) == "已切换到新位置")
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
