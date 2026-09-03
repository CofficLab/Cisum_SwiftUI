import CisumUIComponents
import ProviderScene
import SwiftUI

/// 场景设置页：展示当前场景，并通过 `SceneProviding` 切换场景。
struct SceneSettingsView: View {
    @Environment(\.sceneProviding) private var scene
    @StateObject private var model: SceneSettingsViewModel

    init() {
        _model = StateObject(wrappedValue: SceneSettingsViewModel(scene: nil))
    }

    var body: some View {
        AppSettingsContentScaffold {
            VStack(alignment: .leading, spacing: 16) {
                AppSettingSection(
                    title: String(localized: "Current Scene", bundle: .module)
                ) {
                    AppSettingRow(
                        title: model.currentSceneName ?? String(localized: "No scene selected", bundle: .module),
                        description: String(localized: "The scene currently shown in the main window", bundle: .module),
                        icon: model.currentSceneIconName
                    ) {
                        if model.currentSceneName != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }

                AppSettingSection(
                    title: String(localized: "Available Scenes", bundle: .module)
                ) {
                    if model.sceneNames.isEmpty {
                        AppSettingRow(
                            title: String(localized: "No scenes available", bundle: .module),
                            description: String(localized: "Enable a plugin that provides a scene", bundle: .module),
                            icon: "rectangle.3.group"
                        ) {
                            EmptyView()
                        }
                    } else {
                        ForEach(model.sceneNames, id: \.self) { sceneName in
                            AppSettingRow(
                                title: sceneName,
                                description: String(localized: "Switch to this scene", bundle: .module),
                                icon: model.iconName(for: sceneName),
                                titleSuffix: {
                                    if model.currentSceneName == sceneName {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    }
                                },
                                action: { model.select(sceneName) }
                            ) {
                                if model.currentSceneName == sceneName {
                                    Text(String(localized: "Current", bundle: .module))
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                }

                if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 8)
                }
            }
        }
        .onAppear {
            model.attach(to: scene)
        }
        .onDisappear {
            model.detach()
        }
    }
}
