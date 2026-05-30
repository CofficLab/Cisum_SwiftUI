import Foundation
import PluginAudioJob
import Testing

@Test func jobStatusExportsMetadata() {
    let status = JobStatus(identifier: "job", name: "Job", isRunning: true)

    #expect(status.identifier == "job")
    #expect(status.name == "Job")
    #expect(status.isRunning)
}

@Test func localFileChangesUseFullSync() {
    let localDisk = URL(fileURLWithPath: "/tmp/cisum-audio-job-tests", isDirectory: true)

    #expect(FileSystemMonitorJob.shouldPerformFullSync(isFirst: true, disk: nil))
    #expect(FileSystemMonitorJob.shouldPerformFullSync(isFirst: false, disk: localDisk))
}

@Test func staleMonitorRunStopsAfterRestart() {
    let firstRun = UUID()
    let secondRun = UUID()

    #expect(FileSystemMonitorJob.shouldContinueRunning(
        runID: firstRun,
        activeRunID: firstRun,
        isRunning: true
    ))
    #expect(!FileSystemMonitorJob.shouldContinueRunning(
        runID: firstRun,
        activeRunID: secondRun,
        isRunning: true
    ))
    #expect(!FileSystemMonitorJob.shouldContinueRunning(
        runID: firstRun,
        activeRunID: nil,
        isRunning: false
    ))
}
