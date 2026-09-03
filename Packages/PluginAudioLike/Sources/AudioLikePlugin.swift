import KernelCore
import CisumUIComponents
import PluginAudioScene
import ProviderScene
import SwiftUI

public actor AudioLikePlugin: SuperPlugin {
    public static let shared = AudioLikePlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioLikePluginInfo.title,
        description: AudioLikePluginInfo.description,
        iconName: AudioLikePluginInfo.iconName,
        order: AudioLikePluginInfo.order,
        policy: .optIn
    )

    nonisolated(unsafe) private let sceneBox = SceneBox()

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        guard let scene = kernel.resolveProvider((any SceneProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "SceneProviding")
        }
        sceneBox.scene = scene
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        sceneBox.scene = nil
    }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        let scene = sceneBox.scene
        return AnyView(AudioLikePluginRootView(scene: scene, content: content))
    }

    @MainActor
    public func addSettingView() -> AnyView? {
        nil
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        PluginSettingNavigationItem(
            id: "liked-audio",
            title: String(localized: "Liked audio", bundle: .module),
            description: Self.metadata.description,
            iconName: Self.metadata.iconName,
            order: Self.metadata.order,
            destination: AnyView(AudioLikeSettingsView())
        )
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
