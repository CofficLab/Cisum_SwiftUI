import Foundation
import MagicKit
import OSLog
import PluginWelcome
import SwiftUI

actor WelcomePlugin: SuperPlugin, SuperLog {
    static let shared = WelcomePlugin()
    static let emoji = WelcomePluginInfo.emoji
    static let verbose = true
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 -100，最先执行
    static var order: Int { WelcomePluginInfo.order }

    nonisolated var title: String { WelcomePluginInfo.title }
    nonisolated var description: String { WelcomePluginInfo.description }
    let iconName = WelcomePluginInfo.iconName

    @MainActor
    func addGuideView() -> AnyView? {
        guard Config.getStorageLocation() == nil else {
            return nil
        }

        return AnyView(WelcomePluginGuideView())
    }
}

private struct WelcomePluginGuideView: View {
    @EnvironmentObject private var cloudManager: CloudProvider

    var body: some View {
        WelcomeView(
            isICloudAvailable: cloudManager.isSignedIn == true,
            currentStorageSelection: Config.getStorageLocation()?.welcomeSelection,
            updateStorageSelection: { selection in
                Config.updateStorageLocation(StorageLocation(selection))
            }
        )
    }
}

private extension StorageLocation {
    init(_ selection: WelcomeStorageSelection) {
        switch selection {
        case .icloud:
            self = .icloud
        case .local:
            self = .local
        }
    }

    var welcomeSelection: WelcomeStorageSelection? {
        switch self {
        case .icloud:
            return .icloud
        case .local:
            return .local
        case .custom:
            return nil
        }
    }
}
