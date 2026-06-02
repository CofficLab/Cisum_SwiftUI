import CisumUI
import MagicKit
import SwiftUI

public actor WelcomePlugin: SuperPlugin, SuperLog {
    public static let shared = WelcomePlugin()
    public nonisolated static let emoji = WelcomePluginInfo.emoji
    public static let verbose = true
    public static var shouldRegister: Bool { true }
    public static var order: Int { WelcomePluginInfo.order }

    public nonisolated var title: String { WelcomePluginInfo.title }
    public nonisolated var description: String { WelcomePluginInfo.description }
    public let iconName = WelcomePluginInfo.iconName

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

private struct WelcomePluginGuideView: View {
    var body: some View {
        WelcomeView(
            isICloudAvailable: WelcomePluginHost.isICloudAvailable,
            currentStorageSelection: WelcomePluginHost.currentStorageSelection,
            updateStorageSelection: { selection in
                WelcomePluginHost.updateStorageSelection(selection)
            }
        )
    }
}
