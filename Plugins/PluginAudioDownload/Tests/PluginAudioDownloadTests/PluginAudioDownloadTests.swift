import Testing
import Foundation
@testable import PluginAudioDownload

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(AudioDownloadPluginInfo.iconName == "icloud.and.arrow.down")
    #expect(AudioDownloadPluginInfo.order == 2)
}

@Test func audioDownloadOnlyStartsForActiveMissingAsset() {
    let asset = URL(fileURLWithPath: "/tmp/cisum-audio-download/track.mp3")

    #expect(AudioDownloadRequestPolicy.shouldStartDownload(
        isSceneActive: true,
        asset: asset,
        isNotDownloaded: true
    ))
    #expect(!AudioDownloadRequestPolicy.shouldStartDownload(
        isSceneActive: false,
        asset: asset,
        isNotDownloaded: true
    ))
    #expect(!AudioDownloadRequestPolicy.shouldStartDownload(
        isSceneActive: true,
        asset: nil,
        isNotDownloaded: true
    ))
    #expect(!AudioDownloadRequestPolicy.shouldStartDownload(
        isSceneActive: true,
        asset: asset,
        isNotDownloaded: false
    ))
}

@Test func audioDownloadOnlyAppliesCurrentAssetResults() {
    let asset = URL(fileURLWithPath: "/tmp/cisum-audio-download/track.mp3")
    let other = URL(fileURLWithPath: "/tmp/cisum-audio-download/other.mp3")

    #expect(AudioDownloadRequestPolicy.shouldApplyDownloadResult(
        requestedAsset: asset,
        currentAsset: asset,
        isSceneActive: true
    ))
    #expect(!AudioDownloadRequestPolicy.shouldApplyDownloadResult(
        requestedAsset: asset,
        currentAsset: other,
        isSceneActive: true
    ))
    #expect(!AudioDownloadRequestPolicy.shouldApplyDownloadResult(
        requestedAsset: asset,
        currentAsset: asset,
        isSceneActive: false
    ))
}
