import AudioLibraryCore
import Combine
import Foundation
import ProviderAudioLibrary

/// AudioDB 对外暴露的音频库 Provider。
///
/// 外部插件只依赖 `ProviderAudioLibrary`，仓库和存储解析留在 AudioDB 内部。
@MainActor
final class AudioLibraryProvider: AudioLibraryProviding, ObservableObject {
    private let repoProvider: @MainActor @Sendable () async -> AudioRepo?
    private let diskProvider: @MainActor @Sendable () -> URL?

    init(
        repoProvider: @escaping @MainActor @Sendable () async -> AudioRepo?,
        diskProvider: @escaping @MainActor @Sendable () -> URL?
    ) {
        self.repoProvider = repoProvider
        self.diskProvider = diskProvider
    }

    var audioDisk: URL? { diskProvider() }

    var supportedExtensions: [String] {
        AudioPluginInfo.supportedExtensions
    }

    var isAvailable: Bool {
        audioDisk != nil
    }

    func totalCount() async -> Int {
        guard let repo = await repoProvider() else { return 0 }
        return await repo.getTotalCount()
    }
}
