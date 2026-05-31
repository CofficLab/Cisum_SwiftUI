import Testing
@testable import MagicKit

#if os(macOS)
@Test func shellGitRemoteParserIgnoresMalformedVerboseRows() {
    let remotes = ShellGit.parseRemoteListOutput("""
    origin\thttps://github.com/example/app.git (fetch)
    origin\thttps://github.com/example/app.git (push)
    missing-tab https://example.com/repo.git (fetch)
    upstream\thttps://github.com/example/upstream.git
    mirror\thttps://github.com/example/mirror.git (mirror)
    backup\tssh://git@example.com/backup.git (push)
    """)

    #expect(remotes.count == 2)
    #expect(remotes[0] == MagicGitRemote(
        id: "origin",
        name: "origin",
        url: "https://github.com/example/app.git",
        fetchURL: "https://github.com/example/app.git",
        pushURL: "https://github.com/example/app.git",
        isDefault: true
    ))
    #expect(remotes[1] == MagicGitRemote(
        id: "backup",
        name: "backup",
        url: "ssh://git@example.com/backup.git",
        fetchURL: nil,
        pushURL: "ssh://git@example.com/backup.git",
        isDefault: false
    ))
}
#endif
