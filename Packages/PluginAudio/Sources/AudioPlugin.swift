import KernelCore
import ProviderDocsView
import CisumUIComponents
import Foundation
import PluginAudioLike
import ProviderStorage
import SwiftUI

public actor AudioPlugin: SuperPlugin {
    public static let shared = AudioPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: String.LocalizationValue(AudioPluginInfo.titleKey), bundle: .module),
        description: String(localized: String.LocalizationValue(AudioPluginInfo.descriptionKey), bundle: .module),
        iconName: .cisumIconMusicNote,
        order: 1,
        category: .library,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioPluginManualView() })
        }
    }

    public static let maxAudioCount = AudioPluginInfo.maxAudioCount
    public static let supportedExtensions = AudioPluginInfo.supportedExtensions

    #if DEBUG
        public static let dbDirName = AudioPluginInfo.debugDBDirName
    #else
        public static let dbDirName = AudioPluginInfo.dbDirName
    #endif

    nonisolated(unsafe) private var rootViewModel: AudioRootViewModel?
    nonisolated(unsafe) private var rootObserver: AudioStorageObserver?

    /// OnReady 阶段（Storage 服务已注册）将 `AudioPluginHost` 桥接到内核
    /// `StorageProviding`，使历史插件代码无需改动即可继续工作，并安装
    /// 音频根视图的 ViewModel 与存储观察者。
    @MainActor
    public func onReady(kernel: CisumKernel) async throws {
        guard let storage = kernel.storage else { return }
        AudioPluginHost.configure(
            databaseURL: { try storage.databaseFile(name: $0) },
            storageRoot: { storage.storageRoot },
            hasStorageLocation: { storage.hasUsableStorageLocation },
            storageLocationDidChangeNotifications: [.cisumStorageLocationDidChange, .cisumStorageLocationDidReset]
        )
        installRootState(kernel: kernel)
    }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        // View 贡献可能在启动前被请求：保证返回稳定、长期存在的 ViewModel。
        let viewModel = rootViewModel ?? {
            let viewModel = AudioRootViewModel(
                databaseURL: { try AudioPluginHost.createDatabaseFile(name: "audio") },
                hasStorageLocation: { AudioPluginHost.hasStorageLocation() }
            )
            rootViewModel = viewModel
            return viewModel
        }()
        return AnyView(AudioRootView(viewModel: viewModel, content: content))
    }

    @MainActor
    public func onEnable(kernel: CisumKernel) async throws {
        installRootState(kernel: kernel)
    }

    @MainActor
    public func onDisable(kernel: CisumKernel) async throws {
        teardownRootState()
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        teardownRootState()
    }

    // MARK: - Root state assembly

    @MainActor
    private func installRootState(kernel: CisumKernel) {
        guard rootViewModel == nil else { return }
        guard let storage = kernel.storage else { return }
        let viewModel = AudioRootViewModel(
            databaseURL: { try AudioPluginHost.createDatabaseFile(name: "audio") },
            hasStorageLocation: { AudioPluginHost.hasStorageLocation() }
        )
        let observer = AudioStorageObserver(provider: storage, viewModel: viewModel)
        rootViewModel = viewModel
        rootObserver = observer
    }

    @MainActor
    private func teardownRootState() {
        rootObserver?.cancel()
        rootObserver = nil
        rootViewModel = nil
    }

    @MainActor
    public static func getAudioDisk() -> URL? {
        guard let storageRoot = AudioPluginHost.getStorageRoot() else {
            return nil
        }

        let disk = storageRoot.appendingPathComponent(Self.dbDirName, isDirectory: true)
        return try? disk.ensureDirectory()
    }

    @MainActor
    public static func getAudioRepo() -> AudioRepo? {
        guard let configuration = Self.audioRepoConfiguration() else {
            return nil
        }

        return try? AudioRepo(
            disk: configuration.disk,
            databaseURL: configuration.databaseURL,
            reason: "AudioPlugin"
        )
    }

    /// 后台构造音频仓库。目录和数据库 URL 的解析仍在主线程完成，
    /// SwiftData 容器创建及仓库初始化放到 utility 任务，避免列表刷新阻塞 UI。
    public static func getAudioRepoAsync() async -> AudioRepo? {
        let configuration = await MainActor.run { Self.audioRepoConfiguration() }
        guard let configuration else { return nil }

        let container = await Task.detached(priority: .utility) {
            try? AudioConfigRepo.getContainer(databaseURL: configuration.databaseURL)
        }.value
        guard let container else { return nil }

        return await MainActor.run {
            try? AudioRepo(
                container: container,
                disk: configuration.disk,
                reason: "AudioPlugin.background"
            )
        }
    }

    @MainActor
    private static func audioRepoConfiguration() -> AudioRepoConfiguration? {
        guard let disk = Self.getAudioDisk() else { return nil }

        guard let audioLikeDatabaseURL = try? AudioPluginHost.createDatabaseFile(name: "audio_like") else {
            return nil
        }
        AudioLikeRepositoryConfiguration.configure(databaseURL: audioLikeDatabaseURL)

        guard let databaseURL = try? AudioPluginHost.createDatabaseFile(name: "audio") else {
            return nil
        }

        return AudioRepoConfiguration(
            disk: disk,
            databaseURL: databaseURL
        )
    }
}

private struct AudioRepoConfiguration: Sendable {
    let disk: URL
    let databaseURL: URL
}
