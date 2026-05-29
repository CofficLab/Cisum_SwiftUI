import SwiftUI

private struct PosterDismissActionKey: EnvironmentKey {
    static let defaultValue: @MainActor () -> Void = {}
}

private struct SetCurrentSceneActionKey: EnvironmentKey {
    static let defaultValue: @MainActor (String) throws -> Void = { _ in }
}

private struct ResetSettingsActionKey: EnvironmentKey {
    static let defaultValue: @Sendable () async -> Void = {}
}

private struct PluginThemesKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: [LumiUIThemeContribution] = []
}

private struct CurrentPluginThemeIdKey: EnvironmentKey {
    static let defaultValue = ""
}

private struct SelectPluginThemeActionKey: EnvironmentKey {
    static let defaultValue: @MainActor (String) -> Void = { _ in }
}

private struct CurrentSceneNameKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

private struct DemoModeKey: EnvironmentKey {
    static let defaultValue = false
}

private struct AppIsImportingKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

private struct ShowAudioDBViewActionKey: EnvironmentKey {
    static let defaultValue: @MainActor () -> Void = {}
}

public extension EnvironmentValues {
    var posterDismissAction: @MainActor () -> Void {
        get { self[PosterDismissActionKey.self] }
        set { self[PosterDismissActionKey.self] = newValue }
    }

    var setCurrentSceneAction: @MainActor (String) throws -> Void {
        get { self[SetCurrentSceneActionKey.self] }
        set { self[SetCurrentSceneActionKey.self] = newValue }
    }

    var resetSettingsAction: @Sendable () async -> Void {
        get { self[ResetSettingsActionKey.self] }
        set { self[ResetSettingsActionKey.self] = newValue }
    }

    var pluginThemes: [LumiUIThemeContribution] {
        get { self[PluginThemesKey.self] }
        set { self[PluginThemesKey.self] = newValue }
    }

    var currentPluginThemeId: String {
        get { self[CurrentPluginThemeIdKey.self] }
        set { self[CurrentPluginThemeIdKey.self] = newValue }
    }

    var selectPluginThemeAction: @MainActor (String) -> Void {
        get { self[SelectPluginThemeActionKey.self] }
        set { self[SelectPluginThemeActionKey.self] = newValue }
    }

    var currentSceneName: String? {
        get { self[CurrentSceneNameKey.self] }
        set { self[CurrentSceneNameKey.self] = newValue }
    }

    var demoMode: Bool {
        get { self[DemoModeKey.self] }
        set { self[DemoModeKey.self] = newValue }
    }

    var appIsImporting: Binding<Bool> {
        get { self[AppIsImportingKey.self] }
        set { self[AppIsImportingKey.self] = newValue }
    }

    var showAudioDBViewAction: @MainActor () -> Void {
        get { self[ShowAudioDBViewActionKey.self] }
        set { self[ShowAudioDBViewActionKey.self] = newValue }
    }
}

public extension View {
    func inDemoMode() -> some View {
        environment(\.demoMode, true)
    }
}
