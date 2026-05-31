import Foundation
import Testing
@testable import PluginFileLog

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
