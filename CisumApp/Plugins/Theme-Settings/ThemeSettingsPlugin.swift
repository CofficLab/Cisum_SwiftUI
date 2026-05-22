import CisumUI
import SwiftUI

actor ThemeSettingsPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 126 }

    let title = "主题"
    let description = "切换应用主题"
    let iconName = "paintbrush"

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(ThemeSettingView())
    }
}

struct ThemeSettingView: View {
    @EnvironmentObject private var themeProvider: AppThemeProvider

    var body: some View {
        AppCard(style: .subtle, cornerRadius: 12, showShadow: false) {
            AppSettingsSection(title: "主题风格", subtitle: "选择播放器的整体视觉风格", spacing: 12) {
                ForEach(themeProvider.themes) { theme in
                    ThemeOptionCard(
                        theme: theme,
                        isSelected: themeProvider.currentThemeId == theme.id
                    ) {
                        themeProvider.selectTheme(theme.id)
                    }
                }
            }
        }
    }
}

private struct ThemeOptionCard: View {
    @LumiTheme private var appTheme

    let theme: LumiUIThemeContribution
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: theme.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isSelected ? theme.iconColor : appTheme.textTertiary)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(.appBody)
                        .foregroundColor(appTheme.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(theme.description)
                        .font(.appCaption)
                        .foregroundColor(appTheme.textTertiary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                ThemeSwatches(theme: theme.chromeTheme)
                    .fixedSize()
                    .layoutPriority(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? theme.iconColor.opacity(0.14) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? theme.iconColor : appTheme.textTertiary.opacity(0.08), lineWidth: isSelected ? 2 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

private struct ThemeSwatches: View {
    let theme: any LumiAppChromeTheme

    var body: some View {
        let accent = theme.accentColors()
        let atmosphere = theme.atmosphereColors()

        HStack(spacing: 4) {
            swatch(atmosphere.deep)
            swatch(atmosphere.light)
            swatch(accent.primary)
            swatch(accent.secondary)
        }
        .accessibilityHidden(true)
    }

    private func swatch(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 14, height: 14)
            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
