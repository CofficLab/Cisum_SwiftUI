import KernelCore
import ProviderDocsView
import CisumUIComponents
import MagicPlayMan
import PluginAudio
import ProviderScene
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
    nonisolated(unsafe) private var listViewModel: AudioListViewModel?
    nonisolated(unsafe) private var rootViewModel: AudioDBRootViewModel?
    nonisolated(unsafe) private var dbViewModel: AudioDBViewModel?
    nonisolated(unsafe) private var databaseObserver: AudioDatabaseObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioDBPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioDBPluginManualView() })
        }
    }

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        guard let scene = kernel.resolveProvider((any SceneProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "SceneProviding")
        }
        sceneBox.scene = scene
        installState(kernel: kernel)
    }

    @MainActor
    public func onEnable(kernel: CisumKernel) async throws {
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
                demoMode: demoMode
            )),
            String(localized: "Music Repository", bundle: .module)
        )
    }

    // MARK: - State assembly

    /// 创建并持有音频数据库的 ViewModel 与数据库观察者（幂等）。
    @MainActor
    private func installState(kernel: CisumKernel) {
        guard listViewModel == nil else { return }

        let list = AudioListViewModel(
            audioRepo: { await AudioPlugin.getAudioRepoAsync() }
        )
        let root = AudioDBRootViewModel(
            audioRepo: { await AudioPlugin.getAudioRepoAsync() },
            showDBView: { kernel.appState?.showDBView() ?? () }
        )
        let db = AudioDBViewModel()
        let observer = AudioDatabaseObserver(list: list, root: root, db: db)

        listViewModel = list
        rootViewModel = root
        dbViewModel = db
        databaseObserver = observer
    }

    @MainActor
    private func teardownState() {
        databaseObserver?.cancel()
        databaseObserver = nil
        listViewModel = nil
        rootViewModel = nil
        dbViewModel = nil
    }

    /// 返回当前持有的 ViewModel；若尚未安装（启动前或插件被禁用），
    /// 提供临时空实例保证 View 贡献可用。
    @MainActor
    private func resolveViewModels() -> (list: AudioListViewModel, root: AudioDBRootViewModel, db: AudioDBViewModel) {
        if let listViewModel, let rootViewModel, let dbViewModel {
            return (listViewModel, rootViewModel, dbViewModel)
        }
        let list = AudioListViewModel(audioRepo: { await AudioPlugin.getAudioRepoAsync() })
        let root = AudioDBRootViewModel(audioRepo: { await AudioPlugin.getAudioRepoAsync() }, showDBView: {})
        let db = AudioDBViewModel()
        listViewModel = list
        rootViewModel = root
        dbViewModel = db
        return (list, root, db)
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

    private let content: Content

    init(
        listViewModel: AudioListViewModel,
        rootViewModel: AudioDBRootViewModel,
        dbViewModel: AudioDBViewModel,
        @ViewBuilder content: () -> Content
    ) {
        self.listViewModel = listViewModel
        self.rootViewModel = rootViewModel
        self.dbViewModel = dbViewModel
        self.content = content()
    }

    var body: some View {
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
    }

    private var dependencies: AudioDBDependencies {
        AudioDBDependencies(
            audioRepo: { await AudioPlugin.getAudioRepoAsync() },
            audioDisk: { AudioPlugin.getAudioDisk() },
            supportedExtensions: AudioPlugin.supportedExtensions,
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
    let demoMode: Bool

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
            audioRepo: { await AudioPlugin.getAudioRepoAsync() },
            audioDisk: { AudioPlugin.getAudioDisk() },
            supportedExtensions: AudioPlugin.supportedExtensions,
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
