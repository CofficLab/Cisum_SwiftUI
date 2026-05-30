import Testing
@testable import PluginStorage
import Foundation

@Test func storagePluginInfoIsExposed() {
    #expect(StoragePluginInfo.titleKey == "Storage Settings")
    #expect(PluginStorageLocation.local.rawValue == "local")
    #expect(StoragePlugin.shouldRegister)
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
