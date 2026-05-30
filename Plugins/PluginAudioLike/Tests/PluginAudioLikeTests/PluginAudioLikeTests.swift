import Foundation
import PluginAudioLike
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(AudioLikePluginInfo.iconName == "heart")
    #expect(AudioLikePluginInfo.emoji == "❤️")
    #expect(AudioLikePluginInfo.order == 3)
}

@Test
@MainActor
func pluginExposesSettingsView() {
    let view = AudioLikePlugin.shared.addSettingView()

    #expect(view != nil)
}

@Test
@MainActor
func unlikedAudioDoesNotCreateStoredRecord() async throws {
    let databaseURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("PluginAudioLikeTests-\(UUID().uuidString)")
        .appendingPathExtension("store")
    defer { try? FileManager.default.removeItem(at: databaseURL) }

    AudioLikeRepositoryConfiguration.configure(databaseURL: databaseURL)

    let audioId = "file:///tmp/audio/not-liked.mp3"

    try await AudioLikeRepo.shared.updateLikeStatus(audioId: audioId, liked: false)
    #expect(try await AudioLikeRepo.shared.findLikeModel(audioId: audioId) == nil)

    try await AudioLikeRepo.shared.updateLikeStatus(audioId: audioId, liked: true)
    #expect(try await AudioLikeRepo.shared.findLikeModel(audioId: audioId) != nil)

    try await AudioLikeRepo.shared.updateLikeStatus(audioId: audioId, liked: false)
    #expect(try await AudioLikeRepo.shared.findLikeModel(audioId: audioId) == nil)
}
