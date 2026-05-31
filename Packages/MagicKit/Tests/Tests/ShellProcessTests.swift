import Testing
@testable import MagicKit

#if os(macOS)
@Test func shellProcessTopCommandsUseMacOSSortFlags() {
    #expect(ShellProcess.topProcessesCommand(sort: .cpu, count: 10) == "ps aux -r | head -11")
    #expect(ShellProcess.topProcessesCommand(sort: .memory, count: 5) == "ps aux -m | head -6")
}

@Test func shellProcessTopCommandsClampNegativeCount() {
    #expect(ShellProcess.topProcessesCommand(sort: .cpu, count: -3) == "ps aux -r | head -1")
    #expect(ShellProcess.topProcessesCommand(sort: .memory, count: -1) == "ps aux -m | head -1")
}

@Test func shellProcessCommandsPreserveLiteralInputs() {
    let name = #"App $HOME `uname` "quote" and 'single quote'"#
    let file = #"/tmp/file $HOME `uname` "quote" and 'single quote'.txt"#
    let pid = #"123 $HOME `uname` "quote" and 'single quote'"#
    let quotedName = ShellProcess.shellQuoted(name)
    let quotedFile = ShellProcess.shellQuoted(file)
    let quotedPid = ShellProcess.shellQuoted(pid)

    #expect(ShellProcess.findProcessesCommand(named: name) == "ps aux | grep \(quotedName) | grep -v grep")
    #expect(ShellProcess.findProcessCommand(pid: pid) == "ps aux | grep \(ShellProcess.shellQuoted("\\b\(pid)\\b")) | grep -v grep")
    #expect(ShellProcess.killProcessCommand(pid: pid) == "kill \(quotedPid)")
    #expect(ShellProcess.forceKillProcessCommand(pid: pid) == "kill -9 \(quotedPid)")
    #expect(ShellProcess.killProcessesCommand(named: name) == "pkill \(quotedName)")
    #expect(ShellProcess.processTreeCommand(pid: pid) == "pstree \(quotedPid)")
    #expect(ShellProcess.launchAppCommand(name) == "open -a \(quotedName)")
    #expect(ShellProcess.launchAppCommand(name, withFile: file) == "open -a \(quotedName) \(quotedFile)")
    #expect(ShellProcess.isProcessRunningCommand(name) == "pgrep \(quotedName)")
    #expect(ShellProcess.processDetailsCommand(pid: pid) == "ps -p \(quotedPid) -o pid,ppid,user,time,command")
    #expect(ShellProcess.monitorProcessCommand(pid: pid) == "top -pid \(quotedPid) -l 1")
    #expect(ShellProcess.startServiceCommand(name) == "launchctl start \(quotedName)")
    #expect(ShellProcess.stopServiceCommand(name) == "launchctl stop \(quotedName)")
}

@Test func shellProcessTopQueriesReturnProcessesOnMacOS() {
    #expect(!ShellProcess.getTopCPUProcesses(count: 3).isEmpty)
    #expect(!ShellProcess.getTopMemoryProcesses(count: 3).isEmpty)
}
#endif
