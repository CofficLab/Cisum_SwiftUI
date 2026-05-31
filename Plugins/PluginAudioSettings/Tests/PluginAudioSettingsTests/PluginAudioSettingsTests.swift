import Foundation
@testable import PluginAudioSettings
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(AudioSettingsPluginInfo.iconName == "gearshape")
    #expect(AudioSettingsPluginInfo.order == 10)
}

@Test func audioSettingsOnlyAppliesCurrentDiskMetrics() {
    let firstDisk = URL(fileURLWithPath: "/tmp/cisum-audio-settings/first", isDirectory: true)
    let secondDisk = URL(fileURLWithPath: "/tmp/cisum-audio-settings/second", isDirectory: true)

    #expect(AudioSettingsMetricsPolicy.shouldApplyMetrics(
        currentDisk: firstDisk,
        requestedDisk: firstDisk,
        currentGeneration: 2,
        resultGeneration: 2
    ))
    #expect(!AudioSettingsMetricsPolicy.shouldApplyMetrics(
        currentDisk: secondDisk,
        requestedDisk: firstDisk,
        currentGeneration: 2,
        resultGeneration: 2
    ))
    #expect(!AudioSettingsMetricsPolicy.shouldApplyMetrics(
        currentDisk: firstDisk,
        requestedDisk: firstDisk,
        currentGeneration: 2,
        resultGeneration: 1
    ))
    #expect(!AudioSettingsMetricsPolicy.shouldApplyMetrics(
        currentDisk: nil,
        requestedDisk: firstDisk,
        currentGeneration: 2,
        resultGeneration: 2
    ))
}
