import Testing
@testable import MagicKit

#if os(macOS)
@Test func shellSystemCommandsPreserveLiteralInputs() {
    let value = #"/tmp/Cisum $HOME `uname` "quote" and 'single quote'"#
    let quoted = ShellSystem.shellQuoted(value)

    #expect(ShellSystem.diskUsageCommand(path: value) == "df -h \(quoted)")
    #expect(ShellSystem.processesCommand(named: value) == "ps aux | grep \(quoted) | grep -v grep")
    #expect(ShellSystem.commandExistsCommand(value) == "which \(quoted)")
}

@Test func shellSystemEnvironmentReadsWithoutShellExpansion() {
    #expect(ShellSystem.getEnvironmentVariable(#"PATH"; echo injected"#) == "")
}
#endif
