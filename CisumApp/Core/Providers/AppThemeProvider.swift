import CisumUI
import Combine
import Foundation
import OSLog
import SwiftUI

/// 应用主题状态。
///
/// 主题定义由插件提供，当前选择由该 provider 持久化并同步到 `CisumUI`。
@MainActor
final class AppThemeProvider: ObservableObject, SuperLog {
    nonisolated static let emoji = "🎨"
    nonisolated static let verbose = false

    private static let selectedThemeKey = "Cisum.SelectedThemeID"

    private let pluginProvider: PluginProvider
    private let registry: LumiUIThemeRegistry
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var themes: [LumiUIThemeContribution] = []

    @Published var currentThemeId: String {
        didSet {
            guard oldValue != currentThemeId else { return }
            applySelection(themeId: currentThemeId)
        }
    }

    var currentTheme: LumiUIThemeContribution? {
        themes.first(where: { $0.id == currentThemeId })
    }

    var activeChromeTheme: any LumiAppChromeTheme {
        currentTheme?.chromeTheme ?? registry.chromeTheme
    }

    var preferredColorScheme: ColorScheme? {
        let theme = activeChromeTheme
        if theme.followsSystemAppearance {
            return nil
        }
        return theme.isDarkTheme ? .dark : .light
    }

    init(pluginProvider: PluginProvider, registry: LumiUIThemeRegistry = .shared) {
        self.pluginProvider = pluginProvider
        self.registry = registry

        do {
            try ThemeService.shared.syncFromPlugins(pluginProvider: pluginProvider, registry: registry)
        } catch {
            os_log(.error, "\(Self.t)主题注册失败: \(error.localizedDescription)")
        }

        let savedThemeId = UserDefaults.standard.string(forKey: Self.selectedThemeKey)
        if let savedThemeId, registry.themes.contains(where: { $0.id == savedThemeId }) {
            try? registry.select(themeId: savedThemeId)
        }

        let initialThemeId = registry.selectedThemeId ?? registry.themes.first?.id ?? ""
        self.themes = registry.themes
        self.currentThemeId = initialThemeId
        bindRegistry()
        postThemeDidChange()
    }

    func reloadThemes() {
        do {
            try ThemeService.shared.syncFromPlugins(pluginProvider: pluginProvider, registry: registry)
        } catch {
            os_log(.error, "\(self.t)主题同步失败: \(error.localizedDescription)")
            return
        }
        syncPublishedStateFromRegistry(preserveSelection: true)
    }

    func selectTheme(_ themeId: String) {
        guard themes.contains(where: { $0.id == themeId }) else { return }
        if currentThemeId != themeId {
            currentThemeId = themeId
        }
    }

    private func bindRegistry() {
        registry.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.syncPublishedStateFromRegistry(preserveSelection: true)
            }
            .store(in: &cancellables)
    }

    private func syncPublishedStateFromRegistry(preserveSelection: Bool) {
        themes = registry.themes
        guard let selectedId = registry.selectedThemeId else { return }
        if preserveSelection, themes.contains(where: { $0.id == currentThemeId }) {
            postThemeDidChange()
            return
        }
        if currentThemeId != selectedId {
            currentThemeId = selectedId
        } else {
            postThemeDidChange()
        }
    }

    private func applySelection(themeId: String) {
        do {
            try registry.select(themeId: themeId)
        } catch {
            os_log(.error, "\(self.t)主题选择失败: \(error.localizedDescription)")
            return
        }
        UserDefaults.standard.set(themeId, forKey: Self.selectedThemeKey)
        postThemeDidChange()
    }

    private func postThemeDidChange() {
        guard let selected = currentTheme ?? themes.first else { return }
        NotificationCenter.default.post(
            name: .cisumThemeDidChange,
            object: nil,
            userInfo: ["themeId": selected.id]
        )
    }
}
