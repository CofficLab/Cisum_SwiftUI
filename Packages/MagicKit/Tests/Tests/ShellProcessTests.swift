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

@Test func shellProcessTopQueriesReturnProcessesOnMacOS() {
    #expect(!ShellProcess.getTopCPUProcesses(count: 3).isEmpty)
    #expect(!ShellProcess.getTopMemoryProcesses(count: 3).isEmpty)
}
#endif
