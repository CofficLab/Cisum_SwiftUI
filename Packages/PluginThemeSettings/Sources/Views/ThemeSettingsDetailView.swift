import CisumUIComponents
import ProviderTheme
import SwiftUI

/// 外观设置详情页（对齐 Lumi `ThemeSettingsDetailView` 双栏版式）。
///
/// 作为设置窗口「外观」导航项的 destination：
/// - 顶部：主题统计 + 当前主题；
/// - 左侧：搜索 + 外观筛选 + 主题列表；
/// - 右侧：选中主题的大预览（图标 / 描述 / 色板 / 应用按钮）。
///
/// 全部使用 LumiUI 组件（`AppSettingsContentScaffold` / `AppListRow` /
/// `AppSearchBar` / `AppEmptyState` / `AppButton` / `AppTag` / `AppDivider`），
/// 与 Lumi 自身实现一致，无需新增组件。
struct ThemeSettingsDetailView: View {
    @StateObject private var viewModel: ThemeSettingsViewModel

    @State private var selectedID: String?
    @State private var searchText = ""
    @State private var appearanceFilter: ThemeAppearanceFilter = .all

    init(theme: (any ThemeProviding)?) {
        _viewModel = StateObject(wrappedValue: ThemeSettingsViewModel(theme: theme))
    }

    private var themes: [LumiUIThemeContribution] { viewModel.themes }
    private var currentThemeId: String { viewModel.currentThemeID }

    private var filteredThemes: [LumiUIThemeContribution] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return themes.filter { item in
            appearanceFilter.matches(item.appearanceKind)
                && (keyword.isEmpty
                    || item.displayName.localizedCaseInsensitiveContains(keyword)
                    || item.description.localizedCaseInsensitiveContains(keyword)
                    || item.id.localizedCaseInsensitiveContains(keyword))
        }
    }

    private var selectedTheme: LumiUIThemeContribution? {
        if let selectedID, let item = themes.first(where: { $0.id == selectedID }) {
            return item
        }
        return filteredThemes.first ?? themes.first
    }

    var body: some View {
        AppSettingsContentScaffold(scrollsContent: false, maxContentWidth: nil) {
            VStack(alignment: .leading, spacing: 14) {
                headerStats

                HStack(spacing: 0) {
                    themeListPane
                        .frame(width: 300)
                    AppDivider(.vertical)
                    themeDetailPane
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(minHeight: 420, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onAppear {
            selectedID = currentThemeId.isEmpty ? (selectedTheme?.id) : currentThemeId
        }
        .onChange(of: filteredThemes.map(\.id)) { _, ids in
            guard let selectedID, ids.contains(selectedID) else {
                self.selectedID = ids.first
                return
            }
        }
    }

    private var headerStats: some View {
        HStack(spacing: 10) {
            Label("\(themes.count) 个主题", systemImage: "paintpalette")
            if !currentThemeId.isEmpty,
               let active = themes.first(where: { $0.id == currentThemeId }) {
                Text("当前：\(active.displayName)")
            }
            Spacer()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var themeListPane: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                AppSearchBar(text: $searchText, placeholder: "搜索主题")
                Picker("主题类型", selection: $appearanceFilter) {
                    ForEach(ThemeAppearanceFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            .padding(12)

            AppDivider()

            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(filteredThemes) { item in themeListRow(item) }
                    if filteredThemes.isEmpty {
                        AppEmptyState(icon: "magnifyingglass", title: "没有找到主题")
                            .padding(.vertical, 32)
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: .infinity)
        }
        .appSurface(style: .panel, cornerRadius: 0)
    }

    private func themeListRow(_ item: LumiUIThemeContribution) -> some View {
        let isSelected = selectedTheme?.id == item.id
        let isActive = currentThemeId == item.id
        return AppListRow(isSelected: isSelected, action: {
            withAnimation(.easeInOut(duration: 0.2)) { selectedID = item.id }
        }) {
            HStack(alignment: .top, spacing: 10) {
                VStack(spacing: 6) {
                    Image(systemName: item.iconName)
                        .font(.appBody)
                        .foregroundStyle(item.iconColor)
                        .frame(width: 22, height: 22)
                    Circle()
                        .fill(isActive ? Color.green : Color.gray.opacity(0.45))
                        .frame(width: 6, height: 6)
                }
                .frame(width: 22)

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.displayName)
                        .font(.appCaptionEmphasized)
                        .lineLimit(1)
                    Text(item.description)
                        .font(.appMicro)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private var themeDetailPane: some View {
        if let selectedTheme {
            ThemePreviewPane(
                item: selectedTheme,
                isActive: currentThemeId == selectedTheme.id,
                onApply: { viewModel.selectTheme(selectedTheme.id) }
            )
        } else {
            AppEmptyState(icon: "paintpalette", title: "选择一个主题")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// 右侧主题预览（对齐 Lumi `ThemePreviewPane`，配色取自 chrome 主题的
/// accent / atmosphere 色）。
private struct ThemePreviewPane: View {
    let item: LumiUIThemeContribution
    let isActive: Bool
    let onApply: () -> Void

    private var accent: (primary: Color, secondary: Color, tertiary: Color) {
        item.chromeTheme.accentColors()
    }

    private var atmosphere: (deep: Color, medium: Color, light: Color) {
        item.chromeTheme.atmosphereColors()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                AppDivider()
                preview
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(atmosphere.medium)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: item.iconName)
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(item.iconColor)
                .frame(width: 64, height: 64)
                .background(accent.primary.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 7) {
                Text(item.displayName)
                    .font(.title2.weight(.semibold))
                Text(item.description)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(appearanceLabel)
                    .font(.appMicro)
                    .foregroundStyle(.secondary.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isActive {
                AppTag("当前使用", style: .accent)
            } else {
                AppButton("使用此主题", systemImage: "paintbrush.fill", style: .primary, size: .small, action: onApply)
            }
        }
    }

    private var appearanceLabel: String {
        switch item.appearanceKind {
        case .dark:
            return "深色主题"
        case .light:
            return "浅色主题"
        case .system:
            return "跟随系统外观"
        }
    }

    private var preview: some View {
        AppSettingsSection(title: "组件预览", subtitle: "查看常用组件在此主题下的效果", spacing: 12) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    previewButton("主要操作", fill: accent.primary, foreground: .white)
                    previewButton("次要操作", fill: atmosphere.light, foreground: .primary)
                    previewButton("辅助操作", fill: accent.secondary.opacity(0.18), foreground: accent.secondary)
                }
                HStack(spacing: 10) {
                    colorSwatch("主色", accent.primary)
                    colorSwatch("辅色", accent.secondary)
                    colorSwatch("背景", atmosphere.medium)
                    colorSwatch("抬升", atmosphere.light)
                }
            }
            .padding(16)
            .background(atmosphere.light.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func previewButton(_ title: String, fill: Color, foreground: Color) -> some View {
        Text(title)
            .font(.appMicroEmphasized)
            .foregroundStyle(foreground)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func colorSwatch(_ title: String, _ color: Color) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color)
                .frame(width: 44, height: 28)
            Text(title)
                .font(.appMicro)
                .foregroundStyle(.secondary)
        }
    }
}
