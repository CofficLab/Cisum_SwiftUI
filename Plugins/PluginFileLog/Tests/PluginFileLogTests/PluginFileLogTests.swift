import Foundation
import Testing
@testable import PluginFileLog
#if os(macOS)
    import AppKit

private final class LockedCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var value = 0

    func increment() {
        lock.withLock {
            value += 1
        }
    }

    var count: Int {
        lock.withLock {
            value
        }
    }
}
#endif

@Test func defaultConfigurationReturnsFileLogDirectory() {
    let url = DefaultFileLogConfiguration().logsDirectory()
    #expect(url.lastPathComponent == "FileLog")
}

@Test func logRotationUsesUniqueNameWhenTimestampAlreadyExists() {
    let directory = URL(fileURLWithPath: "/tmp/cisum-file-log-tests", isDirectory: true)
    let existing = directory.appendingPathComponent("2026-05-31_15-00-00.log")

    let next = FileLogRotation.uniqueLogFileURL(
        baseName: "2026-05-31_15-00-00",
        in: directory
    ) { url in
        url == existing
    }

    #expect(next.lastPathComponent == "2026-05-31_15-00-00 2.log")
}

@Test func logRotationUsesReadableFallbackForEmptyBaseName() {
    let directory = URL(fileURLWithPath: "/tmp/cisum-file-log-tests", isDirectory: true)

    let next = FileLogRotation.uniqueLogFileURL(baseName: "", in: directory) { _ in false }

    #expect(next.lastPathComponent == "Cisum Log.log")
}

#if os(macOS)
@Test func terminationObserverIsIdempotentAndRemovable() {
    let notificationCenter = NotificationCenter()
    let observer = FileLogTerminationObserver()
    let stopCount = LockedCounter()

    let stop: @Sendable () -> Void = {
        stopCount.increment()
    }

    observer.start(notificationCenter: notificationCenter, stop: stop)
    observer.start(notificationCenter: notificationCenter, stop: stop)

    notificationCenter.post(name: NSApplication.willTerminateNotification, object: nil)

    #expect(stopCount.count == 1)

    observer.stopObserving(notificationCenter: notificationCenter)
    notificationCenter.post(name: NSApplication.willTerminateNotification, object: nil)

    #expect(stopCount.count == 1)
}
#endif
