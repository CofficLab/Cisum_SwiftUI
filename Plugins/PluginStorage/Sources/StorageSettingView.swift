import CisumUI
import MagicKit
import OSLog
import SwiftUI

public struct StorageSettingView: View, SuperLog {
    public nonisolated static let emoji: String = "🍴"

    @Environment(\.pluginStorageDependencies) private var dependencies
    @State private var showMigrationProgress = false
    @State private var targetLocation: PluginStorageLocation
    @State private var hasChanges = false
    @State private var location: PluginStorageLocation?

    public init() {
        _targetLocation = State(initialValue: .local)
    }

    public var body: some View {
        CisumUI.MagicSettingSection(title: String(localized: "Media Storage Location", table: "Storage", bundle: .module)) {
            VStack(spacing: 0) {
                CisumUI.MagicSettingRow(
                    title: String(localized: "iCloud Drive", table: "Storage", bundle: .module),
                    description: isICloudAvailable
                        ? String(localized: "Store media files in iCloud Drive", table: "Storage", bundle: .module)
                        : String(localized: "iCloud Drive is unavailable", table: "Storage", bundle: .module),
                    icon: .cisumIconCloud,
                    action: isICloudAvailable ? {
                        beginMigration(to: .icloud)
                    } : nil
                ) {
                    if location == .icloud {
                        Image(systemName: .cisumIconCheckmarkSimple)
                            .foregroundColor(.accentColor)
                    } else if !isICloudAvailable {
                        Text("Unavailable", tableName: "Storage", bundle: .module)
                            .font(.footnote)
                    }
                }
                .opacity(isICloudAvailable ? 1 : 0.5)

                CisumUI.MagicSettingRow(
                    title: String(localized: "Local", table: "Storage", bundle: .module),
                    description: isLocalStorageAvailable
                        ? String(localized: "Store within app, data will be lost if app is deleted", table: "Storage", bundle: .module)
                        : String(localized: "Local storage is unavailable", table: "Storage", bundle: .module),
                    icon: .cisumIconFolder,
                    action: isLocalStorageAvailable ? {
                        beginMigration(to: .local)
                    } : nil
                ) {
                    if location == .local {
                        Image(systemName: .cisumIconCheckmarkSimple)
                            .foregroundColor(.accentColor)
                    } else if !isLocalStorageAvailable {
                        Text("Unavailable", tableName: "Storage", bundle: .module)
                            .font(.footnote)
                    }
                }
                .opacity(isLocalStorageAvailable ? 1 : 0.5)
            }
        }
        .sheet(isPresented: $showMigrationProgress) {
            MigrationProgressView(
                sourceLocation: dependencies.getStorageLocation(),
                targetLocation: targetLocation,
                sourceURL: dependencies.getStorageRoot(),
                targetURL: dependencies.getStorageRootForLocation(targetLocation),
                onDismiss: {
                    showMigrationProgress = false
                    self.hasChanges = targetLocation != dependencies.getStorageLocation()
                }
            )
        }
        .onAppear {
            applyStorageLocationUpdate(dependencies.getStorageLocation())
        }
        .onChange(of: targetLocation) {
            hasChanges = Self.hasSelectionChanges(
                targetLocation: targetLocation,
                storageLocation: dependencies.getStorageLocation()
            )
        }
        .onPluginStorageLocationChanged {
            applyStorageLocationUpdate(dependencies.getStorageLocation())
        }
    }

    private func applyStorageLocationUpdate(_ storageLocation: PluginStorageLocation?) {
        let state = Self.stateAfterStorageUpdate(
            currentTarget: targetLocation,
            storageLocation: storageLocation
        )
        location = storageLocation
        targetLocation = state.targetLocation
        hasChanges = state.hasChanges
    }

    private func beginMigration(to newLocation: PluginStorageLocation) {
        guard newLocation != location else { return }
        guard dependencies.getStorageRootForLocation(newLocation) != nil else { return }

        targetLocation = newLocation
        showMigrationProgress = true
    }

    private var isICloudAvailable: Bool {
        dependencies.getStorageRootForLocation(.icloud) != nil
    }

    private var isLocalStorageAvailable: Bool {
        dependencies.getStorageRootForLocation(.local) != nil
    }

    nonisolated static func targetLocationAfterStorageUpdate(
        currentTarget: PluginStorageLocation,
        storageLocation: PluginStorageLocation?
    ) -> PluginStorageLocation {
        storageLocation ?? currentTarget
    }

    nonisolated static func stateAfterStorageUpdate(
        currentTarget: PluginStorageLocation,
        storageLocation: PluginStorageLocation?
    ) -> (targetLocation: PluginStorageLocation, hasChanges: Bool) {
        let targetLocation = targetLocationAfterStorageUpdate(
            currentTarget: currentTarget,
            storageLocation: storageLocation
        )
        return (
            targetLocation,
            hasSelectionChanges(
                targetLocation: targetLocation,
                storageLocation: storageLocation
            )
        )
    }

    nonisolated static func hasSelectionChanges(
        targetLocation: PluginStorageLocation,
        storageLocation: PluginStorageLocation?
    ) -> Bool {
        storageLocation.map { targetLocation != $0 } ?? false
    }
}
