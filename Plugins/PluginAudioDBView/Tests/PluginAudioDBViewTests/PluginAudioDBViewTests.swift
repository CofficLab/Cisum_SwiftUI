import Testing
@testable import PluginAudioDBView
import Foundation

@Test func audioDBInfoExportsMetadata() {
    #expect(AudioDBPluginInfo.titleKey == "Audio Repository")
    #expect(AudioDBPluginInfo.table == "Audio-DBView")
}

@Test func audioImportCleansCopiedFilesWhenBatchFails() throws {
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

    #expect(throws: Error.self) {
        try AudioDBView.copyFilesInBackground([validSource, missingSource], to: destinationRoot)
    }

    #expect(FileManager.default.fileExists(atPath: destinationRoot.appendingPathComponent("valid.mp3").path) == false)
}
