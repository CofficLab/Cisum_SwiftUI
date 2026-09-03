import CisumUIComponents
import ProviderScene
import SwiftUI

/// 场景设置页：展示当前场景，并通过 `SceneProviding` 切换场景。
struct SceneSettingsView: View {
    @Environment(\.sceneProviding) private var scene
    @StateObject private var model: SceneSettingsModel

    init() {
        _model = StateObject(wrappedValue: SceneSettingsModel(scene: nil))
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

@MainActor
private final class SceneSettingsModel: ObservableObject {
    @Published private(set) var sceneNames: [String] = []
    @Published private(set) var currentSceneName: String?
    @Published private(set) var errorMessage: String?

    private weak var scene: (any SceneProviding)?
    private var observer: (any SceneProvidingObserverHandle)?

    init(scene: (any SceneProviding)?) {
        self.scene = scene
        refresh()
    }

    var currentSceneIconName: String {
        guard let currentSceneName else { return "rectangle.3.group" }
        return iconName(for: currentSceneName)
    }

    func attach(to scene: (any SceneProviding)?) {
        guard observer == nil else {
            refresh()
            return
        }

        detach()
        self.scene = scene
        refresh()

        guard let scene else { return }
        observer = scene.addObserver { [weak self] _ in
            self?.refresh()
        }
    }

    func detach() {
        observer?.cancel()
        observer = nil
    }

    func select(_ sceneName: String) {
        guard let scene else { return }
        errorMessage = nil
        do {
            try scene.setCurrentScene(sceneName)
            refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func iconName(for sceneName: String) -> String {
        scene?.plugin(for: sceneName)?.iconName ?? "rectangle.3.group"
    }

    private func refresh() {
        sceneNames = scene?.sceneNames ?? []
        currentSceneName = scene?.currentSceneName
    }
}
