import CisumKernel
import CisumUIComponents
import ProviderAppState
import ProviderPlugin
import ProviderStorage
import ProviderTheme
import SwiftUI

/// 设置窗口：聚合插件贡献的设置项，双栏布局（对齐 Lumi `ProviderSettingView`）。
///
/// 本视图只依赖各 Provider 能力契约（`PluginProviding` / `AppStateProviding` /
/// `ThemeProviding` / `StorageProviding`），不依赖内核或工厂具体类型；由宿主
/// （CisumFactory）从内核解析各 Provider 后注入。
///
/// - 左侧：插件 `addSettingNavigationItem` 贡献的导航入口；另有「插件设置」
///   聚合项承载全部 `addSettingView` 视图。
/// - 右侧：选中导航入口的内容，或全部 `addSettingView` 视图的滚动列表。
public struct SettingsWindow: View {
    /// 「插件设置」聚合项的稳定 ID（优先于插件导航项）。
    private static let allSettingsID = "cisum.settings.all"

    @State private var selection: String

    /// 插件启停变化版本号：收到 `.cisumEnabledPluginsDidChange` 时 +1，强制重建
    /// 设置项列表（禁用某插件后其贡献的设置项会消失）。
    @State private var revision = 0

    private let settings: (any PluginProviding)?
    private let appState: (any AppStateProviding)?
    private let theme: (any ThemeProviding)?
    private let storage: (any StorageProviding)?

    public init(
        settings: (any PluginProviding)?,
        appState: (any AppStateProviding)?,
        theme: (any ThemeProviding)?,
        storage: (any StorageProviding)?
    ) {
        self.settings = settings
        self.appState = appState
        self.theme = theme
        self.storage = storage
        self._selection = State(initialValue: Self.allSettingsID)
    }

    public var body: some View {
        let navItems = settings?.getSettingNavigationItems() ?? []
        let settingViews = settings?.getSettingViews() ?? []
        let hasContent = !navItems.isEmpty || !settingViews.isEmpty

        Group {
            if hasContent {
                #if os(macOS)
                macOSSplitView(settingViews: settingViews, navItems: navItems)
                #else
                iOSList(settingViews: settingViews, navItems: navItems)
                #endif
            } else {
                ContentUnavailableView(
                    "暂无可用设置",
                    systemImage: "gearshape",
                    description: Text("插件暂未贡献任何设置项")
                )
            }
        }
        // 插件启停变化时重建设置项列表。
        .id(revision)
        .onReceive(NotificationCenter.default.publisher(for: .cisumEnabledPluginsDidChange)) { _ in
            revision += 1
        }
        .modifier(KernelEnvironmentModifier(
            settings: settings,
            appState: appState,
            theme: theme,
            storage: storage
        ))
        .onAppear {
            // 无「插件设置」聚合项且存在导航项时，默认选中首个导航入口。
            if settingViews.isEmpty, let first = navItems.first, selection == Self.allSettingsID {
                selection = first.id
            }
        }
    }

    #if os(macOS)
    /// macOS：双栏 + `List(selection:)`（菜单栏设置窗口的标准交互）。
    private func macOSSplitView(
        settingViews: [AnyView],
        navItems: [PluginSettingNavigationItem]
    ) -> some View {
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
    }
    #else
    /// iOS：设置窗口仅在 macOS 有菜单栏入口，此处只保证可编译并展示全部设置项。
    private func iOSList(
        settingViews: [AnyView],
        navItems: [PluginSettingNavigationItem]
    ) -> some View {
        NavigationSplitView {
            List {
                Section("设置") {
                    ForEach(navItems) { item in
                        Label(item.title, systemImage: item.iconName)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 230)
        } detail: {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 28) {
                    if settingViews.isEmpty {
                        Text("暂无可用设置")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(Array(settingViews.enumerated()), id: \.offset) { _, view in
                        view
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    #endif

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

/// 将 Provider 能力投影为插件设置视图依赖的环境值（与主窗口 `KernelRootView` 一致）。
private struct KernelEnvironmentModifier: ViewModifier {
    let settings: (any PluginProviding)?
    let appState: (any AppStateProviding)?
    let theme: (any ThemeProviding)?
    let storage: (any StorageProviding)?

    func body(content: Content) -> some View {
        content
            .environment(\.currentSceneName, settings?.currentSceneName)
            .environment(\.demoMode, appState?.isDemoMode ?? false)
            .environment(
                \.appIsImporting,
                Binding(
                    get: { appState?.isImporting ?? false },
                    set: { appState?.setImporting($0) }
                )
            )
            .environment(\.showAudioDBViewAction, { appState?.showDBView() })
            .environment(\.pluginThemes, theme?.allThemeContributions ?? [])
            .environment(\.currentPluginThemeId, theme?.selectedThemeID ?? "")
            .environment(\.selectPluginThemeAction, { themeID in theme?.selectTheme(themeID) })
            .environment(\.resetSettingsAction, {
                Task { @MainActor in
                    storage?.resetStorageLocation()
                }
            })
    }
}
