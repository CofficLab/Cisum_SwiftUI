import CisumUI
import OSLog
import SwiftUI

struct AppTabView: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📑"
    nonisolated static let verbose = false

    @EnvironmentObject var p: PluginProvider
    @Environment(\.demoMode) var isDemoMode

    @State private var selectedTabID: String = "0"
    @State private var cachedTabViews: [(view: AnyView, label: String)] = []
    @State private var selectedTabIndex: Int = 0
    @State private var selectedDemoTabID: String = "0"

    var body: some View {
        Group {
            #if os(macOS)
                buildCustomTabView()
                    .onChange(of: p.currentSceneName, onChangeOfCurrentScene)
            #else
                if isDemoMode {
                    buildCustomTabView()
                        .onChange(of: p.currentSceneName, onChangeOfCurrentScene)
                } else {
                    buildTabView()
                        .onChange(of: p.currentSceneName, onChangeOfCurrentScene)
                }
            #endif
        }
        .onAppear(perform: refreshTabs)
        .onChange(of: isDemoMode) { _, _ in
            refreshTabs()
        }
    }
}

// MARK: - Builder

extension AppTabView {
    /// 构建 TabView（正常模式）
    func buildTabView() -> AnyView {
        let tabView = TabView(selection: $selectedTabID) {
            ForEach(Array(cachedTabViews.enumerated()), id: \.offset) { index, item in
                item.view
                    .tag(String(index))
                    .tabItem {
                        Label(item.label, systemImage: .cisumIconMusicNote)
                    }
            }

            SettingView()
                .tag("Setting")
                .tabItem {
                    Label(title: { Text("Settings") }, icon: { Image(systemName: "gear") })
                }
        }
        .frame(maxHeight: .infinity)
        #if os(macOS)
            .padding(.top, 2)
        #endif
            .background(.background)

        return AnyView(tabView)
    }

    /// 构建自定义 TabView（Demo 模式）
    func buildCustomTabView() -> some View {
        let settingTab = (view: AnyView(SettingView().environmentObject(p)), label: String(localized: "Settings"))
        let allTabs = cachedTabViews + [settingTab]

        let tabBar = AppTabBar(
            tabs: Array(allTabs.enumerated()).map { index, item in
                AppTabBar.Tab(
                    title: item.label,
                    icon: index < cachedTabViews.count ? .cisumIconMusicNote : "gear",
                    id: String(index)
                )
            },
            selectedTab: Binding(
                get: { selectedDemoTabID },
                set: { newValue in
                    let normalizedIndex = Self.normalizedCustomTabIndex(from: newValue, tabCount: allTabs.count)
                    selectedDemoTabID = String(normalizedIndex)
                    selectedTabIndex = normalizedIndex
                }
            ),
            centered: true
        )
        .padding(6)
        .cisumPt1()
        .cisumDivider(spacing: 2)

        let contentView: AnyView = {
            guard (0..<allTabs.count).contains(selectedTabIndex) else {
                return AnyView(EmptyView())
            }
            return allTabs[selectedTabIndex].view
        }()

        return GeometryReader { _ in
            VStack(spacing: 0) {
                // 上部分：HStack 展示各个标签
                tabBar

                // 下部分：显示选中标签对应的 view
                contentView
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            .background(.background)
        }
    }

    /// 构建标签按钮
    private func tabButton(for item: (view: AnyView, label: String), at index: Int, isPluginTab: Bool) -> some View {
        let isSelected = selectedTabIndex == index

        return Button(action: {
            withAnimation {
                selectedTabIndex = index
            }
        }) {
            VStack(spacing: 4) {
                Text(item.label)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .foregroundColor(isSelected ? .accentColor : .secondary)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .cisumRoundedMedium()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Event Handler

extension AppTabView {
    /// 当前场景变化时的处理（事件驱动）
    func onChangeOfCurrentScene(oldValue: String?, newValue: String?) {
        if Self.verbose {
            os_log("\(self.t)🔄 场景变化事件: \(oldValue ?? "nil") -> \(newValue ?? "nil")")
            os_log("\(self.t)📱 开始重新构建 TabView...")
        }

        refreshTabs()

        if Self.verbose {
            os_log("\(self.t)✅ TabView 已更新完成")
        }
    }

    private func refreshTabs() {
        cachedTabViews = p.getTabViews(reason: self.className, demoMode: isDemoMode)

        let tabCount = cachedTabViews.count
        let normalizedTabID = Self.normalizedTabID(from: selectedTabID, tabCount: tabCount)
        if selectedTabID != normalizedTabID {
            selectedTabID = normalizedTabID
        }

        resetCustomTabSelection()
    }

    private func resetCustomTabSelection() {
        let fallbackID = "0"
        guard selectedDemoTabID != fallbackID || selectedTabIndex != 0 else { return }

        selectedDemoTabID = fallbackID
        selectedTabIndex = 0
    }

    nonisolated static func normalizedTabID(from tabID: String, tabCount: Int) -> String {
        guard tabCount > 0 else { return "Setting" }
        if tabID == "Setting" { return tabID }
        guard let index = Int(tabID), (0..<tabCount).contains(index) else { return "0" }
        return tabID
    }

    nonisolated static func normalizedCustomTabIndex(from tabID: String, tabCount: Int) -> Int {
        guard let index = Int(tabID), (0..<tabCount).contains(index) else { return 0 }
        return index
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}

#Preview("App - Demo") {
    ContentView()
        .inRootView()
        .inDemoMode()
        .withDebugBar()
}

#Preview("App Store Album Art") {
    AppStoreAlbumArt()
        .cisumPreviewContainer(.cisumMacBook13, scale: 1)
}
