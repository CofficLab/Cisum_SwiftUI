import OSLog
import SwiftUI

protocol SuperPlugin: MagicSuperPlugin {
    @MainActor func addLaunchView() -> AnyView?
    @MainActor func addSheetView(storage: StorageLocation?) -> AnyView?
    @MainActor func addStateView(currentGroup: SuperPlugin?) -> AnyView?
    @MainActor func addPosterView() -> AnyView?
    @MainActor func addDBView(reason: String, currentPluginId: String?) -> (view: AnyView, label: String)?
    @MainActor func addSettingView() -> AnyView?
    @MainActor func addStatusView() -> AnyView?
    @MainActor func addToolBarButtons() -> [(id: String, view: AnyView)]
    @MainActor func getDisk() -> URL?
}

extension SuperPlugin {
    nonisolated func addLaunchView() -> AnyView? { nil }
    
    nonisolated func addSheetView(storage: StorageLocation?) -> AnyView? { nil }

    nonisolated func addStateView(currentGroup: SuperPlugin?) -> AnyView? { nil }

    @MainActor func addDBView(reason: String, currentPluginId: String?) -> (view: AnyView, label: String)? { nil }

    nonisolated func addPosterView() -> AnyView? { nil }

    nonisolated func addToolBarButtons() -> [(id: String, view: AnyView)] { [] }

    nonisolated func addStatusView() -> AnyView? { nil }
    
    nonisolated func addSettingView() -> AnyView? { nil }

    @MainActor func getDisk() -> URL? { nil }
}
