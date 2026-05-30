import Foundation
@testable import PluginBookSettings
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookSettingsPluginInfo.iconName == "gearshape")
    #expect(BookSettingsPluginInfo.order == 11)
}

@Test func bookSettingsOnlyAppliesCurrentDiskMetrics() {
    let firstDisk = URL(fileURLWithPath: "/tmp/cisum-book-settings/first", isDirectory: true)
    let secondDisk = URL(fileURLWithPath: "/tmp/cisum-book-settings/second", isDirectory: true)

    #expect(BookSettingsMetricsPolicy.shouldApplyMetrics(
        currentDisk: firstDisk,
        requestedDisk: firstDisk,
        currentGeneration: 2,
        resultGeneration: 2
    ))
    #expect(!BookSettingsMetricsPolicy.shouldApplyMetrics(
        currentDisk: secondDisk,
        requestedDisk: firstDisk,
        currentGeneration: 2,
        resultGeneration: 2
    ))
    #expect(!BookSettingsMetricsPolicy.shouldApplyMetrics(
        currentDisk: firstDisk,
        requestedDisk: firstDisk,
        currentGeneration: 2,
        resultGeneration: 1
    ))
}
