import Foundation
import Testing
@testable import MagicKit

#if os(macOS)
@Test func shellGitTagPreservesLiteralMessage() throws {
    let repo = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: repo)
    }

    try FileManager.default.createDirectory(at: repo, withIntermediateDirectories: true)
    _ = try Shell.runSync("git init", at: repo.path)
    _ = try Shell.runSync("git config user.name Test", at: repo.path)
    _ = try Shell.runSync("git config user.email test@example.com", at: repo.path)

    try "hello\n".write(
        to: repo.appendingPathComponent("file.txt"),
        atomically: true,
        encoding: .utf8
    )
    try ShellGit.add(["file.txt"], at: repo.path)
    _ = try ShellGit.commit(message: "initial", at: repo.path)

    let tagName = "release/test-tag"
    let message = #"literal $HOME `uname` "quote" and 'single quote'"#
    _ = try ShellGit.createTag(tagName, message: message, at: repo.path)

    let subject = try Shell.runSync("git for-each-ref refs/tags/release/test-tag --format='%(subject)'", at: repo.path)
        .trimmingCharacters(in: .whitespacesAndNewlines)
    let listed = try #require(try ShellGit.tagList(at: repo.path).first { $0.name == tagName })

    #expect(subject == message)
    #expect(listed.message == message)
}
#endif
