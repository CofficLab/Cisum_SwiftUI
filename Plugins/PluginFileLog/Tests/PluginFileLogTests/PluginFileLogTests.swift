import Foundation
import Testing
@testable import PluginFileLog

@Test func defaultConfigurationReturnsFileLogDirectory() {
    let url = DefaultFileLogConfiguration().logsDirectory()
    #expect(url.lastPathComponent == "FileLog")
}
