import Foundation
import Testing
@testable import MagicKit

@Test func revealInFinderOnlyAllowsLocalPaths() throws {
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

    #expect(URLOpenActionPolicy.canRevealInFinder(existingFile))
    #expect(URLOpenActionPolicy.canRevealInFinder(danglingLink))
    #expect(!URLOpenActionPolicy.canRevealInFinder(missingFile))
    #expect(!URLOpenActionPolicy.canRevealInFinder(URL(string: "https://example.com")!))
}
