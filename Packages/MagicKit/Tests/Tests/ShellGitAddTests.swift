import Foundation
import Testing
@testable import MagicKit

#if os(macOS)
@Test func shellGitAddAndResetPreserveLiteralFileNames() throws {
    let repo = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: repo)
    }

    try FileManager.default.createDirectory(at: repo, withIntermediateDirectories: true)
    _ = try Shell.runSync("git init", at: repo.path)

    let fileName = #"literal $HOME `uname` "quote" and 'single quote'.txt"#
    let file = repo.appendingPathComponent(fileName)
    try "content\n".write(to: file, atomically: true, encoding: .utf8)

    try ShellGit.add([fileName], at: repo.path)
    let stagedPath = try Shell.runSync("git diff --cached --name-only -- \(ShellGit.shellQuoted(fileName))", at: repo.path)
    #expect(!stagedPath.isEmpty)

    try ShellGit.reset([fileName], at: repo.path)
    let resetStagedPath = try Shell.runSync("git diff --cached --name-only -- \(ShellGit.shellQuoted(fileName))", at: repo.path)
    #expect(resetStagedPath.isEmpty)
    #expect(try ShellGit.unstagedFiles(at: repo.path).contains(fileName))
}
#endif
