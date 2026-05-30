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
