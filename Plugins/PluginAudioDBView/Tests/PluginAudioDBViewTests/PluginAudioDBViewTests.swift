import Testing
@testable import PluginAudioDBView
import Foundation
import UniformTypeIdentifiers

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

@Test func audioListLoadsMoreFromCurrentLoadedCount() {
    #expect(AudioList.nextLoadOffset(loadedCount: 90) == 90)
    #expect(AudioList.nextLoadOffset(loadedCount: 100) == 100)
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

@Test func audioImportFiltersUnsupportedDroppedItems() {
    let root = URL(fileURLWithPath: "/tmp/cisum-audio-import-filter-tests", isDirectory: true)
    let supported = root.appendingPathComponent("track.MP3")
    let unsupported = root.appendingPathComponent("notes.txt")
    let folder = root.appendingPathComponent("folder", isDirectory: true)

    #expect(AudioDBView.supportedImportURLs(
        from: [supported, unsupported, folder],
        supportedExtensions: ["mp3", "wav"]
    ) == [supported])
}

@Test func audioDropReadsFileURLDataProvider() async throws {
    let expected = URL(fileURLWithPath: "/tmp/cisum-audio-drop-provider-tests/track.mp3")
    let provider = NSItemProvider()
    provider.registerDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier, visibility: .all) { completion in
        completion(expected.dataRepresentation, nil)
        return nil
    }

    let url = try await AudioDBView.droppedFileURL(from: provider)

    #expect(url == expected)
}
