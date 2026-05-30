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
    @State private var location: PluginStorageLocation = .local

    public init() {
        _targetLocation = State(initialValue: .local)
    }

    public var body: some View {
        AppSettingsSection(title: "Media Storage Location") {
            VStack(spacing: 0) {
                AppSettingsInfoRow(
                    title: "iCloud Drive",
                    description: isICloudAvailable ? "Store media files in iCloud Drive" : "iCloud Drive is unavailable",
                    systemImage: .cisumIconCloud,
                    isSelected: location == .icloud,
                    action: isICloudAvailable ? {
                        beginMigration(to: .icloud)
                    } : nil
                ) {
                    if location == .icloud {
                        Image(systemName: .cisumIconCheckmarkSimple)
                            .foregroundColor(.accentColor)
                    } else if !isICloudAvailable {
                        Text("Unavailable")
                    }
                }
                .opacity(isICloudAvailable ? 1 : 0.5)

                AppSettingsInfoRow(
                    title: "Local",
                    description: isLocalStorageAvailable ? "Store within app, data will be lost if app is deleted" : "Local storage is unavailable",
                    systemImage: .cisumIconFolder,
                    isSelected: location == .local,
                    action: isLocalStorageAvailable ? {
                        beginMigration(to: .local)
                    } : nil
                ) {
                    if location == .local {
                        Image(systemName: .cisumIconCheckmarkSimple)
                            .foregroundColor(.accentColor)
                    } else if !isLocalStorageAvailable {
                        Text("Unavailable")
                    }
                }
                .opacity(isLocalStorageAvailable ? 1 : 0.5)
            }
        }
        .sheet(isPresented: $showMigrationProgress) {
            MigrationProgressView(
                sourceLocation: dependencies.getStorageLocation() ?? .local,
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
            location = dependencies.getStorageLocation() ?? location
            targetLocation = dependencies.getStorageLocation() ?? .local
        }
        .onChange(of: targetLocation) {
            hasChanges = targetLocation != (dependencies.getStorageLocation() ?? .local)
        }
        .onPluginStorageLocationChanged {
            location = dependencies.getStorageLocation() ?? location
        }
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
}
