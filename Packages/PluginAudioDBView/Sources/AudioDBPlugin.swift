import KernelCore
import ProviderDocsView
import ProviderAudioNavigation
import PluginAudio
import ProviderPlayback
import ProviderScene
import ProviderStorage
import SwiftUI
import MagicKit
import OSLog

public actor AudioDBPlugin: SuperPlugin, SuperLog {
    nonisolated static let verbose = false

    public static let shared = AudioDBPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: String.LocalizationValue(AudioDBPluginInfo.titleKey), bundle: .module),
        description: String(localized: String.LocalizationValue(AudioDBPluginInfo.descriptionKey), bundle: .module),
        iconName: "externaldrive",
        order: 1,
        policy: .alwaysOn,
        category: .library,
    )

    nonisolated(unsafe) private let sceneBox = SceneBox()
    nonisolated(unsafe) private weak var kernel: CisumKernel?
    nonisolated(unsafe) private var listViewModel: AudioListViewModel?
    nonisolated(unsafe) private var rootViewModel: AudioDBRootViewModel?
    nonisolated(unsafe) private var dbViewModel: AudioDBViewModel?
    nonisolated(unsafe) private var databaseObserver: AudioDatabaseObserver?
    nonisolated(unsafe) private var playbackObserver: AudioDBPlaybackObserver?
    nonisolated(unsafe) private var settingPlaybackObserver: AudioDBPlaybackObserver?
    nonisolated(unsafe) private var sceneState: AudioDBSceneState?
    nonisolated(unsafe) private var sceneObserver: AudioDBSceneObserver?
    nonisolated(unsafe) private var navigationProvider: (any AudioTrackNavigationProviding)?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioDBPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioDBPluginManualView() })
        }
    }

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        self.kernel = kernel
        guard let scene = kernel.resolveProvider((any SceneProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "SceneProviding")
        }
        sceneBox.scene = scene
        installNavigationProvider(kernel: kernel)
    }

    /// 所有 Provider 插件完成 onBoot 后再组装依赖它们的 ViewModel 与 Observer。
    ///
    /// `PluginPlayBack` 同样在 onBoot 注册 PlaybackProviding，因此 AudioDB 不能
    /// 在自己的 onBoot 中假设播放服务已经存在。
    @MainActor
    public func onReady(kernel: CisumKernel) async throws {
        installNavigationProvider(kernel: kernel)
        installState(kernel: kernel)
    }

    @MainActor
    public func onEnable(kernel: CisumKernel) async throws {
        self.kernel = kernel
        installNavigationProvider(kernel: kernel)
        installState(kernel: kernel)
    }

    @MainActor
    public func onDisable(kernel: CisumKernel) async throws {
        teardownState()
        removeNavigationProvider(from: kernel)
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        sceneBox.scene = nil
        teardownState()
        removeNavigationProvider(from: kernel)
    }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        let (list, root, db) = resolveViewModels()
        return AnyView(
            AudioDBPluginRootView(
                listViewModel: list,
                rootViewModel: root,
                dbViewModel: db,
                sceneState: resolveSceneState(),
                audioRepo: audioRepoProvider,
                audioDisk: audioDiskProvider,
                audioDiagnostics: audioDiagnosticsProvider,
                content: content
            )
        )
    }

    @MainActor
    public func addTabView(reason: String, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard sceneBox.scene?.currentScene == .music else { return nil }
        guard demoMode == false else { return nil }

        let (list, root, db) = resolveViewModels()
        return (
            AnyView(AudioDBPluginTabView(
                listViewModel: list,
                rootViewModel: root,
                dbViewModel: db,
                audioRepo: audioRepoProvider,
                audioDisk: audioDiskProvider,
                audioDiagnostics: audioDiagnosticsProvider,
                demoMode: demoMode
            )),
            String(localized: "Music Repository", bundle: .module)
        )
    }

    /// 设置窗口入口：展示音频库文件列表。
    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        // 设置页使用独立的 AudioListViewModel，避免与主窗口内容区（AudioList）
        // 共享同一实例——否则设置页 onAppear 触发 handleOnAppear() 重载时，
        // 共享状态变化会传播到主窗口 contentview，导致其闪动。
        let playback = kernel?.playback
        let settingList = AudioListViewModel(
            audioRepo: audioRepoProvider,
            playbackCapability: makePlaybackCapability(from: playback)
        )
        settingPlaybackObserver = AudioDBPlaybackObserver(playback: playback, viewModel: settingList)
        return PluginSettingNavigationItem(
            id: "audiodb",
            title: String(localized: String.LocalizationValue(AudioDBPluginInfo.titleKey), bundle: .module),
            description: Self.metadata.description,
            iconName: Self.metadata.iconName,
            order: Self.metadata.order,
            destination: AnyView(
                AudioDBSettingView()
                    .environmentObject(settingList)
                    .environment(\.audioDBDependencies, settingDependencies)
            )
        )
    }

    /// 设置页依赖：仓库路径 / 仓库 / 诊断均由本插件自持（不依赖 AudioPlugin）。
    @MainActor
    private var settingDependencies: AudioDBDependencies {
        AudioDBDependencies(
            audioRepo: audioRepoProvider,
            audioDisk: audioDiskProvider,
            audioDiagnostics: audioDiagnosticsProvider,
            supportedExtensions: AudioPluginInfo.supportedExtensions,
            isDesktop: Self.isDesktop,
            isNotDesktop: !Self.isDesktop,
            showDBView: { self.kernel?.appState?.showDBView() ?? () },
            isImporting: .constant(false)
        )
    }

    private static var isDesktop: Bool {
        #if os(macOS)
            true
        #else
            false
        #endif
    }

    // MARK: - State assembly

    /// 注册本插件提供的音频曲目导航服务。
    ///
    /// Provider 由插件定义文件组装；消费插件只依赖协议，不依赖
    /// `AudioRepo` 或本插件的具体实现。
    @MainActor
    private func installNavigationProvider(kernel: CisumKernel) {
        guard navigationProvider == nil else { return }
        let repoProvider = audioRepoProvider
        let provider = AudioTrackNavigationProvider(
            nextURL: { current, verbose in
                guard let repo = await repoProvider() else {
                    os_log(.error, "\(Self.t)❌ Cannot find next audio: repository is unavailable")
                    throw AudioPluginError.hostNotConfigured
                }
                do {
                    let result = try await repo.getNextOf(current, verbose: verbose)
                    if result == nil {
                        os_log("\(Self.t)ℹ️ No next audio for current item: \(current?.lastPathComponent ?? "<none>")")
                    }
                    return result
                } catch {
                    os_log(.error, "\(Self.t)❌ Failed to resolve next audio: \(error.localizedDescription)")
                    throw error
                }
            },
            previousURL: { current, verbose in
                guard let repo = await repoProvider() else {
                    os_log(.error, "\(Self.t)❌ Cannot find previous audio: repository is unavailable")
                    throw AudioPluginError.hostNotConfigured
                }
                do {
                    let result = try await repo.getPrevOf(current, verbose: verbose)
                    if result == nil {
                        os_log("\(Self.t)ℹ️ No previous audio for current item: \(current?.lastPathComponent ?? "<none>")")
                    }
                    return result
                } catch {
                    os_log(.error, "\(Self.t)❌ Failed to resolve previous audio: \(error.localizedDescription)")
                    throw error
                }
            },
            firstURL: {
                guard let repo = await repoProvider() else {
                    os_log(.error, "\(Self.t)❌ Cannot find first audio: repository is unavailable")
                    throw AudioPluginError.hostNotConfigured
                }
                do {
                    return try await repo.getFirst()
                } catch {
                    os_log(.error, "\(Self.t)❌ Failed to resolve first audio: \(error.localizedDescription)")
                    throw error
                }
            },
            lastURL: {
                guard let repo = await repoProvider() else {
                    os_log(.error, "\(Self.t)❌ Cannot find last audio: repository is unavailable")
                    throw AudioPluginError.hostNotConfigured
                }
                do {
                    return try await repo.getLast()
                } catch {
                    os_log(.error, "\(Self.t)❌ Failed to resolve last audio: \(error.localizedDescription)")
                    throw error
                }
            }
        )
        navigationProvider = provider
        kernel.registerAudioTrackNavigation(provider)
    }

    @MainActor
    private func removeNavigationProvider(from kernel: CisumKernel) {
        guard navigationProvider != nil else { return }
        kernel.unregisterProvider((any AudioTrackNavigationProviding).self)
        navigationProvider = nil
    }

    /// 创建并持有音频数据库的 ViewModel 与数据库观察者（幂等）。
    @MainActor
    private func installState(kernel: CisumKernel) {
        guard listViewModel == nil else { return }

        guard let playback = kernel.playback else { return }
        let list = AudioListViewModel(
            audioRepo: audioRepoProvider,
            playbackCapability: makePlaybackCapability(from: playback)
        )
        let root = AudioDBRootViewModel(
            audioRepo: audioRepoProvider,
            showDBView: { kernel.appState?.showDBView() ?? () }
        )
        let db = AudioDBViewModel()
        let observer = AudioDatabaseObserver(list: list, root: root, db: db)
        let playbackObserver = AudioDBPlaybackObserver(playback: playback, viewModel: list)

        listViewModel = list
        rootViewModel = root
        dbViewModel = db
        databaseObserver = observer
        self.playbackObserver = playbackObserver

        _ = resolveSceneState()
    }

    @MainActor
    private func teardownState() {
        sceneObserver?.cancel()
        sceneObserver = nil
        sceneState = nil
        databaseObserver?.cancel()
        databaseObserver = nil
        playbackObserver?.cancel()
        playbackObserver = nil
        settingPlaybackObserver?.cancel()
        settingPlaybackObserver = nil
        listViewModel = nil
        rootViewModel = nil
        dbViewModel = nil
    }

    // MARK: - 仓库路径自持（不依赖 AudioPlugin actor）

    /// 音频仓库磁盘目录：`storageRoot` + `dbDirName`。
    ///
    /// 由本插件直接从内核存储服务解析，不再经由 `AudioPlugin` 的静态入口，
    /// 因此 `AudioPlugin` 的启用状态不影响仓库可用性。
    @MainActor
    private static func makeAudioDisk(from storage: any StorageProviding) -> URL? {
        guard let root = storage.storageRoot else { return nil }
        return try? root
            .appendingPathComponent(AudioPluginInfo.effectiveDBDirName, isDirectory: true)
            .ensureDirectory()
    }

    /// 构建音频仓库：磁盘目录 + SwiftData 容器 + `AudioRepo`。
    @MainActor
    private static func makeAudioRepo(from storage: any StorageProviding) async -> AudioRepo? {
        guard let disk = Self.makeAudioDisk(from: storage) else { return nil }
        guard let databaseURL = try? storage.databaseFile(name: "audio") else { return nil }
        guard let container = try? AudioConfigRepo.getContainer(databaseURL: databaseURL) else { return nil }
        return try? AudioRepo(container: container, disk: disk, reason: "AudioDBPlugin")
    }

    /// 将内核能力收窄后注入 ViewModel；ViewModel 不持有 Kernel。
    @MainActor
    private func makePlaybackCapability(
        from playback: (any PlaybackProviding)?
    ) -> (any AudioPlaybackCapability)? {
        guard let playback else { return nil }
        return AudioPlaybackCapabilityAdapter(playback: playback)
    }

    /// 仓库路径解析诊断（错误视图展示）。
    @MainActor
    private var audioDiagnosticsProvider: @MainActor @Sendable () -> AudioStorageDiagnostics {
        { @MainActor [weak self] in
            AudioStorageDiagnostics.make(storage: self?.kernel?.storage)
        }
    }

    @MainActor
    private var audioDiskProvider: @MainActor @Sendable () -> URL? {
        { @MainActor [weak self] in
            guard let storage = self?.kernel?.storage else { return nil }
            return Self.makeAudioDisk(from: storage)
        }
    }

    @MainActor
    private var audioRepoProvider: @MainActor @Sendable () async -> AudioRepo? {
        { @MainActor [weak self] in
            guard let storage = self?.kernel?.storage else { return nil }
            return await Self.makeAudioRepo(from: storage)
        }
    }

    /// 返回当前持有的 ViewModel；若尚未安装（启动前或插件被禁用），
    /// 提供临时空实例保证 View 贡献可用。
    @MainActor
    private func resolveViewModels() -> (list: AudioListViewModel, root: AudioDBRootViewModel, db: AudioDBViewModel) {
        if let listViewModel, let rootViewModel, let dbViewModel {
            return (listViewModel, rootViewModel, dbViewModel)
        }
        let list = AudioListViewModel(
            audioRepo: audioRepoProvider,
            playbackCapability: makePlaybackCapability(from: kernel?.playback)
        )
        let root = AudioDBRootViewModel(audioRepo: audioRepoProvider, showDBView: {})
        let db = AudioDBViewModel()
        listViewModel = list
        rootViewModel = root
        dbViewModel = db
        return (list, root, db)
    }

    /// 返回场景门状态（幂等创建）；同时注册场景监听器。
    @MainActor
    private func resolveSceneState() -> AudioDBSceneState {
        if let sceneState { return sceneState }
        let state = AudioDBSceneState(isMusicScene: sceneBox.scene?.currentScene == .music)
        sceneState = state
        sceneObserver = AudioDBSceneObserver(scene: sceneBox.scene, sceneState: state)
        return state
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
