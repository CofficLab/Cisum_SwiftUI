import CisumKernel
import CisumUI
import SwiftUI

/// 设置窗口：聚合插件贡献的设置项，双栏布局（对齐 Lumi 设置窗口）。
///
/// - 左侧：插件 `addSettingNavigationItem` 贡献的导航入口；另有「插件设置」
///   聚合项承载全部 `addSettingView` 视图。
/// - 右侧：选中导航入口的内容，或全部 `addSettingView` 视图的滚动列表。
///
/// 内核复用 `createMainKernel` 返回的主内核（幂等，与主窗口共享同一实例），
/// 因此主题切换等状态在设置窗口与主窗口间即时同步。
public struct SettingsWindow: View {
    /// 「插件设置」聚合项的稳定 ID（优先于插件导航项）。
    private static let allSettingsID = "cisum.settings.all"

    @State private var kernel: CisumKernel?
    @State private var initializationError: Error?
    @State private var selection: String?

    private let configuration: CisumFactoryConfiguration

    public init(configuration: CisumFactoryConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        Group {
            if let kernel {
                settingsContent(kernel: kernel)
            } else if let initializationError {
                ContentUnavailableView(
                    "设置加载失败",
                    systemImage: "exclamationmark.triangle",
                    description: Text(initializationError.localizedDescription)
                )
            } else {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await loadKernel() }
    }

    private func loadKernel() async {
        guard kernel == nil, initializationError == nil else { return }
        do {
            kernel = try await CisumFactory.createMainKernel(configuration: configuration)
            selection = Self.allSettingsID
        } catch {
            initializationError = error
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func settingsContent(kernel: CisumKernel) -> some View {
        let navItems = kernel.plugin?.getSettingNavigationItems() ?? []
        let settingViews = kernel.plugin?.getSettingViews() ?? []
        let hasContent = !navItems.isEmpty || !settingViews.isEmpty

        if hasContent {
            NavigationSplitView {
                List(selection: $selection) {
                    if !settingViews.isEmpty {
                        Label("插件设置", systemImage: "puzzlepiece.extension")
                            .tag(Self.allSettingsID)
                    }
                    ForEach(navItems) { item in
                        Label(item.title, systemImage: item.iconName)
                            .tag(item.id)
                    }
                }
                .navigationSplitViewColumnWidth(min: 200, ideal: 230)
            } detail: {
                detailContent(settingViews: settingViews, navItems: navItems)
            }
            .modifier(KernelEnvironmentModifier(kernel: kernel))
        } else {
            ContentUnavailableView(
                "暂无可用设置",
                systemImage: "gearshape",
                description: Text("插件暂未贡献任何设置项")
            )
            .modifier(KernelEnvironmentModifier(kernel: kernel))
        }
    }

    @ViewBuilder
    private func detailContent(
        settingViews: [AnyView],
        navItems: [PluginSettingNavigationItem]
    ) -> some View {
        if let selected = navItems.first(where: { $0.id == selection }) {
            selected.destination
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !settingViews.isEmpty {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 28) {
                    ForEach(Array(settingViews.enumerated()), id: \.offset) { _, view in
                        view
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            ContentUnavailableView(
                "选择一个设置项",
                systemImage: "gearshape",
                description: Text("从左侧选择要查看的设置")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// 将内核 Provider 投影为插件设置视图依赖的环境值（与主窗口 `KernelRootView` 一致）。
private struct KernelEnvironmentModifier: ViewModifier {
    @ObservedObject var kernel: CisumKernel

    func body(content: Content) -> some View {
        content
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
                    CisumFactory.mainKernel?.storage?.resetStorageLocation()
                }
            })
    }
}
