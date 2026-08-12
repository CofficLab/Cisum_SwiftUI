import CisumUI
import Foundation
import SwiftUI

/// `ThemeProviding` 的具体实现。
///
/// 吸收旧版 `ThemeVM` + `ThemeService` + `LumiUIThemeRegistry` 的编排：
/// 通过注入的 `contributionsProvider` 拉取插件主题贡献，按 `id` 选择并持久化
/// （`UserDefaults` key `"Cisum.SelectedThemeID"`），并将结果同步到 CisumUI
/// 的 `LumiUIThemeRegistry`。
@MainActor
public final class ThemeService: ObservableObject, ThemeProviding {
    private static let selectedThemeKey = "Cisum.SelectedThemeID"

    private let registry: LumiUIThemeRegistry
    private let contributionsProvider: () -> [LumiUIThemeContribution]

    @Published public private(set) var allThemeContributions: [LumiUIThemeContribution] = []
    @Published public private(set) var selectedThemeID: String = ""

    public init(
        registry: LumiUIThemeRegistry = .shared,
        contributionsProvider: @escaping () -> [LumiUIThemeContribution]
    ) {
        self.registry = registry
        self.contributionsProvider = contributionsProvider
    }

    public var activeChromeTheme: any LumiAppChromeTheme {
        allThemeContributions.first { $0.id == selectedThemeID }?.chromeTheme
            ?? registry.chromeTheme
    }

    public var preferredColorScheme: ColorScheme? {
        switch activeChromeTheme.appearanceKind {
        case .dark: .dark
        case .light: .light
        case .system: nil
        }
    }

    public func reloadThemes() {
        let contributions = contributionsProvider()
        allThemeContributions = contributions

        let savedID = UserDefaults.standard.string(forKey: Self.selectedThemeKey) ?? ""
        if contributions.contains(where: { $0.id == savedID }) {
            selectedThemeID = savedID
        } else {
            selectedThemeID = contributions.first?.id ?? ""
        }
    }

    public func selectTheme(_ themeID: String) {
        guard allThemeContributions.contains(where: { $0.id == themeID }) else { return }
        guard selectedThemeID != themeID else { return }
        selectedThemeID = themeID
        UserDefaults.standard.set(themeID, forKey: Self.selectedThemeKey)
        syncToCisumUI()
        NotificationCenter.default.post(name: .cisumThemeDidChange, object: nil)
    }

    public func syncToCisumUI() {
        do {
            try registry.replaceAll(allThemeContributions)
            if !selectedThemeID.isEmpty {
                try registry.select(themeId: selectedThemeID)
            }
        } catch {
            // 忽略主题注册错误（无主题/重复 id 等），保持降级运行。
        }
    }
}
