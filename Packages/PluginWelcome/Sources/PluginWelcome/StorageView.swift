import CisumUI
import MagicKit
import SwiftUI

public struct StorageView: View {
    private let isICloudAvailable: Bool
    private let currentStorageSelection: WelcomeStorageSelection?
    private let updateStorageSelection: @MainActor (WelcomeStorageSelection) -> Void

    @State private var tempStorageSelection: WelcomeStorageSelection

    public init(
        isICloudAvailable: Bool,
        currentStorageSelection: WelcomeStorageSelection?,
        updateStorageSelection: @escaping @MainActor (WelcomeStorageSelection) -> Void
    ) {
        self.isICloudAvailable = isICloudAvailable
        self.currentStorageSelection = currentStorageSelection
        self.updateStorageSelection = updateStorageSelection
        _tempStorageSelection = State(initialValue: currentStorageSelection ?? .icloud)
    }

    public var body: some View {
        CisumUI.MagicSettingSection(
            title: String(localized: "Media Storage Location", table: "Welcome", bundle: .module),
            titleAlignment: .center
        ) {
            VStack(spacing: 12) {
                CisumUI.MagicSettingRow(
                    title: String(localized: "iCloud Drive", table: "Welcome", bundle: .module),
                    description: String(localized: "Files stored in iCloud\nAccessible on other devices\nEnsure sufficient iCloud storage", table: "Welcome", bundle: .module),
                    icon: .cisumIconCloud,
                    action: {
                        if isICloudAvailable {
                            tempStorageSelection = .icloud
                        }
                    }
                ) {
                    HStack {
                        if tempStorageSelection == .icloud {
                            Image(systemName: .cisumIconCheckmarkSimple)
                                .foregroundColor(.accentColor)
                        } else {
                            Text("Recommended", tableName: "Welcome", bundle: .module)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .opacity(isICloudAvailable ? 1 : 0.5)
                .disabled(!isICloudAvailable)

                if !isICloudAvailable {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .imageScale(.small)
                        Text("Sign in to iCloud in System Settings to use this option", tableName: "Welcome", bundle: .module)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 32)
                    .padding(.bottom, 8)
                }

                Divider()

                CisumUI.MagicSettingRow(
                    title: String(localized: "App Local Storage", table: "Welcome", bundle: .module),
                    description: String(localized: "Stored within the app, data will be lost if app is deleted", table: "Welcome", bundle: .module),
                    icon: .cisumIconFolder,
                    action: {
                        tempStorageSelection = .local
                    }
                ) {
                    HStack {
                        if tempStorageSelection == .local {
                            Image(systemName: .cisumIconCheckmarkSimple)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .onAppear(perform: onAppear)
            .onDisappear(perform: onDisappear)
        }
    }

    private func onAppear() {
        if let currentStorageSelection {
            tempStorageSelection = currentStorageSelection
        }
    }

    private func onDisappear() {
        updateStorageSelection(tempStorageSelection)
    }
}
