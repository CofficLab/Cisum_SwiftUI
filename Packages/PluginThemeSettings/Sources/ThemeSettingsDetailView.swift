import CisumUIComponents
import SwiftUI

/// 外观设置详情页（对齐 Lumi `ThemeSettingsDetailView`）。
///
/// 作为设置窗口「外观」导航项的 destination：顶部展示主题统计与当前主题，
/// 下方为完整主题列表（筛选 + 切换 + 色板预览，由 `ThemeSettingsRootView`
/// 提供）。主题数据来自环境值（由 `SettingsWindow` 的 `KernelEnvironmentModifier`
/// 从 `ThemeProviding` 投影）。
struct ThemeSettingsDetailView: View {
    @Environment(\.pluginThemes) private var themes
    @Environment(\.currentPluginThemeId) private var currentThemeId
    @Environment(\.selectPluginThemeAction) private var selectTheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerStats

                ThemeSettingsRootView(
                    themes: themes,
                    currentThemeId: currentThemeId,
                    selectTheme: { themeId in
                        selectTheme(themeId)
                    }
                )
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var headerStats: some View {
        HStack(spacing: 10) {
            Label("\(themes.count) 个主题", systemImage: "paintpalette")
            if let active = themes.first(where: { $0.id == currentThemeId }) {
                Text("当前：\(active.displayName)")
            }
            Spacer()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
