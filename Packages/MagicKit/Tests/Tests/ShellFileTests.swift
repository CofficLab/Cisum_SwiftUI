import Foundation
import Testing
@testable import MagicKit

#if os(macOS)
@Test func shellFileMakeFileWritesLiteralContent() throws {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: directory)
    }

    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

    let file = directory.appendingPathComponent("literal content.txt")
    let content = #"""
literal $HOME `uname` "quote" \ slash
second line
"""#

    ShellFile().makeFile(file.path, content: content)

    let saved = try String(contentsOf: file, encoding: .utf8)
    #expect(saved == content)
}
#endif
