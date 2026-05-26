import CisumUI
import MagicKit
import SwiftUI

actor ThemeSettingsPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 140 }

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
        MagicSettingSection(title: String(localized: "Theme Style", table: "Theme-Settings")) {
            ForEach(themeProvider.themes) { theme in
                let isSelected = themeProvider.currentThemeId == theme.id
                MagicSettingRow(
                    title: theme.displayName,
                    description: theme.description,
                    icon: theme.iconName,
                    titleSuffix: {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(theme.iconColor)
                        }
                    },
                    action: {
                        themeProvider.selectTheme(theme.id)
                    }
                ) {
                    ThemeSwatches(theme: theme.chromeTheme)
                        .fixedSize()
                }
            }
        }
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
