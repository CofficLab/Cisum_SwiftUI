import Foundation
import Testing
@testable import MagicKit

#if os(macOS)
@Test func shellGitUnstagedFilesIncludesUntrackedFiles() throws {
    let repo = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: repo)
    }

    try FileManager.default.createDirectory(at: repo, withIntermediateDirectories: true)
    _ = try Shell.runSync("git init", at: repo.path)

    let fileName = "new notes.txt"
    try "draft\n".write(
        to: repo.appendingPathComponent(fileName),
        atomically: true,
        encoding: .utf8
    )

    #expect(try ShellGit.hasUncommittedChanges(at: repo.path))
    #expect(try ShellGit.unstagedFiles(at: repo.path) == [fileName])
}

@Test func shellGitUnstagedPorcelainParserIgnoresStagedOnlyRows() {
    #expect(ShellGit.parseUnstagedFile(fromPorcelainLine: "A  staged.txt") == nil)
    #expect(ShellGit.parseUnstagedFile(fromPorcelainLine: " M changed.txt") == "changed.txt")
    #expect(ShellGit.parseUnstagedFile(fromPorcelainLine: "AM staged-and-changed.txt") == "staged-and-changed.txt")
    #expect(ShellGit.parseUnstagedFile(fromPorcelainLine: "?? untracked.txt") == "untracked.txt")
}
#endif
