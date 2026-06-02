import CisumUI
import SwiftUI

public typealias ThemeSettingsSelectThemeAction = @MainActor (String) -> Void

public struct ThemeSettingsRootView: View {
    private let themes: [LumiUIThemeContribution]
    private let currentThemeId: String
    private let selectTheme: ThemeSettingsSelectThemeAction

    public init(
        themes: [LumiUIThemeContribution],
        currentThemeId: String,
        selectTheme: @escaping ThemeSettingsSelectThemeAction
    ) {
        self.themes = themes
        self.currentThemeId = currentThemeId
        self.selectTheme = selectTheme
    }

    public var body: some View {
        MagicSettingSection(title: String(localized: "Theme Style", bundle: .module)) {
            ForEach(themes) { theme in
                let isSelected = currentThemeId == theme.id
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
                        selectTheme(theme.id)
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
