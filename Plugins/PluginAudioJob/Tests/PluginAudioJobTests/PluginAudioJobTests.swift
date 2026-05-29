import PluginAudioJob
import Testing

@Test func jobStatusExportsMetadata() {
    let status = JobStatus(identifier: "job", name: "Job", isRunning: true)

    #expect(status.identifier == "job")
    #expect(status.name == "Job")
    #expect(status.isRunning)
}
