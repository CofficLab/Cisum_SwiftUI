import Testing
@testable import PluginAudioDBView
import Foundation

@Test func audioDBInfoExportsMetadata() {
    #expect(AudioDBPluginInfo.titleKey == "Audio Repository")
    #expect(AudioDBPluginInfo.table == "Audio-DBView")
}

@Test func audioImportCleansCopiedFilesWhenBatchFails() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let sourceRoot = root.appendingPathComponent("source", isDirectory: true)
    let destinationRoot = root.appendingPathComponent("destination", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: sourceRoot, withIntermediateDirectories: true)
    let validSource = sourceRoot.appendingPathComponent("valid.mp3")
    let missingSource = sourceRoot.appendingPathComponent("missing.mp3")
    try Data("audio".utf8).write(to: validSource)

    await #expect(throws: Error.self) {
        try await AudioDBView.copyFilesInBackground([validSource, missingSource], to: destinationRoot)
    }

    #expect(FileManager.default.fileExists(atPath: destinationRoot.appendingPathComponent("valid.mp3").path) == false)
}

@Test func audioImportCleansCopiedFilesWhenRepositoryIsUnavailable() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let copiedFile = root.appendingPathComponent("orphaned.mp3")
    try Data("audio".utf8).write(to: copiedFile)

    AudioDBView.cleanUpCopiedFiles([copiedFile])

    #expect(FileManager.default.fileExists(atPath: copiedFile.path) == false)
}

@Test func audioListRejectsStaleDeleteOffsets() {
    let root = URL(fileURLWithPath: "/tmp/cisum-audio-list-tests", isDirectory: true)
    let urls = [
        root.appendingPathComponent("one.mp3"),
        root.appendingPathComponent("two.mp3"),
    ]

    #expect(AudioList.urlsToDelete(from: IndexSet(integer: 1), in: urls) == [urls[1]])
    #expect(AudioList.urlsToDelete(from: IndexSet(integer: 2), in: urls) == nil)
}

@Test func audioDeleteOnlyResetsPlaybackForStillCurrentDeletedAudio() {
    let root = URL(fileURLWithPath: "/tmp/cisum-audio-delete-tests", isDirectory: true)
    let deleted = root.appendingPathComponent("deleted.mp3")
    let switched = root.appendingPathComponent("switched.mp3")

    #expect(AudioDeletePlaybackPolicy.shouldResetAfterDelete(
        currentURL: deleted,
        deletedURLs: [deleted]
    ))
    #expect(!AudioDeletePlaybackPolicy.shouldResetAfterDelete(
        currentURL: switched,
        deletedURLs: [deleted]
    ))
    #expect(!AudioDeletePlaybackPolicy.shouldResetAfterDelete(
        currentURL: nil,
        deletedURLs: [deleted]
    ))
}
