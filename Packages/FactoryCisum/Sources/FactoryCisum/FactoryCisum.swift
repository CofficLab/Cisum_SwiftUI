import CisumKernel
import CisumUIComponents
import Foundation
import MagicKit
import MagicPlayMan
import OSLog
import ProviderContentView
import ProviderRootView
import ProviderSettings
import ProviderToolbar
import SwiftUI

/// Cisum 应用组装工厂（Composition Root）。
///
/// 唯一知道"如何组装应用"的地方：
/// - 内核生命周期管理（创建、启动、销毁）
/// - 基础设施 Provider 注册（AppState / Playback / Theme / Cloud / Device）
/// - 窗口 / 命令工厂方法
///
/// 插件清单由宿主（app target）通过 `FactoryCisumConfiguration` 传入，Factory
/// 本身不依赖任何具体插件。
///
/// ## 核心流程
///
/// ```swift
/// let kernel = try await FactoryCisum.createMainKernel(configuration: config)
///
/// // 内部:
/// CisumKernel()
///   -> initializePlugins(config.plugins)
///   -> 注册基础设施 Provider
///   -> kernel.startup()
///       -> pluginManager.onBoot(kernel:)   // 插件注册 Storage 等服务
///       -> 必需服务校验
///       -> pluginManager.onReady(kernel:)  // 插件桥接 Host / 异步初始化
///       -> registerPluginUIContributions   // 失效缓存 + 主题同步
/// ```
@MainActor
public enum CisumBuilder: SuperLog {
    nonisolated static let logger = Logger(subsystem: "com.coffic.cisum", category: "factory")
    nonisolated public static let emoji = "🏭"
    nonisolated static let verbose = true

    // MARK: - Kernel Registry

    /// 已创建的内核列表（支持多内核）。
    public private(set) static var kernels: [CisumKernel] = []

    /// 主内核，取内核列表中的首个。
    public static var mainKernel: CisumKernel? { kernels.first }

    // MARK: - Kernel Factory

    /// 创建并启动一个新内核。
    ///
    /// 流程：
    /// 1. 通过 `PluginFactory` 装配插件清单并初始化（默认 `DefaultPluginFactory`
    ///    直接装配 Cisum 全部内置插件；宿主可传 `SelectedPluginFactory` 等
    ///    自定义实现覆盖）
    /// 2. 注册基础设施 Provider（非插件拥有的跨切面服务）
    /// 3. 启动内核（两阶段生命周期 + 服务校验 + 贡献聚合）
    /// 4. 恢复持久化的当前场景
    /// 5. 订阅插件启用/禁用变更
    public static func createKernel(
        configuration: FactoryCisumConfiguration = FactoryCisumConfiguration(),
        pluginFactory: (any PluginFactory)? = nil
    ) async throws -> CisumKernel {
        let kernel = CisumKernel()

        // 1. 通过插件工厂装配插件清单（对齐 Lumi `pluginFactory.makePlugins()`）
        let factory = pluginFactory ?? DefaultPluginFactory()
        kernel.pluginManager.initializePlugins(factory.makePlugins())

        // 2. 注册基础设施 Provider
        let appState = BasicAppStateService()
        kernel.registerAppStateService(appState)

        let pluginService = PluginContributionService(manager: kernel.pluginManager)
        kernel.registerPluginService(pluginService)

        let playMan = MagicPlayMan()
        kernel.registerPlayback(playMan)

        let themeService = ThemeService(contributionsProvider: { [weak kernel] in
            kernel?.plugin?.getThemeContributions() ?? []
        })
        kernel.registerThemeService(themeService)

        kernel.registerCloudService(CloudService())
        kernel.registerDeviceService(DeviceService())

        // 3. 启动内核（插件 onBoot 注册 Storage 等服务 → 校验 → onReady → 贡献聚合）
        try await kernel.startup()

        // 2.5 注册视图 Provider（对齐 Lumi：视图区域各自为独立的 Provider 契约，
        // 默认实现在此注册进内核；Factory 组装时只做 resolveProvider + 注入 + makeRootView）
        registerViewProviders(into: kernel)

        // 4. 恢复当前场景
        pluginService.restoreCurrentScene()

        // 5. 订阅插件变更
        subscribeToPluginChanges(kernel: kernel)

        kernels.append(kernel)
        logger.info("\(Self.t)Kernel created and started successfully")
        return kernel
    }

    /// 创建主内核（幂等：首次调用以传入的 configuration 创建，后续调用返回已有实例）。
    public static func createMainKernel(configuration: FactoryCisumConfiguration) async throws -> CisumKernel {
        if let existing = mainKernel {
            logger.info("\(Self.t)Main kernel already exists, returning existing instance")
            return existing
        }
        return try await createKernel(configuration: configuration)
    }

    /// 销毁指定内核。
    public static func destroyKernel(_ kernel: CisumKernel) {
        kernels.removeAll { $0 === kernel }
    }

    /// 销毁所有内核。
    public static func destroyAllKernels() {
        kernels.removeAll()
    }

    // MARK: - Window Factory

    /// 创建主窗口视图。
    public static func makeMainWindow(configuration: FactoryCisumConfiguration) -> some View {
        WindowMain(configuration: configuration)
    }

    // MARK: - Settings Window Factory

    /// 创建设置窗口视图。
    ///
    /// 设置窗口复用 `createMainKernel` 返回的主内核（幂等，与主窗口共享同一实例）。
    /// 设置窗口 UI 本体在独立的 `ProviderSettings` 包中（只依赖 Provider 契约），
    /// 此处仅做接线：创建内核 → 解析各 Provider → 注入设置窗口。
    public static func makeSettingsWindow(configuration: FactoryCisumConfiguration) -> some View {
        SettingsWindowHost(configuration: configuration)
    }

    // MARK: - Commands Factory

    /// 创建应用命令菜单。
    ///
    /// 命令装配集中在 Factory 包内（对齐 Lumi `FactoryLumi/AppCommands.swift`），
    /// 宿主只需 `.commands { FactoryCisum.makeCommands() }`。
    public static func makeCommands() -> some Commands {
        CisumAppCommands()
    }

    // MARK: - View Assembly

    /// 注册视图 Provider 默认实现（对齐 Lumi `DefaultProviderFactory` 的
    /// `makeXxxProvider()` 方法族）。
    ///
    /// 各视图区域（根布局 / 内容区 / 工具栏）是独立的 Provider 契约，
    /// 默认实现注册进内核；Factory 组装时只做解析 + 注入 + makeRootView。
    private static func registerViewProviders(into kernel: CisumKernel) {
        kernel.registerProvider((any RootViewProviding).self, DefaultRootViewProviding(kernel: kernel))
        kernel.registerProvider((any ContentViewProviding).self, DefaultContentViewProviding())
        kernel.registerProvider((any ToolbarProviding).self, DefaultToolbarProviding(kernel: kernel))
    }

    /// 组装主视图（对齐 Lumi `DefaultViewFactory.makeMainView(kernel:)`）。
    ///
    /// 视图组装逻辑集中在此：解析 `RootViewProviding` → 注入各区域视图
    /// （内容区来自 `ContentViewProviding`、工具栏来自 `ToolbarProviding`）→
    /// 返回 `makeRootView()`。宿主只需要一个视图，无需关心各 Provider 如何组合。
    @MainActor
    public static func assembleMainView(kernel: CisumKernel) -> AnyView {
        guard let root = kernel.resolveProvider((any RootViewProviding).self) else {
            return AnyView(Text("RootViewProviding not registered"))
        }

        if let content = kernel.resolveProvider((any ContentViewProviding).self) {
            refreshContentTabs(content, kernel: kernel)
            root.setContentView(content.makeContentView())
        }
        if let toolbar = kernel.resolveProvider((any ToolbarProviding).self) {
            root.setToolbarContent(toolbar.makeToolbarView())
        }
        return root.makeRootView()
    }

    /// 把插件贡献的内容 Tab 注入 `ContentViewProviding`。
    ///
    /// 对齐 Lumi 插件通过 Provider 注入内容的范式；Cisum 侧由
    /// `PluginContributionService` 聚合插件贡献，此处转成 `ContentTabItem` 注入。
    @MainActor
    private static func refreshContentTabs(_ content: any ContentViewProviding, kernel: CisumKernel) {
        let contribution = kernel.plugin?.getTabViews(
            reason: "AppTabView",
            demoMode: kernel.appState?.isDemoMode ?? false
        ) ?? []
        content.setTabs(
            contribution.enumerated().map { index, tab in
                ContentTabItem(
                    id: tab.label,
                    title: tab.label,
                    order: index,
                    content: tab.view
                )
            }
        )
    }

    // MARK: - Private

    /// 订阅插件启用/禁用变更通知，触发贡献重建。
    private static func subscribeToPluginChanges(kernel: CisumKernel) {
        NotificationCenter.default.addObserver(
            forName: .cisumEnabledPluginsDidChange,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                kernel.pluginManager.rebuildAllContributions(in: kernel)
            }
        }
    }
}

/// Factory 的设置窗口接线视图。
///
/// 负责创建主内核，并在内核就绪后把各 Provider 解析出来注入 `ProviderSettings.SettingsWindow`。
/// 设置窗口 UI 本身不感知内核/工厂，与主窗口共享同一内核实例。
public struct SettingsWindowHost: View {
    @State private var kernel: CisumKernel?
    @State private var initializationError: Error?
    @State private var isInitializing = true
    private let configuration: FactoryCisumConfiguration

    public init(configuration: FactoryCisumConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        Group {
            if isInitializing {
                KernelLoadingView()
            } else if let initializationError {
                KernelErrorView(error: initializationError)
            } else if let kernel {
                ProviderSettings.SettingsWindow(
                    settings: kernel.plugin,
                    appState: kernel.appState,
                    theme: kernel.theme,
                    storage: kernel.storage
                )
            }
        }
        .task {
            await initializeKernel()
        }
    }

    private func initializeKernel() async {
        guard kernel == nil, initializationError == nil else { return }

        do {
            kernel = try await FactoryCisum.createMainKernel(configuration: configuration)
        } catch {
            initializationError = error
        }
        isInitializing = false
    }
}

/// Factory 的主窗口启动视图。
///
/// 负责创建 Kernel，并在 Kernel 准备完成后显示 `KernelRootView`。
public struct WindowMain: View {
    @State private var kernel: CisumKernel?
    @State private var initializationError: Error?
    @State private var isInitializing = true
    private let configuration: FactoryCisumConfiguration

    public init(configuration: FactoryCisumConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        Group {
            if isInitializing {
                KernelLoadingView()
            } else if let initializationError {
                KernelErrorView(error: initializationError)
            } else if let kernel {
                KernelRootView(kernel: kernel)
            }
        }
        .task {
            await initializeKernel()
        }
    }

    private func initializeKernel() async {
        guard kernel == nil, initializationError == nil else { return }

        do {
            kernel = try await FactoryCisum.createMainKernel(configuration: configuration)
        } catch {
            initializationError = error
        }
        isInitializing = false
    }
}

/// Factory 根视图桥接层。
///
/// 将内核 Provider 投影为 SwiftUI 环境值/环境对象，供仍以旧式环境读取的插件视图
/// 继续工作；并用插件的 RootView 包裹内部布局。Host 桥接彻底移除后，这里的兼容
/// 环境可进一步精简。
struct KernelRootView: View {
    @ObservedObject var kernel: CisumKernel
    /// 插件贡献版本号：插件启用/禁用变化时 +1，触发根视图重新组装。
    @State private var contributionRevision = 0

    var body: some View {
        rootContent
            // 插件贡献变化（.id 变化）时整棵子树重建，重新注入内容 Tab 等。
            .id(contributionRevision)
            .environment(\.currentSceneName, kernel.plugin?.currentSceneName)
            .environment(\.demoMode, kernel.appState?.isDemoMode ?? false)
            .environment(
                \.appIsImporting,
                Binding(
                    get: { kernel.appState?.isImporting ?? false },
                    set: { kernel.appState?.setImporting($0) }
                )
            )
            .environment(\.showAudioDBViewAction, { kernel.appState?.showDBView() })
            .environment(\.pluginThemes, kernel.theme?.allThemeContributions ?? [])
            .environment(\.currentPluginThemeId, kernel.theme?.selectedThemeID ?? "")
            .environment(\.selectPluginThemeAction, { themeID in kernel.theme?.selectTheme(themeID) })
            .environment(\.resetSettingsAction, {
                Task { @MainActor in
                    FactoryCisum.mainKernel?.storage?.resetStorageLocation()
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: .cisumEnabledPluginsDidChange)) { _ in
                contributionRevision += 1
            }
    }

    @ViewBuilder
    private var rootContent: some View {
        let content = FactoryCisum.assembleMainView(kernel: kernel)
        if let playMan = kernel.playback as? MagicPlayMan {
            wrap(content).environmentObject(playMan)
        } else {
            wrap(content)
        }
    }

    @ViewBuilder
    private func wrap(_ content: AnyView) -> some View {
        if let wrapped = kernel.plugin?.wrapWithCurrentRoot(content: { content }) {
            wrapped
        } else {
            content
        }
    }
}

private struct KernelLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading…")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct KernelErrorView: View {
    let error: Error

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Unable to start Cisum")
                .font(.title2)
            Text(error.localizedDescription)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 520)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 兼容别名。
public typealias FactoryCisum = CisumBuilder
