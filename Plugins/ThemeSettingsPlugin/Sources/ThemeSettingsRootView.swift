import CisumUI
import SwiftUI

public typealias ThemeSettingsSelectThemeAction = @MainActor (String) -> Void

public struct ThemeSettingsRootView: View {
    private let themes: [LumiUIThemeContribution]
    private let currentThemeId: String
    private let selectTheme: ThemeSettingsSelectThemeAction
    @State private var appearanceFilter: ThemeAppearanceFilter = .all

    private var filteredThemes: [LumiUIThemeContribution] {
        themes.filter { appearanceFilter.matches($0.appearanceKind) }
    }

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
            Picker("", selection: $appearanceFilter) {
                ForEach(ThemeAppearanceFilter.allCases) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            if filteredThemes.isEmpty {
                MagicSettingRow(
                    title: String(localized: "No themes in this category", bundle: .module),
                    description: nil,
                    icon: "line.3.horizontal.decrease.circle",
                    action: {}
                ) {
                    EmptyView()
                }
            }

            ForEach(filteredThemes) { theme in
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

private enum ThemeAppearanceFilter: String, CaseIterable, Identifiable {
    case all
    case dark
    case light
    case system

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return String(localized: "All", bundle: .module)
        case .dark:
            return String(localized: "Black", bundle: .module)
        case .light:
            return String(localized: "Light", bundle: .module)
        case .system:
            return String(localized: "System", bundle: .module)
        }
    }

    func matches(_ kind: ThemeAppearanceKind) -> Bool {
        switch self {
        case .all:
            return true
        case .dark:
            return kind == .dark
        case .light:
            return kind == .light
        case .system:
            return kind == .system
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
