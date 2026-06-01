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

@Test func audioSettingsHidesOpenLibraryActionForMissingLocalDisk() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let missingDisk = root.appendingPathComponent("missing", isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    #expect(!AudioSettingsView.shouldShowOpenLibraryAction(for: missingDisk))
    #expect(AudioSettingsView.shouldShowOpenLibraryAction(for: root))
}

@Test func audioSettingsUsesSingularFileCountOnlyForOneFile() {
    #expect(!AudioSettingsView.shouldUseSingularFileCount(0))
    #expect(AudioSettingsView.shouldUseSingularFileCount(1))
    #expect(!AudioSettingsView.shouldUseSingularFileCount(2))
}
