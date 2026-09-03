import KernelCore
import ProviderDocsView
import CisumUIComponents
import PluginBookScene
import ProviderScene
import SwiftUI

public actor BookLikePlugin: SuperPlugin {
    public static let shared = BookLikePlugin()
    public static let metadata = PluginMetadata(
        displayName: BookLikePluginInfo.title,
        description: BookLikePluginInfo.description,
        iconName: BookLikePluginInfo.iconName,
        order: BookLikePluginInfo.order,
        policy: .optIn,
        category: .like,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookLikePluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookLikePluginManualView() })
        }
    }

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
        return AnyView(BookLikePluginRootView(scene: scene, content: content))
    }

    @MainActor
    public func addSettingView() -> AnyView? {
        nil
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        PluginSettingNavigationItem(
            id: "liked-books",
            title: String(localized: "Liked Books", bundle: .module),
            description: Self.metadata.description,
            iconName: Self.metadata.iconName,
            order: Self.metadata.order,
            destination: AnyView(BookLikeSettingsView())
        )
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
