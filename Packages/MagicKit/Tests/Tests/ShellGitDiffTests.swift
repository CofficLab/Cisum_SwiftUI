import Foundation
import Testing
@testable import MagicKit

#if os(macOS)
@Test func shellGitNameStatusParserUsesNewPathForRenamesAndCopies() throws {
    let renamed = try #require(ShellGit.parseNameStatusLine("R100\told/name.md\tnew/name.md"))
    let copied = try #require(ShellGit.parseNameStatusLine("C075\tsource.md\tcopy.md"))

    #expect(renamed.changeType == "R100")
    #expect(renamed.file == "new/name.md")
    #expect(copied.changeType == "C075")
    #expect(copied.file == "copy.md")
}

@Test func shellGitNameStatusParserUsesPathForSimpleChanges() throws {
    let modified = try #require(ShellGit.parseNameStatusLine("M\tSources/App.swift"))
    let deleted = try #require(ShellGit.parseNameStatusLine("D\tOld.swift"))

    #expect(modified.file == "Sources/App.swift")
    #expect(deleted.file == "Old.swift")
}

@Test func shellGitNameStatusParserSkipsMalformedRows() {
    #expect(ShellGit.parseNameStatusLine("M") == nil)
    #expect(ShellGit.parseNameStatusLine("\tfile.swift") == nil)
    #expect(ShellGit.parseNameStatusLine("R100\told.swift\t") == nil)
}

@Test func shellGitDiffHandlesQuotedFilePaths() async throws {
    let repo = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: repo)
    }

    try FileManager.default.createDirectory(at: repo, withIntermediateDirectories: true)
    _ = try Shell.runSync("git init", at: repo.path)
    _ = try Shell.runSync("git config user.name Test", at: repo.path)
    _ = try Shell.runSync("git config user.email test@example.com", at: repo.path)

    let fileName = "folder/a file 'quoted'.txt"
    let fileURL = repo.appendingPathComponent(fileName)
    try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try "before\n".write(to: fileURL, atomically: true, encoding: .utf8)
    _ = try Shell.runSync("git add .", at: repo.path)
    _ = try Shell.runSync("git commit -m initial", at: repo.path)

    try "after\n".write(to: fileURL, atomically: true, encoding: .utf8)

    let directDiff = try ShellGit.diffFile(fileName, at: repo.path)
    let listedDiff = try await ShellGit.diffFileList(at: repo.path)
    let contentChange = try ShellGit.uncommittedFileContentChange(file: fileName, repoPath: repo.path)

    #expect(directDiff.contains("-before"))
    #expect(directDiff.contains("+after"))
    #expect(listedDiff.map { $0.file } == [fileName])
    #expect(listedDiff.first?.diff.contains("+after") == true)
    #expect(contentChange.before == "before")
    #expect(contentChange.after == "after\n")
}
#endif
