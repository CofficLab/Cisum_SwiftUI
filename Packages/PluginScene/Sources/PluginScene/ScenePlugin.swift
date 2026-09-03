import CisumKernel
import CisumUIComponents
import Foundation
import ProviderScene
import SwiftUI

/// 场景 Provider 插件。
///
/// 场景列表来自已启用插件的 `addSceneItem()` 贡献；当前场景保存到应用支持
/// 目录中的 JSON 文件，并在内核进入 ready 阶段后恢复。
public actor ScenePlugin: SuperPlugin, CisumKernelPlugin {
    public static let shared = ScenePlugin()
    public static let metadata = PluginMetadata(
        id: "scene",
        displayName: String(localized: "Scene", bundle: .module),
        description: String(localized: "Manages the current scene", bundle: .module),
        iconName: "rectangle.3.group",
        order: 0,
        policy: .alwaysOn
    )

    public init() {}

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        kernel.registerSceneService(
            SceneService(manager: kernel.pluginManager)
        )
    }

    @MainActor
    public func onReady(kernel: CisumKernel) async throws {
        kernel.scene?.restoreCurrentScene()
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        kernel.unregisterProvider((any SceneProviding).self)
    }
}