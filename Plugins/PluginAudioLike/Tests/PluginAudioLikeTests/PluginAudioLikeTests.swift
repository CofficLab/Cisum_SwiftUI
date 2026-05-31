import Foundation
@testable import PluginAudioLike
import Testing

private final class NotificationObserverToken: @unchecked Sendable {
    var value: NSObjectProtocol?
}

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

@Test func audioLikeSettingsOnlyAppliesLatestLoadResult() {
    #expect(AudioLikeSettingsLoadPolicy.shouldApplyResult(
        currentGeneration: 2,
        resultGeneration: 2
    ))
    #expect(!AudioLikeSettingsLoadPolicy.shouldApplyResult(
        currentGeneration: 2,
        resultGeneration: 1
    ))
}

@Test func audioLikeStatusChangeOnlyAppliesLatestGeneration() {
    #expect(AudioLikeStatusChangePolicy.shouldApplyChange(
        currentGeneration: 3,
        requestGeneration: 3
    ))
    #expect(!AudioLikeStatusChangePolicy.shouldApplyChange(
        currentGeneration: 3,
        requestGeneration: 2
    ))
}

@Test func audioLikeStatusNotificationIsDeliveredOnMainThread() async {
    let url = URL(fileURLWithPath: "/tmp/audio/main-thread.mp3")

    let deliveredOnMainThread = await withCheckedContinuation { continuation in
        let token = NotificationObserverToken()
        token.value = NotificationCenter.default.addObserver(
            forName: .AudioLikeStatusChanged,
            object: nil,
            queue: nil
        ) { _ in
            if let observer = token.value {
                NotificationCenter.default.removeObserver(observer)
                token.value = nil
            }
            continuation.resume(returning: Thread.isMainThread)
        }

        Task.detached {
            NotificationCenter.postAudioLikeStatusChanged(
                audioId: url.absoluteString,
                url: url,
                liked: true
            )
        }
    }

    #expect(deliveredOnMainThread)
}

@Suite(.serialized)
struct AudioLikeRepoTests {
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

    @Test
    @MainActor
    func audioLikeRepoUsesReconfiguredDatabaseURL() async throws {
        let firstDatabaseURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("PluginAudioLikeTests-\(UUID().uuidString)-first")
            .appendingPathExtension("store")
        let secondDatabaseURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("PluginAudioLikeTests-\(UUID().uuidString)-second")
            .appendingPathExtension("store")
        defer {
            try? FileManager.default.removeItem(at: firstDatabaseURL)
            try? FileManager.default.removeItem(at: secondDatabaseURL)
        }

        let audioId = "file:///tmp/audio/reconfigured.mp3"

        AudioLikeRepositoryConfiguration.configure(databaseURL: firstDatabaseURL)
        try await AudioLikeRepo.shared.updateLikeStatus(audioId: audioId, liked: true)
        #expect(try await AudioLikeRepo.shared.findLikeModel(audioId: audioId) != nil)

        AudioLikeRepositoryConfiguration.configure(databaseURL: secondDatabaseURL)
        #expect(try await AudioLikeRepo.shared.findLikeModel(audioId: audioId) == nil)
    }

    @Test
    @MainActor
    func audioLikeRepoPersistsMetadataForSettings() async throws {
        let databaseURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("PluginAudioLikeTests-\(UUID().uuidString)-metadata")
            .appendingPathExtension("store")
        defer {
            try? FileManager.default.removeItem(at: databaseURL)
        }

        AudioLikeRepositoryConfiguration.configure(databaseURL: databaseURL)

        let url = URL(fileURLWithPath: "/tmp/audio/metadata-track.mp3")
        let audioId = url.absoluteString

        try await AudioLikeRepo.shared.updateLikeStatus(
            audioId: audioId,
            liked: true,
            url: url,
            title: "Metadata Track"
        )

        let model = try #require(await AudioLikeRepo.shared.findLikeModel(audioId: audioId))
        #expect(model.url == url)
        #expect(model.title == "Metadata Track")
    }

    @Test
    @MainActor
    func audioLikeRepoBackfillsMissingMetadata() async throws {
        let databaseURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("PluginAudioLikeTests-\(UUID().uuidString)-backfill")
            .appendingPathExtension("store")
        defer {
            try? FileManager.default.removeItem(at: databaseURL)
        }

        AudioLikeRepositoryConfiguration.configure(databaseURL: databaseURL)

        let url = URL(fileURLWithPath: "/tmp/audio/backfilled-track.mp3")
        let audioId = url.absoluteString

        try await AudioLikeRepo.shared.updateLikeStatus(audioId: audioId, liked: true)
        try await AudioLikeRepo.shared.updateLikeStatus(
            audioId: audioId,
            liked: true,
            url: url,
            title: "Backfilled Track"
        )

        let model = try #require(await AudioLikeRepo.shared.findLikeModel(audioId: audioId))
        #expect(model.url == url)
        #expect(model.title == "Backfilled Track")
    }

    @Test
    @MainActor
    func audioLikeRepoMatchesSymlinkedLikedAudio() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let databaseURL = root
            .appendingPathComponent("PluginAudioLikeTests-\(UUID().uuidString)-symlink")
            .appendingPathExtension("store")
        let realFolder = root.appendingPathComponent("real", isDirectory: true)
        let linkedFolder = root.appendingPathComponent("linked", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: realFolder, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: linkedFolder, withDestinationURL: realFolder)
        let realURL = realFolder.appendingPathComponent("track.mp3")
        let linkedURL = linkedFolder.appendingPathComponent("track.mp3")
        try Data("audio".utf8).write(to: realURL)

        AudioLikeRepositoryConfiguration.configure(databaseURL: databaseURL)

        try await AudioLikeRepo.shared.updateLikeStatus(
            audioId: realURL.absoluteString,
            liked: true,
            url: realURL,
            title: "Track"
        )

        #expect(await AudioLikeRepo.shared.isLiked(url: linkedURL))
    }

    @Test
    @MainActor
    func audioLikeRepoUnlikesSymlinkedStoredAudio() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let databaseURL = root
            .appendingPathComponent("PluginAudioLikeTests-\(UUID().uuidString)-unlink")
            .appendingPathExtension("store")
        let realFolder = root.appendingPathComponent("real", isDirectory: true)
        let linkedFolder = root.appendingPathComponent("linked", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: realFolder, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: linkedFolder, withDestinationURL: realFolder)
        let realURL = realFolder.appendingPathComponent("track.mp3")
        let linkedURL = linkedFolder.appendingPathComponent("track.mp3")
        try Data("audio".utf8).write(to: realURL)

        AudioLikeRepositoryConfiguration.configure(databaseURL: databaseURL)

        try await AudioLikeRepo.shared.updateLikeStatus(
            audioId: realURL.absoluteString,
            liked: true,
            url: realURL,
            title: "Track"
        )
        try await AudioLikeRepo.shared.updateLikeStatus(
            audioId: linkedURL.absoluteString,
            liked: false,
            url: linkedURL
        )

        #expect(!(await AudioLikeRepo.shared.isLiked(url: realURL)))
        #expect(try await AudioLikeRepo.shared.findLikeModel(audioId: realURL.absoluteString) == nil)
    }

    @Test
    @MainActor
    func audioLikeRepoReplacesSymlinkedDuplicateLike() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let databaseURL = root
            .appendingPathComponent("PluginAudioLikeTests-\(UUID().uuidString)-dedupe")
            .appendingPathExtension("store")
        let realFolder = root.appendingPathComponent("real", isDirectory: true)
        let linkedFolder = root.appendingPathComponent("linked", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        try FileManager.default.createDirectory(at: realFolder, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: linkedFolder, withDestinationURL: realFolder)
        let realURL = realFolder.appendingPathComponent("track.mp3")
        let linkedURL = linkedFolder.appendingPathComponent("track.mp3")
        try Data("audio".utf8).write(to: realURL)

        AudioLikeRepositoryConfiguration.configure(databaseURL: databaseURL)

        try await AudioLikeRepo.shared.updateLikeStatus(
            audioId: realURL.absoluteString,
            liked: true,
            url: realURL,
            title: "Real"
        )
        try await AudioLikeRepo.shared.updateLikeStatus(
            audioId: linkedURL.absoluteString,
            liked: true,
            url: linkedURL,
            title: "Linked"
        )

        let liked = await AudioLikeRepo.shared.getAllLiked()
        #expect(liked.count == 1)
        #expect(liked.first?.url == linkedURL)
        #expect(liked.first?.title == "Linked")
    }
}
