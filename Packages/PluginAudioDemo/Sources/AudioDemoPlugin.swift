import KernelCore
import CisumUIComponents
import PluginAudioScene
import ProviderScene
import SwiftUI

public actor AudioDemoPlugin: SuperPlugin {
    public static let shared = AudioDemoPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioDemoPluginInfo.title,
        description: AudioDemoPluginInfo.description,
        iconName: AudioDemoPluginInfo.iconName,
        order: 1
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
    public func addTabView(reason: String, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard sceneBox.scene?.currentSceneName == AudioScenePlugin.sceneName else { return nil }
        guard demoMode else { return nil }

        let addButton = AnyView(
            AudioDemoAddButton()
                .font(.title2)
                .labelStyle(.iconOnly)
        )

        return (
            AnyView(AudioListDemo(showAddButton: Self.isNotDesktop, addButton: addButton)),
            AudioDemoPluginInfo.tabLabel
        )
    }

    private static var isNotDesktop: Bool {
        #if os(macOS)
            false
        #else
            true
        #endif
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
