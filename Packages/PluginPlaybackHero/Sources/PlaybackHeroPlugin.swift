import CisumUIComponents
import KernelCore
import ProviderDocsView
import SwiftUI

/// 播放封面插件：向播放控制区注入封面/标题区视图（`setHeroView`）。
public actor PlaybackHeroPlugin: SuperPlugin {
    public static let shared = PlaybackHeroPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: "Playback Cover", bundle: .module),
        description: String(localized: "Provides the cover and title view for the player control area.", bundle: .module),
        iconName: "photo",
        order: 19,
        policy: .alwaysOn,
        category: .playback,
        version: "1.0.0"
    )

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { PlaybackHeroPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { PlaybackHeroPluginManualView() })
        }
    }

    /// 向 `ControlViewProviding` 注入封面/标题区视图。
    @MainActor
    public func addHeroView() -> AnyView? {
        AnyView(PlaybackHeroView())
    }
}
