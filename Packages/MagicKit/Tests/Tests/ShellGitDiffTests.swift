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
#endif
