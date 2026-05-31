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

@Test func shellGitLogCommandsPreserveLiteralRefs() {
    let branch = #"feature/$HOME-`uname`-"quote"-'single'"#
    let remote = #"origin $HOME `uname`"#
    let commit = #"HEAD^{/fix $HOME `uname`}"#
    let format = #"%H|%an|%s $HOME `uname`"#
    let quotedBranch = ShellGit.shellQuoted(branch)
    let quotedRemoteRange = ShellGit.shellQuoted("\(remote)/\(branch)..\(branch)")
    let quotedCommit = ShellGit.shellQuoted(commit)
    let quotedFormat = ShellGit.shellQuoted(format)

    #expect(ShellGit.commitsInBranchCommand(branch, count: 2, format: format) == "git log \(quotedBranch) -n 2 --pretty=format:\(quotedFormat)")
    #expect(ShellGit.commitDetailCommand(commit, format: format) == "git show \(quotedCommit) --pretty=format:\(quotedFormat) --no-patch")
    #expect(ShellGit.commitShowCommand(commit) == "git show \(quotedCommit)")
    #expect(ShellGit.unpushedCommitsCommand(remote: remote, branchName: branch) == "git log \(quotedRemoteRange) --oneline")
    #expect(ShellGit.unpushedCommitListCommand(remote: remote, branchName: branch).hasPrefix("git log \(quotedRemoteRange) --pretty=format:"))
}
#endif
