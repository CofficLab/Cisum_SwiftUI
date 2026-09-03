import CisumKernel
import CisumUIComponents
import ProviderAppState
import ProviderPlugin
import ProviderStorage
import ProviderTheme
import SwiftUI

/// 设置窗口：各插件贡献的一级导航入口，双栏布局（对齐 Lumi `ProviderSettingView`）。
///
/// 每个插件通过 `addSettingNavigationItem()` 贡献自己的设置入口（对齐 Lumi
/// 各插件 `SettingViewProviding.addEntries` 一个入口的范式），窗口不再聚合
/// 「插件设置」列表。
///
/// - 左侧：插件 `addSettingNavigationItem` 贡献的导航入口；
/// - 右侧：选中导航入口的内容。
///
/// 本视图只依赖各 Provider 能力契约（`PluginProviding` / `AppStateProviding` /
/// `ThemeProviding` / `StorageProviding`），不依赖内核或工厂具体类型；由宿主
/// （CisumFactory）从内核解析各 Provider 后注入。
public struct SettingsWindow: View {
    @State private var selection: String
    @LumiTheme private var appTheme

    /// 插件启停变化版本号：收到 `.cisumEnabledPluginsDidChange` 时 +1，强制重建
    /// 设置项列表（禁用某插件后其贡献的入口会消失）。
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
        self._selection = State(initialValue: "")
    }

    public var body: some View {
        let navItems = settings?.getSettingNavigationItems() ?? []
        // 未选中时默认展示首个入口。
        let currentSelection = selection.isEmpty ? (navItems.first?.id ?? "") : selection

        Group {
            if !navItems.isEmpty {
                #if os(macOS)
                macOSSplitView(navItems: navItems, currentSelection: currentSelection)
                #else
                iOSList(navItems: navItems, currentSelection: currentSelection)
                #endif
            } else {
                ContentUnavailableView(
                    "暂无可用设置",
                    systemImage: "gearshape",
                    description: Text("插件暂未贡献任何设置项")
                )
            }
        }
        // 插件启停变化时重建设置入口列表。
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
        .appThemedAppearance()
#if os(macOS)
        .overlay { ThemeWindowAppearanceBridge() }
#endif
    }

    #if os(macOS)
    /// macOS：双栏，侧边栏对齐 Lumi `AppSettingsSidebarContainer` 结构
    /// （顶部 app 信息 Header + 分隔线 + 入口列表，手动管理选中态）。
    private func macOSSplitView(
        navItems: [PluginSettingNavigationItem],
        currentSelection: String
    ) -> some View {
        NavigationSplitView {
            AppSettingsSidebarContainer(width: 220) {
                VStack(alignment: .leading, spacing: 10) {
                    SettingsHeaderView()

                    AppSettingsDivider()

                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(navItems) { item in
                                AppSettingsSidebarItem(
                                    title: item.title,
                                    systemImage: item.iconName,
                                    isSelected: currentSelection == item.id
                                ) {
                                    selection = item.id
                                }
                            }
                        }
                        .padding(.leading)
                        .padding(.trailing)
                    }

                    Spacer()
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 230)
        } detail: {
            detailContent(navItems: navItems, currentSelection: currentSelection)
        }
    }
    #else
    /// iOS：各插件一级入口同样可交互选择，右侧展示选中入口内容。
    private func iOSList(
        navItems: [PluginSettingNavigationItem],
        currentSelection: String
    ) -> some View {
        NavigationSplitView {
            List {
                Section("设置") {
                    ForEach(navItems) { item in
                        Button {
                            selection = item.id
                        } label: {
                            Label(item.title, systemImage: item.iconName)
                                .foregroundStyle(currentSelection == item.id ? appTheme.primary : appTheme.textPrimary)
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 230)
        } detail: {
            detailContent(navItems: navItems, currentSelection: currentSelection)
        }
    }
    #endif

    @ViewBuilder
    private func detailContent(
        navItems: [PluginSettingNavigationItem],
        currentSelection: String
    ) -> some View {
        if let selected = navItems.first(where: { $0.id == currentSelection }) {
            selected.destination
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    @LumiTheme private var appTheme
    let settings: (any PluginProviding)?
    let appState: (any AppStateProviding)?
    let theme: (any ThemeProviding)?
    let storage: (any StorageProviding)?

    func body(content: Content) -> some View {
        content
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
            .environment(\.currentPluginThemeId, appTheme.id)
            .environment(\.selectPluginThemeAction, { themeID in theme?.selectTheme(themeID) })
            .environment(\.resetSettingsAction, {
                Task { @MainActor in
                    storage?.resetStorageLocation()
                }
            })
    }
}
