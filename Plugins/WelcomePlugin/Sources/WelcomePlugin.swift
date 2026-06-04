import CisumUI
import MagicKit
import SwiftUI

public actor WelcomePlugin: SuperPlugin, SuperLog {
    public static let shared = WelcomePlugin()
    public nonisolated static let emoji = WelcomePluginInfo.emoji
    public static let verbose = true
    public static let metadata = PluginMetadata(
        displayName: WelcomePluginInfo.title,
        description: WelcomePluginInfo.description,
        iconName: WelcomePluginInfo.iconName,
        order: WelcomePluginInfo.order
    )

    @MainActor
    public func addGuideView() -> AnyView? {
        guard WelcomePluginHost.hasStorageLocation == false else {
            return nil
        }

        return AnyView(WelcomePluginGuideView())
    }

    @MainActor
    public func completeGuidePage() -> Bool {
        guard WelcomePluginHost.hasStorageLocation == false else {
            return true
        }

        let selection = WelcomeStorageSelectionPolicy.defaultSelection(
            currentStorageSelection: WelcomePluginHost.currentStorageSelection,
            isICloudAvailable: WelcomePluginHost.isICloudAvailable
        )
        WelcomePluginHost.updateStorageSelection(selection)
        return true
    }
}
