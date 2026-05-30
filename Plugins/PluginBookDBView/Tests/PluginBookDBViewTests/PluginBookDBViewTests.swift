import Testing
@testable import PluginBookDBView
import Foundation
import UniformTypeIdentifiers

@Test func bookDBInfoExportsMetadata() {
    #expect(BookDBPluginInfo.table == "Book-DBView")
    #expect(BookDBPluginInfo.iconName == "books.vertical")
}

@Test func folderImportRequiresPlayableFiles() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    let unsupportedFolder = root.appendingPathComponent("unsupported", isDirectory: true)
    let supportedFolder = root.appendingPathComponent("supported", isDirectory: true)
    let nestedFolder = supportedFolder.appendingPathComponent("disc-1", isDirectory: true)

    try FileManager.default.createDirectory(at: unsupportedFolder, withIntermediateDirectories: true)
    try Data("notes".utf8).write(to: unsupportedFolder.appendingPathComponent("notes.txt"))

    try FileManager.default.createDirectory(at: nestedFolder, withIntermediateDirectories: true)
    try Data("audio".utf8).write(to: nestedFolder.appendingPathComponent("chapter.m4b"))

    #expect(BookDBView.folderContainsPlayableFiles(unsupportedFolder) == false)
    #expect(BookDBView.folderContainsPlayableFiles(supportedFolder) == true)
}

@Test func bookImportCleansCopiedItemsWhenBatchFails() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let sourceRoot = root.appendingPathComponent("source", isDirectory: true)
    let destinationRoot = root.appendingPathComponent("destination", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: sourceRoot, withIntermediateDirectories: true)
    let validSource = sourceRoot.appendingPathComponent("chapter-1.m4b")
    let missingSource = sourceRoot.appendingPathComponent("chapter-2.m4b")
    try Data("audio".utf8).write(to: validSource)

    await #expect(throws: Error.self) {
        try await BookDBView.copyImportedItems([validSource, missingSource], to: destinationRoot)
    }

    #expect(FileManager.default.fileExists(atPath: destinationRoot.appendingPathComponent("source").path) == false)
}

@Test func bookDropReadsFileURLDataProvider() async throws {
    let expected = URL(fileURLWithPath: "/tmp/cisum-book-drop-provider-tests/audiobook")
    let provider = NSItemProvider()
    provider.registerDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier, visibility: .all) { completion in
        completion(expected.dataRepresentation, nil)
        return nil
    }

    let url = try await BookDBView.droppedFileURL(from: provider)

    #expect(url == expected)
}

@Test func bookDropSkipsEmptyImportAfterProviderFailure() {
    let error = NSError(domain: "BookDrop", code: 1)
    let url = URL(fileURLWithPath: "/tmp/cisum-book-drop-provider-tests/audiobook")

    #expect(BookDBView.shouldImportDroppedURLs([], after: [error]) == false)
    #expect(BookDBView.shouldImportDroppedURLs([url], after: [error]) == true)
    #expect(BookDBView.shouldImportDroppedURLs([], after: []) == true)
}

@Test func bookPlaybackOrderingUsesRelativePaths() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    let disc1 = root.appendingPathComponent("Disc 1", isDirectory: true)
    let disc2 = root.appendingPathComponent("Disc 2", isDirectory: true)
    try FileManager.default.createDirectory(at: disc1, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: disc2, withIntermediateDirectories: true)

    let disc1Chapter2 = disc1.appendingPathComponent("02.m4b")
    let disc2Chapter1 = disc2.appendingPathComponent("01.m4b")
    try Data("audio".utf8).write(to: disc1Chapter2)
    try Data("audio".utf8).write(to: disc2Chapter1)

    let playable = BookPlaybackOrdering.playableChildren(for: root)

    #expect(playable.map { BookPlaybackOrdering.relativePath($0, in: root) } == [
        "Disc 1/02.m4b",
        "Disc 2/01.m4b",
    ])
    #expect(BookPlaybackOrdering.relativePath(disc1Chapter2, in: root) == "Disc 1/02.m4b")
}
