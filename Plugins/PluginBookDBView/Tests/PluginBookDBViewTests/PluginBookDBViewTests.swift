import Testing
@testable import PluginBookDBView
import Foundation

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

@Test func bookImportCleansCopiedItemsWhenBatchFails() throws {
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

    #expect(throws: Error.self) {
        try BookDBView.copyImportedItems([validSource, missingSource], to: destinationRoot)
    }

    #expect(FileManager.default.fileExists(atPath: destinationRoot.appendingPathComponent("source").path) == false)
}
