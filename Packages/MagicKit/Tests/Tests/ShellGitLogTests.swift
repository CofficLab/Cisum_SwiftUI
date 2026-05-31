import Testing
@testable import MagicKit

#if os(macOS)
@Test func shellGitLogParserPreservesPipesInSubjects() throws {
    let commit = try #require(ShellGit.parseRecentCommitLine(
        "abc123|Author|author@example.com|1700000000|fix: keep A | B visible"
    ))

    #expect(commit.hash == "abc123")
    #expect(commit.message == "fix: keep A | B visible")
}

@Test func shellGitCommitDetailParserPreservesPipesInBody() throws {
    let detail = try ShellGit.parseCommitDetailOutput(
        "abc123|Author|author@example.com|1700000000|fix: subject|body keeps A | B"
    )

    #expect(detail.id == "abc123")
    #expect(detail.message == "fix: subject")
    #expect(detail.body == "body keeps A | B")
}

@Test func shellGitLogParserSkipsMalformedRecentCommitRows() {
    #expect(ShellGit.parseRecentCommitLine("abc123|Author|missing fields") == nil)
}
#endif
