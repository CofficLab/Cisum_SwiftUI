import CisumUI
import MagicKit
import SwiftUI

public typealias ResetSettingsAction = @Sendable () async -> Void

public struct SystemSetting: View, SuperLog {
    public nonisolated static let emoji = ResetPluginInfo.emoji
    public nonisolated static let verbose = false

    @State private var showConfirmSheet = false

    private let appVersion: String
    private let resetSettings: ResetSettingsAction

    public init(
        appVersion: String,
        resetSettings: @escaping ResetSettingsAction
    ) {
        self.appVersion = appVersion
        self.resetSettings = resetSettings
    }

    public var body: some View {
        CisumUI.MagicSettingSection(title: String(localized: "App Information", table: "Reset", bundle: .module)) {
            CisumUI.MagicSettingRow(
                title: String(localized: "Current Version", table: "Reset", bundle: .module),
                description: String(localized: "App version", table: "Reset", bundle: .module),
                icon: "info.circle",
                content: {
                    Text(appVersion)
                        .font(.footnote)
                }
            )

            CisumUI.MagicSettingRow(
                title: String(localized: "Reset Storage Location", table: "Reset", bundle: .module),
                description: String(localized: "Clear the media storage selection", table: "Reset", bundle: .module),
                icon: .cisumIconReset
            ) {
                Image.cisumReset
                    .frame(width: 28, height: 28)
                    .background(.regularMaterial, in: Circle())
                    .cisumShadowSm()
                    .cisumHoverScale(105)
                    .cisumButton {
                        showConfirmSheet = true
                    }
            }
        }
        .sheet(isPresented: $showConfirmSheet) {
            ResetConfirm(resetSettings: resetSettings)
                .frame(width: 400)
        }
    }
}
