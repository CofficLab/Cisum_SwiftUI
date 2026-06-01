import Foundation
import Testing

@testable import MagicKit

private final class InitialScanRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var didReceiveInitialScan = false
    private var filesCount: Int?
    private var errorDescription: String?

    func record(files: [URL], isInitialFetch: Bool, error: Error?) {
        lock.lock()
        didReceiveInitialScan = isInitialFetch
        filesCount = files.count
        errorDescription = error?.localizedDescription
        lock.unlock()
    }

    func snapshot() -> (didReceiveInitialScan: Bool, filesCount: Int?, errorDescription: String?) {
        lock.lock()
        defer { lock.unlock() }
        return (didReceiveInitialScan, filesCount, errorDescription)
    }
}

@Test func localDirectoryMonitorDetectsFileListChanges() {
    let base = URL(fileURLWithPath: "/tmp/cisum-monitor-tests", isDirectory: true)
    let previous = [
        base.appendingPathComponent("a.mp3"),
        base.appendingPathComponent("b.mp3"),
    ]
    let current = [
        base.appendingPathComponent("a.mp3"),
        base.appendingPathComponent("b.mp3"),
        base.appendingPathComponent("c.mp3"),
    ]

    #expect(!LocalDirectoryMonitor.hasFileListChanged(previous: previous, current: previous))
    #expect(LocalDirectoryMonitor.hasFileListChanged(previous: previous, current: current))
}

@Test func localDirectoryMonitorCreatesMissingDirectoryBeforeInitialScan() async throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer { try? FileManager.default.removeItem(at: root) }

    let recorder = InitialScanRecorder()
    let monitor = LocalDirectoryMonitor(
        directoryURL: root,
        verbose: false,
        caller: "test"
    ) { files, isInitialFetch, error in
        recorder.record(files: files, isInitialFetch: isInitialFetch, error: error)
    }

    let cancellable = monitor.start()
    try await Task.sleep(for: .milliseconds(250))
    cancellable.cancel()

    var isDirectory: ObjCBool = false
    #expect(FileManager.default.fileExists(atPath: root.path, isDirectory: &isDirectory))
    #expect(isDirectory.boolValue)

    let snapshot = recorder.snapshot()
    #expect(snapshot.didReceiveInitialScan)
    #expect(snapshot.filesCount == 0)
    #expect(snapshot.errorDescription == nil)
}
