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
