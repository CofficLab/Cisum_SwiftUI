import KernelCore
import ProviderDocsView
import CisumUIComponents
import MagicPlayMan
import PluginAudio
import ProviderScene
import ProviderStorage
import SwiftUI

public actor AudioDBPlugin: SuperPlugin {
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
    nonisolated(unsafe) private var sceneState: AudioDBSceneState?
    nonisolated(unsafe) private var sceneObserver: AudioDBSceneObserver?

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
        installState(kernel: kernel)
    }

    @MainActor
    public func onEnable(kernel: CisumKernel) async throws {
        self.kernel = kernel
        installState(kernel: kernel)
    }

    @MainActor
    public func onDisable(kernel: CisumKernel) async throws {
        teardownState()
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        sceneBox.scene = nil
        teardownState()
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
        let settingList = AudioListViewModel(audioRepo: audioRepoProvider)
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

    /// 创建并持有音频数据库的 ViewModel 与数据库观察者（幂等）。
    @MainActor
    private func installState(kernel: CisumKernel) {
        guard listViewModel == nil else { return }

        let list = AudioListViewModel(
            audioRepo: audioRepoProvider
        )
        let root = AudioDBRootViewModel(
            audioRepo: audioRepoProvider,
            showDBView: { kernel.appState?.showDBView() ?? () }
        )
        let db = AudioDBViewModel()
        let observer = AudioDatabaseObserver(list: list, root: root, db: db)

        listViewModel = list
        rootViewModel = root
        dbViewModel = db
        databaseObserver = observer

        _ = resolveSceneState()
    }

    @MainActor
    private func teardownState() {
        sceneObserver?.cancel()
        sceneObserver = nil
        sceneState = nil
        databaseObserver?.cancel()
        databaseObserver = nil
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
        let list = AudioListViewModel(audioRepo: audioRepoProvider)
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

private struct AudioDBPluginRootView<Content>: View where Content: View {
    @Environment(\.demoMode) private var isDemoMode
    @Environment(\.appIsImporting) private var isImporting
    @Environment(\.showAudioDBViewAction) private var showDBView
    @EnvironmentObject private var playMan: MagicPlayMan

    let listViewModel: AudioListViewModel
    let rootViewModel: AudioDBRootViewModel
    let dbViewModel: AudioDBViewModel
    @ObservedObject var sceneState: AudioDBSceneState

    private let audioRepo: @MainActor @Sendable () async -> AudioRepo?
    private let audioDisk: @MainActor @Sendable () -> URL?
    private let audioDiagnostics: @MainActor @Sendable () -> AudioStorageDiagnostics

    private let content: Content

    init(
        listViewModel: AudioListViewModel,
        rootViewModel: AudioDBRootViewModel,
        dbViewModel: AudioDBViewModel,
        sceneState: AudioDBSceneState,
        audioRepo: @escaping @MainActor @Sendable () async -> AudioRepo?,
        audioDisk: @escaping @MainActor @Sendable () -> URL?,
        audioDiagnostics: @escaping @MainActor @Sendable () -> AudioStorageDiagnostics,
        @ViewBuilder content: () -> Content
    ) {
        self.listViewModel = listViewModel
        self.rootViewModel = rootViewModel
        self.dbViewModel = dbViewModel
        self.sceneState = sceneState
        self.audioRepo = audioRepo
        self.audioDisk = audioDisk
        self.audioDiagnostics = audioDiagnostics
        self.content = content()
    }

    var body: some View {
        if sceneState.isMusicScene {
            AudioDBRootView(isDemoMode: isDemoMode) {
                content
            }
            .environment(\.audioDBDependencies, dependencies)
            .environmentObject(listViewModel)
            .environmentObject(rootViewModel)
            .environmentObject(dbViewModel)
            .onAppear {
                listViewModel.bind(playMan: playMan)
            }
        } else {
            // 场景不是音乐库：下掉 AudioDB root view 外壳，直接透传内容区。
            content
        }
    }

    private var dependencies: AudioDBDependencies {
        AudioDBDependencies(
            audioRepo: audioRepo,
            audioDisk: audioDisk,
            audioDiagnostics: audioDiagnostics,
            supportedExtensions: AudioPluginInfo.supportedExtensions,
            isDesktop: Self.isDesktop,
            isNotDesktop: !Self.isDesktop,
            showDBView: showDBView,
            isImporting: isImporting
        )
    }

    private static var isDesktop: Bool {
        #if os(macOS)
            true
        #else
            false
        #endif
    }
}

private struct AudioDBPluginTabView: View {
    @Environment(\.appIsImporting) private var isImporting
    @Environment(\.showAudioDBViewAction) private var showDBView
    @EnvironmentObject private var playMan: MagicPlayMan

    let listViewModel: AudioListViewModel
    let rootViewModel: AudioDBRootViewModel
    let dbViewModel: AudioDBViewModel

    private let audioRepo: @MainActor @Sendable () async -> AudioRepo?
    private let audioDisk: @MainActor @Sendable () -> URL?
    private let audioDiagnostics: @MainActor @Sendable () -> AudioStorageDiagnostics

    let demoMode: Bool

    init(
        listViewModel: AudioListViewModel,
        rootViewModel: AudioDBRootViewModel,
        dbViewModel: AudioDBViewModel,
        audioRepo: @escaping @MainActor @Sendable () async -> AudioRepo?,
        audioDisk: @escaping @MainActor @Sendable () -> URL?,
        audioDiagnostics: @escaping @MainActor @Sendable () -> AudioStorageDiagnostics,
        demoMode: Bool
    ) {
        self.listViewModel = listViewModel
        self.rootViewModel = rootViewModel
        self.dbViewModel = dbViewModel
        self.audioRepo = audioRepo
        self.audioDisk = audioDisk
        self.audioDiagnostics = audioDiagnostics
        self.demoMode = demoMode
    }

    var body: some View {
        AudioDBView(isDemoMode: demoMode)
            .environment(\.audioDBDependencies, dependencies)
            .environmentObject(listViewModel)
            .environmentObject(rootViewModel)
            .environmentObject(dbViewModel)
            .onAppear {
                listViewModel.bind(playMan: playMan)
            }
    }

    private var dependencies: AudioDBDependencies {
        AudioDBDependencies(
            audioRepo: audioRepo,
            audioDisk: audioDisk,
            audioDiagnostics: audioDiagnostics,
            supportedExtensions: AudioPluginInfo.supportedExtensions,
            isDesktop: Self.isDesktop,
            isNotDesktop: !Self.isDesktop,
            showDBView: showDBView,
            isImporting: isImporting
        )
    }

    private static var isDesktop: Bool {
        #if os(macOS)
            true
        #else
            false
        #endif
    }
}
