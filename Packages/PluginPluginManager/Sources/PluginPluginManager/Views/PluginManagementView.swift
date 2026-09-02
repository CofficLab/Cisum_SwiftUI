import CisumUIComponents
import ProviderPluginManaging
import SwiftUI

/// 插件管理设置页（复刻 Lumi `PluginPluginManager.PluginManagementView`）。
///
/// 两栏布局：左侧为插件列表（搜索过滤），右侧为选中插件的详情与启用状态。
/// 数据源：`PluginManaging` Provider。列表与详情直接读取 Provider 的状态，
/// 并监听 `.cisumEnabledPluginsDidChange` 通知在启停后自动刷新。
struct PluginManagementView: View {
    let manager: any PluginManaging

    @State private var selectedPluginID: String?
    @State private var searchText = ""
    /// 插件启停变化版本号：收到 `.cisumEnabledPluginsDidChange` 时 +1，强制重建。
    @State private var revision = 0

    /// 列表数据源：仅显示用户可配置的插件（对齐 Lumi 行为）。
    /// `alwaysOn` / `disabled` 不可配置，展示在列表中没有可操作控件，故过滤掉，
    /// 只保留 `optOut` / `optIn`（`allowUserToggle == true`）。
    private var plugins: [any SuperPlugin] {
        manager.configurablePlugins
    }

    /// 按搜索词过滤后的插件。
    private var filteredPlugins: [any SuperPlugin] {
        let keyword = searchText.trimmingCharacters(in: .whitespaces)
        guard !keyword.isEmpty else { return plugins }
        return plugins.filter { plugin in
            let metadata = type(of: plugin).metadata
            return metadata.displayName.localizedCaseInsensitiveContains(keyword)
                || metadata.description.localizedCaseInsensitiveContains(keyword)
                || plugin.id.localizedCaseInsensitiveContains(keyword)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            searchField

            HStack(spacing: 0) {
                pluginListPane
                    .frame(width: 280)
                    .frame(maxHeight: .infinity)

                Divider()

                pluginDetailPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(minHeight: 420, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.separator, lineWidth: 1)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            if selectedPluginID == nil {
                selectedPluginID = filteredPlugins.first?.id
            }
        }
        .onChange(of: filteredPlugins.map(\.id)) { _, ids in
            guard let selectedPluginID, ids.contains(selectedPluginID) else {
                self.selectedPluginID = ids.first
                return
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .cisumEnabledPluginsDidChange)) { _ in
            // 插件启停后重建列表（isEnabled 状态、可用插件集合都可能变化）。
            revision += 1
        }
    }

    // MARK: - Subviews

    /// 顶部统计：总数 / 启用数。
    private var header: some View {
        HStack(spacing: 12) {
            Label("插件管理", systemImage: "puzzlepiece.extension")
                .font(.headline)
            Spacer()
            Text("\(plugins.count) 个插件 · \(enabledCount) 个已启用")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var enabledCount: Int {
        plugins.filter { manager.isEnabled(id: $0.id) }.count
    }

    /// 搜索框。
    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("搜索插件", text: $searchText)
                .textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
    }

    /// 左侧插件列表。
    private var pluginListPane: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(filteredPlugins, id: \.id) { plugin in
                    PluginListRow(
                        plugin: plugin,
                        isSelected: selectedPluginID == plugin.id,
                        isEnabled: manager.isEnabled(id: plugin.id)
                    ) {
                        selectedPluginID = plugin.id
                    }
                }
            }
            .padding(6)
        }
        .background(.background)
    }

    /// 右侧详情面板。
    @ViewBuilder
    private var pluginDetailPane: some View {
        if let plugin = filteredPlugins.first(where: { $0.id == selectedPluginID }) {
            PluginSettingsDetailView(manager: manager, plugin: plugin)
                .id(revision)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "puzzlepiece.extension")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                Text("选择一个插件")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
