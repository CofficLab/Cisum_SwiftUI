import Foundation
import Testing

@testable import MagicKit

@Test func iCloudDirectoryMonitorLifecycleSuppressesCancelledDelayedStart() {
    let lifecycle = ICloudDirectoryMonitorLifecycle()
    let cancelledRun = lifecycle.beginRun()

    #expect(lifecycle.shouldStart(runID: cancelledRun))
    #expect(lifecycle.cancel(runID: cancelledRun))
    #expect(!lifecycle.shouldStart(runID: cancelledRun))
}

@Test func iCloudDirectoryMonitorLifecycleKeepsReplacementRunAfterStaleCancel() {
    let lifecycle = ICloudDirectoryMonitorLifecycle()
    let staleRun = lifecycle.beginRun()
    let replacementRun = lifecycle.beginRun()

    #expect(!lifecycle.cancel(runID: staleRun))
    #expect(!lifecycle.shouldStart(runID: staleRun))
    #expect(lifecycle.shouldStart(runID: replacementRun))
}
