import CisumUIComponents
import KernelCore
import ProviderDocsView
import SwiftUI

/// 播放进度插件：向播放控制区注入进度条视图（`setProgressView`）。
public actor PlaybackProgressPlugin: SuperPlugin {
    public static let shared = PlaybackProgressPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: "Playback Progress", bundle: .module),
        description: String(localized: "Provides the progress bar view for the player control area.", bundle: .module),
        iconName: "waveform",
        order: 21,
        policy: .alwaysOn,
        category: .playback,
        version: "1.0.0"
    )

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { PlaybackProgressPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { PlaybackProgressPluginManualView() })
        }
    }

    /// 向 `ControlViewProviding` 注入播放进度条视图。
    @MainActor
    public func addProgressView() -> AnyView? {
        AnyView(PlaybackProgressView())
    }
}
