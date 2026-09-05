@testable import PluginThemeSettings
import KernelCore
import CisumUIComponents
import SwiftUI
import Testing

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(ThemeSettingsPluginInfo.iconName == "paintbrush")
    #expect(ThemeSettingsPluginInfo.order == 140)
}

// MARK: - Observer + ViewModel 生命周期（迁移 Phase 1）

private struct TestChromeTheme: LumiAppChromeTheme {
    let identifier = "test-theme"
    let displayName = "Test Theme"
    let compactName = "Test"
    let description = "Test theme for observer lifecycle"
    let iconName = "paintpalette"
    let iconColor: Color = .blue
    let appearanceKind: ThemeAppearanceKind = .light

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (.blue, .blue.opacity(0.7), .blue.opacity(0.4))
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (.black, .gray, .white)
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        (.blue.opacity(0.2), .blue.opacity(0.5), .blue)
    }

    func makeGlobalBackground(proxy: GeometryProxy) -> AnyView {
        AnyView(Color.clear)
    }
}

@MainActor
private func makeThemeService() -> ThemeService {
    let theme = TestChromeTheme()
    let contribution = LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 1, themeId: theme.identifier),
        chromeTheme: theme,
        editorThemeId: theme.identifier
    )
    let service = ThemeService(contributionsProvider: { [contribution] })
    service.reloadThemes()
    return service
}

@MainActor
@Test func themeObserverPerformsInitialSync() {
    let service = makeThemeService()

    let viewModel = ThemeSettingsViewModel(
        capability: ThemeSettingsCapabilityAdapter(theme: service)
    )
    let observer = ThemeProvidingObserver(provider: service, viewModel: viewModel)
    defer { observer.cancel() }

    // 监听安装前已经存在的状态不能丢失。
    #expect(viewModel.themes.map(\.id) == ["test-theme"])
    #expect(viewModel.currentThemeID == "test-theme")
}

@MainActor
@Test func themeObserverForwardsSelectionToViewModel() {
    let theme = TestChromeTheme()
    let contribution = LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 1, themeId: theme.identifier),
        chromeTheme: theme,
        editorThemeId: theme.identifier
    )
    let service = ThemeService(contributionsProvider: { [contribution] })

    let viewModel = ThemeSettingsViewModel(
        capability: ThemeSettingsCapabilityAdapter(theme: service)
    )
    let observer = ThemeProvidingObserver(provider: service, viewModel: viewModel)
    defer { observer.cancel() }

    service.reloadThemes()
    #expect(viewModel.themes.map(\.id) == ["test-theme"])
}

@MainActor
@Test func themeObserverCancelStopsViewModelUpdates() {
    let service = makeThemeService()
    let viewModel = ThemeSettingsViewModel(
        capability: ThemeSettingsCapabilityAdapter(theme: service)
    )
    let observer = ThemeProvidingObserver(provider: service, viewModel: viewModel)

    #expect(viewModel.currentThemeID == "test-theme")

    observer.cancel()
    // 无可选中变化时保持当前选中；cancel 后重新加载不再覆盖 ViewModel。
    service.reloadThemes()
    #expect(viewModel.currentThemeID == "test-theme")
}
